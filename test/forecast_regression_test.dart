import 'package:aeonfall/data/cards.dart';
import 'package:aeonfall/data/enemies.dart';
import 'package:aeonfall/engine/battle.dart';
import 'package:aeonfall/engine/core.dart';
import 'package:aeonfall/engine/director.dart';
import 'package:aeonfall/engine/rng.dart';
import 'package:aeonfall/engine/run_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Battle fight({int asc = 0}) {
    final run = Director.newRun(
      1234,
      'ashcaller',
      MetaState()..ascension = asc,
    );
    run.relics.clear();
    final b = Battle(
      run: run,
      foeDefs: [enemyDef('cinder_wretch')],
      rng: Rng(7),
      kind: 'normal',
    )..start();
    b.hand.clear();
    b.hero.st.clear();
    b.hero.block = 0;
    b.foes.first.st.clear();
    b.foes.first.intent = const Intent(IntentKind.attack, value: 7);
    return b;
  }

  int act(Battle b) {
    final before = b.hero.hp;
    b.endPlayerTurn();
    while (b.stepFoes()) {}
    return before - b.hero.hp;
  }

  test('Ascension 9 includes scaled and rounded damage in intent', () {
    final b = fight(asc: 9);
    expect(b.incomingFrom(b.foes.first), 8);
    expect(b.intentInfos().single.perHit, 8);
    expect(act(b), 8);
  });

  for (final fixture in [(1, 0, 20), (1, 7, 13), (2, 7, 3), (3, 7, 0)]) {
    test('Ward ${fixture.$1} and Guard ${fixture.$2} resolve per hit', () {
      final b = fight();
      b.foes.first.intent = const Intent(
        IntentKind.attackMulti,
        value: 10,
        times: 3,
      );
      b.hero.add('ward', fixture.$1);
      b.hero.block = fixture.$2;
      expect(b.incomingAfterGuard, fixture.$3);
      expect(act(b), fixture.$3);
    });
  }

  test('Ward is shared across foes, not reapplied to each foe', () {
    final b = fight();
    final second = Combatant.foe(enemyDef('cinder_wretch'), 100, 100, const [])
      ..intent = const Intent(IntentKind.attack, value: 10);
    b.foes.first.intent = const Intent(IntentKind.attack, value: 10);
    b.foes.add(second);
    b.hero.add('ward', 1);
    b.hero.block = 5;
    expect(b.incomingAfterGuard, 5);
    expect(act(b), 5);
  });

  test('Stealth stops attacks without spending real forecast state', () {
    final b = fight();
    b.hero.add('stealth', 1);
    b.hero.block = 4;
    expect(b.incomingAfterGuard, 0);
    expect(b.hero.block, 4);
    expect(b.hero.s('stealth'), 1);
    expect(act(b), 0);
  });

  test('AOE intent is included in incoming damage', () {
    final b = fight(asc: 9);
    b.foes.first.intent = const Intent(IntentKind.aoe, value: 7);
    expect(b.incomingTotal, 8);
    expect(b.incomingAfterGuard, 8);
    expect(act(b), 8);
  });

  test('Strength, Weak and Ascension use the same rounding as execution', () {
    final b = fight(asc: 9);
    b.foes.first.add('strength', 3);
    b.foes.first.add('weak', 2);
    // Raw 7 -> 8, +3 Strength -> 11, Weak -> 8.25 -> 8.
    expect(b.incomingFrom(b.foes.first), 8);
    expect(act(b), 8);
  });

  test(
    'Waning scales raw damage before Strength and rounds before Ascension',
    () {
      final b = fight(asc: 9);
      b.foes[0] =
          Combatant.foe(enemyDef('cinder_wretch'), 100, 100, const ['waning'])
            ..intent = const Intent(IntentKind.attack, value: 7)
            ..add('strength', 2)
            ..add('weak', 2);
      b.hero.add('vulnerable', 2);
      // 7*1.5 -> 11; 11*1.1 -> 12; (12+2)*.75*1.4 -> 15.
      expect(b.incomingFrom(b.foes.first), 15);
      expect(act(b), 15);
    },
  );

  test('Momentum is consumed only by the first hit of a foe', () {
    final b = fight();
    b.foes.first.intent = const Intent(
      IntentKind.attackMulti,
      value: 10,
      times: 2,
    );
    b.foes.first.add('momentum', 2);
    expect(b.incomingFrom(b.foes.first), 24); // 14 + 10
    expect(b.incomingAfterGuard, 24);
    expect(b.foes.first.s('momentum'), 2);
    expect(act(b), 24);
  });

  test('Reading a forecast never consumes Ward, Guard or battle RNG', () {
    final b = fight();
    b.foes.first.intent = const Intent(
      IntentKind.attackMulti,
      value: 10,
      times: 3,
    );
    b.hero.add('ward', 1);
    b.hero.block = 7;
    final control = fight();
    expect(b.incomingAfterGuard, 13);
    expect(b.incomingAfterGuard, 13);
    expect(b.hero.s('ward'), 1);
    expect(b.hero.block, 7);
    expect(b.rng.nextInt(1000000), control.rng.nextInt(1000000));
  });

  test('Footnote counts only the two other frames in the hand', () {
    final b = fight();
    final f = b.foes.first;
    f.aura = Elem.none;
    f.block = 0;
    f.hp = f.maxHp = 1000;
    final c = CardInst(cardDef('px_footnote'));
    b.hand = [c, CardInst(cardDef('ae_guard')), CardInst(cardDef('ae_guard'))];
    expect(b.previewDamage(c, f), 10);
    expect(b.hand.length, 3);
    final before = f.hp;
    b.play(c, 0);
    expect(before - f.hp, 10);
  });
}
