import 'package:aeonfall/data/ascension.dart';
import 'package:aeonfall/data/enemies.dart';
import 'package:aeonfall/engine/battle.dart';
import 'package:aeonfall/engine/core.dart';
import 'package:aeonfall/engine/director.dart';
import 'package:aeonfall/engine/map_gen.dart';
import 'package:aeonfall/engine/rng.dart';
import 'package:aeonfall/engine/run_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ascension used to be one line — enemy HP times six percent per level — so
/// every tier was the same run with bigger numbers. These check that each rule
/// actually reaches the thing it claims to change.
void main() {
  MetaState metaAt(int n) => MetaState()..ascension = n;

  Battle fightAt(int asc, List<String> foes, {String kind = 'normal'}) {
    final run = Director.newRun(1234, 'ashcaller', metaAt(asc));
    return Battle(
      run: run,
      foeDefs: foes.map(enemyDef).toList(),
      rng: Rng(9),
      kind: kind,
    )..start();
  }

  test('all twenty tiers are described', () {
    expect(kAscensions.length, 20);
    for (var i = 0; i < 20; i++) {
      expect(kAscensions[i].level, i + 1);
      expect(kAscensions[i].title, isNotEmpty);
      expect(kAscensions[i].desc.length, greaterThan(20),
          reason: 'tier ${i + 1} does not explain itself');
    }
    expect(AscensionRules(20).active.length, 20);
    expect(AscensionRules(0).active, isEmpty);
  });

  test('1, 5 and 15 stack onto foe health', () {
    int hp(int asc) => fightAt(asc, ['kiln_golem']).foes.first.maxHp;
    expect(hp(1), greaterThan(hp(0)));
    expect(hp(5), greaterThan(hp(1)));
    expect(hp(15), greaterThan(hp(5)));
  });

  test('2 puts elites on earlier layers and more of them', () {
    int elites(int asc) {
      var n = 0;
      for (var seed = 1; seed <= 40; seed++) {
        final m = generateMap(Rng(seed), 2, ascension: asc);
        n += m.nodes.where((x) => x.type == NodeType.elite).length;
      }
      return n;
    }

    expect(elites(2), greaterThan(elites(0)));
  });

  test('4 starts you carrying a Curse', () {
    final clean = Director.newRun(5, 'ashcaller', metaAt(3));
    final cursed = Director.newRun(5, 'ashcaller', metaAt(4));
    expect(clean.deck.where((c) => c.def.type == CardType.curse), isEmpty);
    expect(cursed.deck.where((c) => c.def.type == CardType.curse), isNotEmpty);
  });

  test('6 shaves every Guard you gain', () {
    int guard(int asc) {
      final b = fightAt(asc, ['emberling']);
      b.hero.block = 0;
      b.energy = 99;
      final card = CardInst(b.run.deck.firstWhere((c) => c.def.id == 'ae_guard').def);
      b.hand.add(card);
      b.play(card, 0);
      return b.hero.block;
    }

    expect(guard(6), lessThan(guard(5)));
  });

  test('8 puts a boss back on its feet exactly once', () {
    // Killed through the real damage path, twice, so the revive is exercised
    // rather than asserted.
    Battle setUp(int asc) {
      final run = Director.newRun(77, 'ashcaller', metaAt(asc))
        ..addPotion('laststroke')
        ..addPotion('laststroke');
      return Battle(
        run: run,
        foeDefs: [enemyDef('aeonfall')],
        rng: Rng(9),
        kind: 'boss',
      )..start();
    }

    final b = setUp(8);
    final boss = b.foes.first;
    boss.hp = 5;
    b.usePotion('laststroke');
    expect(boss.phaseTwo, isTrue, reason: 'the boss did not get up');
    expect(boss.hp, greaterThan(0));
    expect(b.ended, isFalse, reason: 'the fight ended on a death that was undone');

    // Second time it stays down.
    boss.hp = 5;
    b.usePotion('laststroke');
    expect(boss.alive, isFalse, reason: 'the boss got up twice');

    // Below Ascension 8 the first death is the only one.
    final low = setUp(7);
    low.foes.first.hp = 5;
    low.usePotion('laststroke');
    expect(low.foes.first.alive, isFalse);
  });

  test('10 makes a Cinematic need a fourth frame', () {
    expect(AscensionRules(9).cinematicFrames, 3);
    expect(AscensionRules(10).cinematicFrames, 4);
    expect(fightAt(10, ['emberling']).asc.cinematicFrames, 4);
  });

  test('11 costs you starting health', () {
    final a = Director.newRun(8, 'ashcaller', metaAt(10));
    final b = Director.newRun(8, 'ashcaller', metaAt(11));
    expect(b.maxHp, a.maxHp - 12);
    expect(b.hp, b.maxHp);
  });

  test('12 guarantees every elite arrives mutated', () {
    for (var seed = 1; seed <= 12; seed++) {
      final run = Director.newRun(seed * 7, 'ashcaller', metaAt(12));
      final b = Battle(
        run: run,
        foeDefs: [enemyDef('the_understudy')],
        rng: Rng(seed),
        kind: 'elite',
      )..start();
      expect(b.foes.first.mods, isNotEmpty, reason: 'unmutated elite on seed $seed');
    }
  });

  test('13 deals you a smaller opening hand', () {
    expect(fightAt(13, ['emberling']).hand.length,
        lessThan(fightAt(12, ['emberling']).hand.length));
  });

  test('16 opens every act with an elite', () {
    final m = generateMap(Rng(3), 1, ascension: 16);
    final first = m.nodes.where((n) => n.layer == 0);
    expect(first, isNotEmpty);
    expect(first.every((n) => n.type == NodeType.elite), isTrue);
  });

  test('19 narrows the card reward', () {
    final a = Director(Director.newRun(2, 'ashcaller', metaAt(18)));
    final b = Director(Director.newRun(2, 'ashcaller', metaAt(19)));
    expect(b.cardReward().length, lessThan(a.cardReward().length));
  });

  test('7 marks the market up and 17 thins your purse', () {
    final plain = Director(Director.newRun(4, 'ashcaller', metaAt(6)));
    final marked = Director(Director.newRun(4, 'ashcaller', metaAt(7)));
    final p = plain.potionStock().first;
    expect(marked.potionPrice(p), greaterThan(plain.potionPrice(p)));

    expect(AscensionRules(17).goldGain, lessThan(1.0));
    expect(AscensionRules(16).goldGain, 1.0);
  });

  test('14 halves how often draughts turn up', () {
    expect(AscensionRules(14).potionDropRate, lessThan(1.0));
    // Elites and bosses still always drop one — the guarantee is the floor.
    final d = Director(Director.newRun(6, 'ashcaller', metaAt(14)));
    expect(d.potionDrop('elite'), isNotNull);
  });

  test('a full-Ascension run is meaningfully harder than a fresh one', () {
    final easy = fightAt(0, ['aeonfall'], kind: 'boss');
    final hard = fightAt(20, ['aeonfall'], kind: 'boss');
    expect(hard.foes.first.maxHp, greaterThan(easy.foes.first.maxHp));
    expect(hard.hand.length, lessThan(easy.hand.length));
    expect(hard.run.maxHp, lessThan(easy.run.maxHp));
    expect(hard.asc.cinematicFrames, greaterThan(easy.asc.cinematicFrames));
  });
}
