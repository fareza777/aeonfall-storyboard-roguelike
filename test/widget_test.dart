import 'package:aeonfall/data/cards.dart';
import 'package:aeonfall/data/enemies.dart';
import 'package:aeonfall/data/endings.dart';
import 'package:aeonfall/data/events.dart';
import 'package:aeonfall/data/vessels.dart';
import 'package:aeonfall/engine/core.dart';
import 'package:aeonfall/engine/map_gen.dart';
import 'package:aeonfall/engine/rng.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every starter deck references a real card', () {
    for (final v in kVessels) {
      for (final id in v.deck.keys) {
        expect(kCardById.containsKey(id), isTrue, reason: '${v.id} -> $id');
      }
    }
  });

  test('card ids are unique', () {
    final ids = kAllCards.map((c) => c.id).toList();
    expect(ids.length, ids.toSet().length);
  });

  test('every elemental pair produces a reaction', () {
    const elems = [Elem.ember, Elem.frost, Elem.volt, Elem.umbra, Elem.lumen];
    for (var i = 0; i < elems.length; i++) {
      for (var j = i + 1; j < elems.length; j++) {
        final r = reactionFor(elems[i], elems[j]);
        expect(r, isNotNull);
        expect(kReactions.containsKey(r), isTrue);
      }
    }
  });

  test('maps always connect the entry layer to the boss', () {
    for (var seed = 1; seed < 60; seed++) {
      for (var act = 1; act <= 3; act++) {
        final map = generateMap(Rng(seed), act);
        final boss = map.nodes.where((n) => n.type == NodeType.boss);
        expect(boss.length, 1, reason: 'seed $seed act $act');

        final seen = <int>{};
        final queue = <int>[...map.available];
        while (queue.isNotEmpty) {
          final id = queue.removeLast();
          if (!seen.add(id)) continue;
          queue.addAll(map.byId(id).next);
        }
        expect(seen.contains(boss.first.id), isTrue,
            reason: 'boss unreachable on seed $seed act $act');
      }
    }
  });

  test('enemy and ending ids are unique', () {
    final e = kAllEnemies.map((x) => x.id).toList();
    expect(e.length, e.toSet().length);
    final n = kEndings.map((x) => x.id).toList();
    expect(n.length, n.toSet().length);
  });

  test('event choices reference real cards and relics', () {
    for (final ev in kAllEvents) {
      expect(ev.choices, isNotEmpty, reason: ev.id);
      for (final c in ev.choices) {
        for (final o in c.out) {
          if (o.arg != null && o.kind.name == 'card') {
            expect(kCardById.containsKey(o.arg), isTrue, reason: '${ev.id}/${o.arg}');
          }
        }
      }
    }
  });
}
