import 'package:aeonfall/data/companion_aid.dart';
import 'package:aeonfall/data/companions.dart';
import 'package:aeonfall/data/enemies.dart';
import 'package:aeonfall/engine/battle.dart';
import 'package:aeonfall/engine/core.dart';
import 'package:aeonfall/engine/director.dart';
import 'package:aeonfall/engine/rng.dart';
import 'package:aeonfall/engine/run_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// Companions used to grant a perk on recruit and then never appear again
/// until the epilogue. These check that calling on one in a fight actually
/// does something, once, and only for companions who are with you.
void main() {
  Battle fight(RunState run, [List<String> foes = const ['cinder_wretch']]) => Battle(
        run: run,
        foeDefs: foes.map(enemyDef).toList(),
        rng: Rng(6),
        kind: 'normal',
      )..start();

  test('every companion has an Aid, and every Aid is well formed', () {
    for (final c in kCompanions) {
      final aid = aidFor(c.id);
      expect(aid, isNotNull, reason: '${c.id} has no Aid');
      expect(aid!.fx, isNotEmpty, reason: '${c.id} Aid does nothing');
      expect(aid.desc.length, greaterThan(10));
      expect(aid.line, isNotEmpty);
      for (final fx in aid.fx) {
        // Same rule as draughts: calling on somebody is one tap, never a
        // target picker.
        expect(fx.target, isNot(FxTarget.enemy),
            reason: '${c.id} Aid would need a target chosen');
        if (fx.arg != null &&
            (fx.kind == FxKind.selfStatus ||
                fx.kind == FxKind.status ||
                fx.kind == FxKind.statusAll)) {
          expect(kStatus.containsKey(fx.arg), isTrue,
              reason: '${c.id} applies unknown condition ${fx.arg}');
        }
      }
    }
  });

  test('you can only call on somebody who is actually with you', () {
    final run = Director.newRun(3, 'ashcaller', MetaState());
    final b = fight(run);
    expect(b.aidAvailable('brann'), isFalse);
    expect(b.useAid('brann'), isFalse);

    run.companions.add('brann');
    expect(b.aidAvailable('brann'), isTrue);
  });

  test('an Aid fires once and then is spent for the rest of the fight', () {
    final run = Director.newRun(4, 'ashcaller', MetaState())..companions.add('brann');
    final b = fight(run);
    b.hero.block = 0;

    expect(b.useAid('brann'), isTrue);
    expect(b.hero.block, greaterThanOrEqualTo(20), reason: 'Hold the Line did nothing');
    expect(b.hero.s('fortify'), greaterThan(0));

    expect(b.aidAvailable('brann'), isFalse);
    expect(b.useAid('brann'), isFalse, reason: 'the Aid fired twice');
  });

  test('it costs no Aether and is not a played frame', () {
    final run = Director.newRun(5, 'ashcaller', MetaState())..companions.add('vessa');
    final b = fight(run);
    final energy = b.energy;
    final played = b.playedThisTurn;
    final elems = b.elemsThisTurn.length;

    b.useAid('vessa');
    expect(b.energy, energy);
    expect(b.playedThisTurn, played);
    expect(b.elemsThisTurn.length, elems,
        reason: 'an Aid polluted the Cinematic meter');
  });

  test('a damaging Aid reaches every foe', () {
    final run = Director.newRun(6, 'ashcaller', MetaState())..companions.add('harrow');
    final b = fight(run, ['cinder_wretch', 'ash_hound', 'soot_moth']);
    for (final f in b.foes) {
      f.block = 40; // Harrow ignores Guard
    }
    final before = b.foes.map((f) => f.hp).toList();

    b.useAid('harrow');
    for (var i = 0; i < b.foes.length; i++) {
      expect(b.foes[i].hp, lessThan(before[i]), reason: 'foe $i untouched');
    }
  });

  test('a companion who has already turned on you does not answer', () {
    final run = Director.newRun(7, 'ashcaller', MetaState())
      ..companions.add('brann')
      ..betrayerId = 'brann'
      ..betrayalActed = 2;
    final b = fight(run);
    expect(b.aidAvailable('brann'), isFalse);
  });

  test('a fresh battle gives the Aid back', () {
    final run = Director.newRun(8, 'ashcaller', MetaState())..companions.add('tock');
    final first = fight(run);
    first.useAid('tock');
    expect(first.aidAvailable('tock'), isFalse);

    final second = fight(run);
    expect(second.aidAvailable('tock'), isTrue,
        reason: 'Aids must reset between fights');
  });
}
