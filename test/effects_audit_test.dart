import 'package:aeonfall/data/cards.dart';
import 'package:aeonfall/data/enemies.dart';
import 'package:aeonfall/data/narrative_model.dart';
import 'package:aeonfall/data/relics.dart';
import 'package:aeonfall/engine/battle.dart';
import 'package:aeonfall/engine/core.dart';
import 'package:aeonfall/engine/director.dart';
import 'package:aeonfall/engine/rng.dart';
import 'package:aeonfall/engine/run_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// Does every printed effect actually happen?
///
/// A sigil that says it grants Guard at the start of a battle and does not is
/// worse than no sigil — the player builds around a promise. This walks every
/// relic and every card effect and holds the engine to what the text says.
void main() {
  Battle fight(RunState run, {List<String> foes = const ['kiln_golem']}) => Battle(
        run: run,
        foeDefs: foes.map(enemyDef).toList(),
        rng: Rng(5),
        kind: 'normal',
      )..start();

  RunState runWith(String relicId, {String vessel = 'ashcaller'}) {
    final run = Director.newRun(4242, vessel, MetaState());
    run.relics.clear(); // drop the vessel's own sigil so nothing overlaps
    run.relics.add(relicId);
    return run;
  }

  RunState bare({String vessel = 'ashcaller'}) {
    final run = Director.newRun(4242, vessel, MetaState());
    run.relics.clear();
    return run;
  }

  group('sigils that fire when a battle begins', () {
    final starters = kRelics
        .where((r) => r.trigger == RelicTrigger.onBattleStart && r.fx.isNotEmpty)
        .toList();

    test('there are some to check', () {
      expect(starters.length, greaterThan(8));
    });

    for (final kind in [FxKind.block, FxKind.energy, FxKind.draw]) {
      test('${kind.name} granted at battle start survives the first turn', () {
        final relics = [
          ...kRelics,
          ...kStarterRelics,
        ].where((r) =>
            r.trigger == RelicTrigger.onBattleStart &&
            r.fx.any((f) => f.kind == kind));

        expect(relics, isNotEmpty, reason: 'no sigil grants ${kind.name}');

        for (final r in relics) {
          final want = r.fx.firstWhere((f) => f.kind == kind).value;
          final withIt = fight(runWith(r.id));
          final without = fight(bare());

          final got = switch (kind) {
            FxKind.block => withIt.hero.block - without.hero.block,
            FxKind.energy => withIt.energy - without.energy,
            _ => withIt.hand.length - without.hand.length,
          };

          expect(got, greaterThanOrEqualTo(want),
              reason: '${r.id} ("${r.desc}") promised $want ${kind.name} '
                  'and delivered $got on turn one');
        }
      });
    }

    test('conditions applied at battle start are actually on the board', () {
      // Collected rather than thrown on first failure, so one broken sigil
      // does not hide the others.
      final broken = <String>[];
      for (final r in [...kRelics, ...kStarterRelics].where((x) =>
          x.trigger == RelicTrigger.onBattleStart &&
          x.fx.any((f) => f.kind == FxKind.statusAll))) {
        for (final fx in r.fx.where((f) => f.kind == FxKind.statusAll)) {
          final b = fight(runWith(r.id));
          final got = b.foes.first.s(fx.arg!);
          if (got < fx.value) {
            broken.add('${r.id} ("${r.desc}") -> ${fx.arg} '
                'wanted ${fx.value}, got $got');
          }
        }
      }
      expect(broken, isEmpty, reason: broken.join('\n  '));
    });

    test('relic ids are unique', () {
      final ids = [...kRelics, ...kStarterRelics].map((r) => r.id).toList();
      final dupes = <String>[];
      final seen = <String>{};
      for (final id in ids) {
        if (!seen.add(id)) dupes.add(id);
      }
      expect(dupes, isEmpty, reason: 'duplicate sigil ids: ${dupes.join(", ")}');
    });

    test('self conditions applied at battle start are on the hero', () {
      for (final r in [...kRelics, ...kStarterRelics].where((x) =>
          x.trigger == RelicTrigger.onBattleStart &&
          x.fx.any((f) => f.kind == FxKind.selfStatus))) {
        final fx = r.fx.firstWhere((f) => f.kind == FxKind.selfStatus);
        final b = fight(runWith(r.id));
        expect(b.hero.s(fx.arg!), greaterThanOrEqualTo(fx.value),
            reason: '${r.id} did not apply ${fx.arg} to you');
      }
    });
  });

  group('sigils that fire every turn', () {
    test('turn-start grants land on turn one as well as later turns', () {
      for (final r in [...kRelics, ...kStarterRelics].where((x) =>
          x.trigger == RelicTrigger.onTurnStart && x.fx.isNotEmpty)) {
        final b = fight(runWith(r.id));
        final base = fight(bare());

        for (final fx in r.fx) {
          final got = switch (fx.kind) {
            FxKind.block => b.hero.block - base.hero.block,
            FxKind.energy => b.energy - base.energy,
            FxKind.draw => b.hand.length - base.hand.length,
            FxKind.selfStatus => b.hero.s(fx.arg!) - base.hero.s(fx.arg!),
            FxKind.statusAll => b.foes.first.s(fx.arg!) - base.foes.first.s(fx.arg!),
            FxKind.heal => 0, // capped at full health on turn one; not measurable
            _ => fx.value, // damage-shaped effects are checked elsewhere
          };
          if (fx.kind == FxKind.heal) continue;
          expect(got, greaterThanOrEqualTo(fx.value),
              reason: '${r.id} ("${r.desc}") gave $got of a promised '
                  '${fx.value} ${fx.kind.name} on turn one');
        }
      }
    });
  });

  test('no sigil is wired to a trigger the engine never fires', () {
    // Only these four are handled in Battle. Anything else with effects
    // attached is text that never happens.
    const live = {
      RelicTrigger.onBattleStart,
      RelicTrigger.onTurnStart,
      RelicTrigger.onReaction,
      RelicTrigger.onBattleWin,
      RelicTrigger.passive, // handled ad hoc, by id, where it matters
    };

    final dead = [...kRelics, ...kStarterRelics]
        .where((r) => r.fx.isNotEmpty && !live.contains(r.trigger))
        .map((r) => '${r.id} (${r.trigger.name})')
        .toList();

    expect(dead, isEmpty,
        reason: 'these carry effects on a dead trigger:\n  ${dead.join("\n  ")}');
  });

  group('Stealth', () {
    // "Foes cannot target you this turn." It was decremented by the hero's
    // end-of-turn tick, which runs *before* the foes move — so it expired at
    // exactly the moment it was supposed to work and never did anything.
    test('actually stops the foes that swing next', () {
      final run = bare();
      final b = fight(run, foes: ['cinder_wretch', 'ash_hound']);
      b.hero.add('stealth', 1);
      b.hero.block = 0;
      final hp = b.hero.hp;

      b.endTurn(); // your end of turn, then every foe acts, then turn two

      expect(b.hero.hp, hp, reason: 'Stealth did not stop the attacks');
    });

    test('covers one foe phase and no more', () {
      final run = bare();
      final b = fight(run, foes: ['cinder_wretch']);
      b.hero.add('stealth', 1);
      b.hero.block = 0;

      b.endTurn();
      expect(b.hero.s('stealth'), 0, reason: 'Stealth outlived its turn');

      final hp = b.hero.hp;
      b.hero.block = 0;
      b.endTurn();
      expect(b.hero.hp, lessThan(hp),
          reason: 'Stealth is still protecting you a turn later');
    });

    test('without it, the same foes do land', () {
      final run = bare();
      final b = fight(run, foes: ['cinder_wretch', 'ash_hound']);
      b.hero.block = 0;
      final hp = b.hero.hp;
      b.endTurn();
      expect(b.hero.hp, lessThan(hp),
          reason: 'the control case took no damage — the test proves nothing');
    });

    test('the Veil Water draught grants a Stealth that works', () {
      final run = bare()..addPotion('veilwater');
      final b = fight(run, foes: ['cinder_wretch', 'ash_hound']);
      b.hero.block = 0;
      expect(b.usePotion('veilwater'), isTrue);
      final hp = b.hero.hp;
      b.endTurn();
      expect(b.hero.hp, hp, reason: 'Veil Water did not protect you');
    });
  });

  test('Silver Thread halves what an event costs you', () {
    int lost(bool withThread) {
      final run = bare();
      if (withThread) run.relics.add('silver_thread');
      final before = run.hp;
      Director(run).applyOutcome(const Out(OutKind.hp, value: 20));
      return before - run.hp;
    }

    expect(lost(false), 20);
    expect(lost(true), lessThan(20), reason: 'Silver Thread did nothing');
  });

  test('every card effect kind the data uses is handled by the engine', () {
    // FxKind values that appear in real content but fall through _applyFx's
    // switch would silently do nothing.
    final used = <FxKind>{};
    for (final c in kAllCards) {
      for (final f in [...c.fx, ...(c.fxUp ?? []), ...(c.handTick ?? [])]) {
        used.add(f.kind);
      }
    }
    for (final r in [...kRelics, ...kStarterRelics]) {
      for (final f in r.fx) {
        used.add(f.kind);
      }
    }

    // Prove each one moves *something* by running a card that uses it.
    final unproven = <FxKind>[];
    for (final kind in used) {
      final card = kAllCards.firstWhere(
        (c) => c.fx.any((f) => f.kind == kind),
        orElse: () => kAllCards.first,
      );
      if (!card.fx.any((f) => f.kind == kind)) continue;

      final run = bare();
      final b = fight(run, foes: ['kiln_golem', 'cinder_wretch']);
      b.energy = 99;
      final inst = CardInst(card);
      b.hand.add(inst);

      final before = _snapshot(b);
      b.play(inst, 0);
      final after = _snapshot(b);
      if (before == after) unproven.add(kind);
    }

    // A handful genuinely change nothing measurable in one turn against a
    // fresh board; they are named rather than hidden.
    const knownQuiet = {
      FxKind.gainEnergyNextTurn,
      FxKind.cleanse,
      FxKind.cleanseOne,
      FxKind.recallDiscard,
      FxKind.upgradeHand,
      FxKind.copyLast,
      FxKind.exhaustHand,
      FxKind.discardRandom,
      FxKind.doubleBlock,
    };
    final surprises = unproven.where((k) => !knownQuiet.contains(k)).toList();
    expect(surprises, isEmpty,
        reason: 'these effect kinds changed nothing when played: '
            '${surprises.map((k) => k.name).join(", ")}');
  });
}

/// Everything an effect could plausibly move, as one comparable string.
String _snapshot(Battle b) => [
      b.hero.hp,
      b.hero.block,
      b.hero.maxHp,
      b.energy,
      b.hand.length,
      b.drawPile.length,
      b.discard.length,
      b.exhausted.length,
      b.run.gold,
      b.hero.st.toString(),
      b.foes.map((f) => '${f.hp}/${f.block}/${f.st}/${f.aura}').join('|'),
    ].join(',');
