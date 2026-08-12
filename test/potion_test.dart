import 'package:aeonfall/data/potions.dart';
import 'package:aeonfall/data/enemies.dart';
import 'package:aeonfall/engine/battle.dart';
import 'package:aeonfall/engine/core.dart';
import 'package:aeonfall/engine/director.dart';
import 'package:aeonfall/engine/rng.dart';
import 'package:aeonfall/engine/run_state.dart';
import 'package:flutter_test/flutter_test.dart';

Battle _fight(RunState run, List<String> foes) => Battle(
      run: run,
      foeDefs: foes.map(enemyDef).toList(),
      rng: Rng(11),
      kind: 'normal',
    )..start();

void main() {
  test('every draught is well formed', () {
    final ids = kPotions.map((p) => p.id).toList();
    expect(ids.length, ids.toSet().length, reason: 'duplicate draught id');

    for (final p in kPotions) {
      expect(p.fx, isNotEmpty, reason: '${p.id} does nothing');
      expect(p.desc.length, greaterThan(10), reason: '${p.id} has no description');
      for (final fx in p.fx) {
        // Draughts must never need a target picker — drinking one is a single
        // tap, so nothing may resolve against FxTarget.enemy.
        expect(fx.target, isNot(FxTarget.enemy),
            reason: '${p.id} would need the player to choose a target');
        if (fx.arg != null && (fx.kind == FxKind.status ||
            fx.kind == FxKind.selfStatus ||
            fx.kind == FxKind.statusAll)) {
          expect(kStatus.containsKey(fx.arg), isTrue,
              reason: '${p.id} applies unknown condition ${fx.arg}');
        }
      }
    }
  });

  test('the belt holds three, four with the Deep Satchel', () {
    final run = Director.newRun(5, 'ashcaller', MetaState());
    expect(run.potionSlots, 3);
    expect(run.addPotion('stillwater'), isTrue);
    expect(run.addPotion('torndraft'), isTrue);
    expect(run.addPotion('quickink'), isTrue);
    expect(run.beltFull, isTrue);
    expect(run.addPotion('ashflask'), isFalse, reason: 'belt overflowed');

    run.addRelic('deep_satchel');
    expect(run.potionSlots, 4);
    expect(run.addPotion('ashflask'), isTrue);
  });

  test('drinking removes it from the belt and does something', () {
    final run = Director.newRun(7, 'ashcaller', MetaState());
    run.addPotion('ashflask');
    final b = _fight(run, ['cinder_wretch', 'ash_hound']);
    final before = b.foes.map((f) => f.hp).toList();

    expect(b.usePotion('ashflask'), isTrue);
    expect(run.potions, isEmpty, reason: 'the draught was not consumed');
    for (var i = 0; i < b.foes.length; i++) {
      expect(b.foes[i].hp, lessThan(before[i]), reason: 'foe $i took nothing');
      expect(b.foes[i].s('burn'), greaterThan(0), reason: 'foe $i is not burning');
    }
  });

  test('a draught costs no Aether and does not break a Cinematic', () {
    final run = Director.newRun(9, 'ashcaller', MetaState());
    run.addPotion('quickink');
    final b = _fight(run, ['emberling']);
    final energy = b.energy;
    final played = b.playedThisTurn;
    final elems = b.elemsThisTurn.length;

    b.usePotion('quickink');
    expect(b.energy, energy + 2, reason: 'Quick Ink did not add Aether');
    expect(b.playedThisTurn, played, reason: 'drinking counted as a frame');
    expect(b.elemsThisTurn.length, elems,
        reason: 'drinking polluted the Cinematic meter');
  });

  test('you cannot drink one you do not have', () {
    final run = Director.newRun(3, 'ashcaller', MetaState());
    final b = _fight(run, ['emberling']);
    expect(b.usePotion('laststroke'), isFalse);
  });

  test('draughts survive a save and reload', () {
    final run = Director.newRun(13, 'saintcoralis', MetaState())
      ..addPotion('secondwind')
      ..addPotion('coldiron');
    final back = RunState.fromJson(run.toJson());
    expect(back.potions, ['secondwind', 'coldiron']);
  });

  test('elites and bosses always leave one behind', () {
    final run = Director.newRun(21, 'voltborn', MetaState());
    final d = Director(run);
    expect(d.potionDrop('elite'), isNotNull);
    expect(d.potionDrop('boss'), isNotNull);
  });
}
