import 'package:aeonfall/data/cards.dart';
import 'package:aeonfall/data/enemies.dart';
import 'package:aeonfall/engine/battle.dart';
import 'package:aeonfall/engine/core.dart';
import 'package:aeonfall/engine/director.dart';
import 'package:aeonfall/engine/rng.dart';
import 'package:aeonfall/engine/run_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// The forecast printed on a foe is a promise. If it ever disagrees with what
/// the swing actually does, the readout is worse than having no readout — so
/// this plays the frame for real and holds the two numbers against each other.
void main() {
  Battle fight(RunState run, List<String> foes, {int seed = 4}) => Battle(
        run: run,
        foeDefs: foes.map(enemyDef).toList(),
        rng: Rng(seed),
        kind: 'normal',
      )..start();

  test('the forecast equals the damage actually dealt', () {
    // Frames whose damage is fully determined at the moment of the tap.
    // Anything random or turn-dependent is deliberately outside the promise,
    // so it is outside this check too.
    const settled = {
      FxKind.damage,
      FxKind.damageAll,
      FxKind.pierce,
      FxKind.block,
      FxKind.draw,
      FxKind.energy,
      FxKind.status,
      FxKind.statusAll,
      FxKind.selfStatus,
      // aura / auraAll are excluded on purpose: a frame that paints an element
      // onto a foe and then hits it sets off its own Reaction, which the
      // forecast flags rather than folds in.
      FxKind.heal,
      FxKind.gainGold,
    };
    final attacks = kAllCards.where((c) {
      if (c.type != CardType.attack || c.fx.isEmpty) return false;
      if (!c.fx.any((f) => f.kind == FxKind.damage || f.kind == FxKind.damageAll)) {
        return false;
      }
      return c.fx.every(
          (f) => settled.contains(f.kind) && f.target != FxTarget.randomEnemy);
    }).toList();

    expect(attacks.length, greaterThan(25), reason: 'not enough coverage');

    var checked = 0;
    for (final def in attacks) {
      for (final foeId in ['cinder_wretch', 'kiln_golem', 'snowblind_monk', 'gravebloom']) {
        for (final loaded in [false, true]) {
          final run = Director.newRun(99, 'ashcaller', MetaState());
          final b = fight(run, [foeId]);
          final f = b.foes.first;
          final card = CardInst(def);

          // Reactions are flagged, not folded into the number, so this case
          // is measured with the board's aura cleared. The flag itself is
          // checked separately below.
          f.aura = Elem.none;
          // A foe that dies mid-swing truncates the measurement — HP floors at
          // zero, so overkill would read as a forecast that was too high.
          // Give it a pool nothing in the game can empty.
          f.maxHp = 99999;
          f.hp = 99999;

          if (loaded) {
            // Force every multiplier on both sides to be in play at once.
            b.hero.add('strength', 3);
            b.hero.add('momentum', 2);
            f.add('vulnerable', 2);
            f.add('rime', 2);
            f.block = 7;
          }

          final predicted = b.previewDamage(card, f);
          final hpBefore = f.hp;
          b.energy = 99;
          b.hand.add(card);
          b.play(card, 0);
          final actual = hpBefore - f.hp;

          expect(predicted ?? 0, actual,
              reason: '${def.id} vs $foeId '
                  '(${loaded ? "loaded" : "clean"}): forecast '
                  '${predicted ?? 0}, dealt $actual');
          checked++;
        }
      }
    }
    // ignore: avoid_print
    print('forecast checked against $checked real swings');
  });

  test('Guard is subtracted before the number is shown', () {
    final run = Director.newRun(31, 'ashcaller', MetaState());
    final b = fight(run, ['kiln_golem']);
    final f = b.foes.first;
    final card = CardInst(cardDef('ae_stancecut')); // flat 8

    final bare = b.previewDamage(card, f);
    f.block = 5;
    final guarded = b.previewDamage(card, f);

    expect(bare, isNotNull);
    expect(guarded, (bare! - 5).clamp(0, 999) == 0 ? null : bare - 5,
        reason: 'Guard was not taken off the forecast');
  });

  test('no number is promised for foes that cannot be hit', () {
    final run = Director.newRun(41, 'ashcaller', MetaState());
    final card = CardInst(cardDef('ae_stancecut'));

    // shroud: untouchable while anything else stands.
    final b = fight(run, ['quiet_thing', 'cinder_wretch']);
    final shrouded = b.foes.firstWhere((f) => f.def!.passive == 'shroud');
    expect(b.previewDamage(card, shrouded), isNull);

    // and once it is alone, the promise comes back.
    b.foes.where((f) => f != shrouded).forEach((f) => f.hp = 0);
    expect(b.previewDamage(card, shrouded), isNotNull);
  });

  test('an incoming Reaction is flagged rather than guessed at', () {
    final run = Director.newRun(63, 'ashcaller', MetaState());
    final b = fight(run, ['drowned_choirboy']); // Frost
    final f = b.foes.first;
    f.aura = Elem.frost;

    // Ember into Frost is Vaporize.
    final ember = CardInst(cardDef('em_strike'));
    expect(b.previewReaction(ember, f), 'vaporize');

    // Frost into Frost is nothing at all.
    final frost = CardInst(cardDef('fr_lance'));
    expect(b.previewReaction(frost, f), isNull);

    // And with no aura on the board, nothing is promised either way.
    f.aura = Elem.none;
    expect(b.previewReaction(ember, f), isNull);
  });

  test('a skill that deals no damage promises nothing', () {
    final run = Director.newRun(55, 'ashcaller', MetaState());
    final b = fight(run, ['emberling']);
    expect(b.previewDamage(CardInst(cardDef('ae_guard')), b.foes.first), isNull);
  });
}
