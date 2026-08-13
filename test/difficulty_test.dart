import 'package:aeonfall/data/cards.dart';
import 'package:aeonfall/data/enemies.dart';
import 'package:aeonfall/data/potions.dart';
import 'package:aeonfall/data/relics.dart';
import 'package:aeonfall/engine/battle.dart';
import 'package:aeonfall/engine/core.dart';
import 'package:aeonfall/engine/director.dart';
import 'package:aeonfall/engine/map_gen.dart';
import 'package:aeonfall/engine/rng.dart';
import 'package:aeonfall/engine/run_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// The difficulty curve, measured rather than asserted.
///
/// Foes used to be drawn flat from a whole act, so the first floor could hand
/// you the heaviest thing in the book and the last floor before the boss could
/// hand you the lightest. Rewards were guaranteed and rares were common. These
/// hold the new numbers to what they claim.
void main() {
  /// Average foe weight actually drawn at a given depth, over many seeds.
  double weightAt(int act, int floor, {int samples = 260}) {
    var total = 0.0, n = 0;
    for (var seed = 1; seed <= samples; seed++) {
      final run = Director.newRun(seed * 17, 'ashcaller', MetaState())
        ..act = act
        ..floor = floor
        ..totalFloors = floor;
      for (final f in Director(run).encounter(NodeType.battle)) {
        total += (f.hp + f.hpMax) / 2;
        n++;
      }
    }
    return total / n;
  }

  test('foes get heavier the deeper into an act you are', () {
    for (final act in [1, 2, 3]) {
      final early = weightAt(act, 1);
      final mid = weightAt(act, 7);
      final late = weightAt(act, 13);

      expect(mid, greaterThan(early),
          reason: 'act $act mid-act foes are not heavier than early ones');
      expect(late, greaterThan(mid),
          reason: 'act $act late foes are not heavier than mid ones');
      // The ramp has to be worth feeling, not statistical noise.
      expect(late / early, greaterThan(1.35),
          reason: 'act $act ramp is only ${(late / early).toStringAsFixed(2)}x');
      // ignore: avoid_print
      print('act $act  entry ${early.toStringAsFixed(1)}'
          ' -> mid ${mid.toStringAsFixed(1)}'
          ' -> door ${late.toStringAsFixed(1)}'
          '  (${(late / early).toStringAsFixed(2)}x)');
    }
  });

  test('the heaviest foes stay off the opening floors', () {
    final pool = normalPool(1);
    final heaviest = pool
        .map((e) => (e.hp + e.hpMax) / 2)
        .reduce((a, b) => a > b ? a : b);

    var seenHeavy = 0;
    for (var seed = 1; seed <= 300; seed++) {
      final run = Director.newRun(seed * 11, 'ashcaller', MetaState())..floor = 0;
      for (final f in Director(run).encounter(NodeType.battle)) {
        if ((f.hp + f.hpMax) / 2 >= heaviest * .9) seenHeavy++;
      }
    }
    // Not banned outright — the band overlaps on purpose — but rare.
    expect(seenHeavy / 300, lessThan(.10),
        reason: 'the heaviest Act I foes turn up on floor one too often');
  });

  test('the same foe is tougher at the boss door than at the entry', () {
    int hpAt(int floor) {
      final run = Director.newRun(99, 'ashcaller', MetaState())..floor = floor;
      final b = Battle(
        run: run,
        foeDefs: [enemyDef('kiln_golem')],
        rng: Rng(3),
        kind: 'normal',
      )..start();
      return b.foes.first.maxHp;
    }

    expect(hpAt(13), greaterThan(hpAt(0)));
  });

  test('no fight is guaranteed to leave a draught', () {
    double rate(String kind) {
      var got = 0;
      for (var seed = 1; seed <= 240; seed++) {
        final run = Director.newRun(seed * 13, 'ashcaller', MetaState())
          ..totalFloors = seed;
        if (Director(run).potionDrop(kind) != null) got++;
      }
      return got / 240;
    }

    final normal = rate('normal');
    final elite = rate('elite');
    final boss = rate('boss');
    // ignore: avoid_print
    print('draught drops — normal ${(normal * 100).round()}%'
        ' elite ${(elite * 100).round()}%'
        ' boss ${(boss * 100).round()}%');

    expect(normal, lessThan(.35), reason: 'ordinary fights are too generous');
    expect(elite, lessThan(.75), reason: 'elites still feel guaranteed');
    expect(boss, lessThan(.95), reason: 'bosses still feel guaranteed');
    // ...but the belt must still fill up over a run.
    expect(normal, greaterThan(.10));
    expect(boss, greaterThan(.50));
  });

  test('rare draughts cannot appear in Act I and stay scarce after', () {
    expect(potionWeight(Rarity.rare, 1), 0);
    expect(potionWeight(Rarity.rare, 2), greaterThan(0));

    double rareShare(int act) {
      final w = <Rarity, int>{
        for (final r in [Rarity.common, Rarity.uncommon, Rarity.rare])
          r: potionWeight(r, act)
      };
      final total = w.values.reduce((a, b) => a + b);
      return w[Rarity.rare]! / total;
    }

    expect(rareShare(1), 0);
    expect(rareShare(3), lessThan(.20),
        reason: 'rare draughts are not rare in Act III');
  });

  test('rare and mythic rewards are earned, not handed out', () {
    double share(Rarity target, int act, int Function(Rarity, int) w) {
      final all = [Rarity.common, Rarity.uncommon, Rarity.rare, Rarity.mythic];
      final total = all.fold(0, (s, r) => s + w(r, act));
      return w(target, act) / total;
    }

    int cardW(Rarity r, int a) => rarityWeight(r, a);
    int relicW(Rarity r, int a) =>
        relicWeight(RelicDef(id: 'x', name: 'x', desc: 'x', rarity: r,
            trigger: RelicTrigger.passive), a);

    for (final w in [cardW, relicW]) {
      // Nothing legendary in the first act at all.
      expect(w(Rarity.mythic, 1), 0);
      // Rares climb with depth rather than being flat.
      expect(w(Rarity.rare, 3), greaterThan(w(Rarity.rare, 1)));
      expect(share(Rarity.rare, 1, w), lessThan(.06),
          reason: 'rares are too common in Act I');
      expect(share(Rarity.rare, 3, w), lessThan(.18),
          reason: 'rares are too common in Act III');
      // Commons still carry the bulk of every offer.
      expect(share(Rarity.common, 1, w), greaterThan(.55));
    }
  });

  test('an act ends harder than it begins, end to end', () {
    // A blunt aggregate: total foe health you are asked to chew through on
    // the entry layer versus the layer before the boss.
    double totalAt(int floor) {
      var sum = 0.0;
      for (var seed = 1; seed <= 200; seed++) {
        final run = Director.newRun(seed * 23, 'ashcaller', MetaState())
          ..floor = floor
          ..totalFloors = floor;
        for (final f in Director(run).encounter(NodeType.battle)) {
          sum += (f.hp + f.hpMax) / 2 * (1 + .24 * (floor / 13).clamp(0, 1));
        }
      }
      return sum / 200;
    }

    final entry = totalAt(0);
    final door = totalAt(13);
    // ignore: avoid_print
    print('encounter load — entry ${entry.toStringAsFixed(1)}'
        ' -> door ${door.toStringAsFixed(1)}'
        '  (${(door / entry).toStringAsFixed(2)}x)');
    expect(door, greaterThan(entry * 2.2),
        reason: 'the act does not actually get harder');
  });

  test('most of the path a player walks is a fight', () {
    // Measured on the route actually taken, not the whole generated grid.
    // The old mix gave 4.6 battles against 5.1 rests, shops and caches — 42%
    // of a run was combat, so the deck being built barely got used.
    for (final act in [1, 2, 3]) {
      final tally = <NodeType, double>{};
      const runs = 300;
      for (var seed = 1; seed <= runs; seed++) {
        final m = generateMap(Rng(seed * 7), act);
        var id = m.available.first;
        for (var l = 0; l < m.layers; l++) {
          final n = m.byId(id);
          tally[n.type] = (tally[n.type] ?? 0) + 1;
          if (n.next.isEmpty) break;
          id = n.next[seed % n.next.length];
        }
      }
      final nodes = tally.values.fold(0.0, (a, b) => a + b) / runs;
      final fights = ((tally[NodeType.battle] ?? 0) +
              (tally[NodeType.elite] ?? 0) +
              (tally[NodeType.boss] ?? 0)) /
          runs;
      final quiet = ((tally[NodeType.rest] ?? 0) +
              (tally[NodeType.shop] ?? 0) +
              (tally[NodeType.treasure] ?? 0)) /
          runs;

      // ignore: avoid_print
      print('act $act  ${nodes.toStringAsFixed(1)} nodes'
          '  fights ${fights.toStringAsFixed(1)}'
          ' (${(fights / nodes * 100).round()}%)'
          '  quiet ${quiet.toStringAsFixed(1)}'
          '  battles ${((tally[NodeType.battle] ?? 0) / runs).toStringAsFixed(1)}');

      expect(fights / nodes, greaterThan(.50),
          reason: 'act $act is mostly not fighting');
      expect(fights, greaterThan(7.0),
          reason: 'act $act has too few fights to build a deck around');
      expect(quiet, lessThan(4.5),
          reason: 'act $act has too many rest/shop/cache stops');
      // ...but it must not become nothing but combat either.
      expect(fights / nodes, lessThan(.70), reason: 'act $act has no breathing room');
    }
  });

  test('each act is a real step up from the last', () {
    final a1 = weightAt(1, 13);
    final a2 = weightAt(2, 0);
    final a3 = weightAt(3, 0);
    // ignore: avoid_print
    print('act boundaries — I door ${a1.toStringAsFixed(1)}'
        ' | II entry ${a2.toStringAsFixed(1)}'
        ' | III entry ${a3.toStringAsFixed(1)}');
    expect(a2, greaterThan(a1), reason: 'Act II opens softer than Act I ends');
    expect(a3, greaterThan(a2 * 1.4), reason: 'Act III is not a step up');
  });
}
