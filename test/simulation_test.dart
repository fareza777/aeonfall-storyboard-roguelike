import 'package:aeonfall/data/enemies.dart';
import 'package:aeonfall/data/narrative_model.dart';
import 'package:aeonfall/data/vessels.dart';
import 'package:aeonfall/engine/battle.dart';
import 'package:aeonfall/engine/director.dart';
import 'package:aeonfall/engine/map_gen.dart';
import 'package:aeonfall/engine/rng.dart';
import 'package:aeonfall/engine/run_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// Plays a battle with a dumb bot: dump every affordable frame, end turn.
/// The point is to hammer every effect, reaction and relic path for crashes.
void autoPlay(Battle b, Rng rng, {int maxTurns = 60}) {
  b.start();
  var turns = 0;
  while (!b.ended && turns++ < maxTurns) {
    var guard = 0;
    while (guard++ < 40) {
      final playable = b.hand.where(b.canPlay).toList();
      if (playable.isEmpty) break;
      final card = rng.pick(playable);
      final targets = <int>[];
      for (var i = 0; i < b.foes.length; i++) {
        if (b.foes[i].alive) targets.add(i);
      }
      if (targets.isEmpty) break;
      b.play(card, rng.pick(targets));
      if (b.ended) break;
    }
    if (b.ended) break;
    b.endTurn();
  }
}

void main() {
  test('full runs complete without throwing', () {
    var battles = 0;
    var wins = 0;
    var cinematics = 0;
    var reactions = 0;

    for (var seed = 1; seed <= 24; seed++) {
      for (final v in kVessels) {
        final run = Director.newRun(seed * 7919, v.id, MetaState()..ascension = seed % 6);
        final d = Director(run);
        final rng = Rng(seed * 31 + v.id.length);

        for (run.act = 1; run.act <= 3; run.act++) {
          run.map = generateMap(run.rng.fork('sim$run.act'), run.act);
          for (var floor = 0; floor < 14; floor++) {
            run.floor = floor;
            run.totalFloors++;
            final type = rng.pick([
              NodeType.battle,
              NodeType.battle,
              NodeType.elite,
              NodeType.event,
              NodeType.shop,
              NodeType.rest,
            ]);

            if (type == NodeType.battle || type == NodeType.elite) {
              final foes = d.encounter(type);
              expect(foes, isNotEmpty);
              final b = Battle(
                run: run,
                foeDefs: foes,
                rng: rng.fork('b$seed-$floor-${v.id}'),
                kind: type == NodeType.elite ? 'elite' : 'normal',
              );
              autoPlay(b, rng);
              battles++;
              if (b.victory) wins++;
              cinematics += b.cinematicsFired;
              reactions += b.reactionsFired;
              if (!b.victory) {
                // simulate the meta reward and restart the vessel's run
                run.hp = run.maxHp;
              }
            } else {
              final ev = d.nextEvent();
              if (ev != null) {
                final choice = rng.pick(ev.choices);
                for (final o in choice.out) {
                  d.applyOutcome(o);
                }
              }
              // shops and rests exercise the same generators the UI uses
              d.shopStock();
              d.cardReward();
              d.relicReward();
              d.offerCompanion();
            }
            expect(run.hp, greaterThanOrEqualTo(0));
            expect(run.deck.length, greaterThan(0));
          }

          // boss
          final boss = d.encounter(NodeType.boss);
          final b = Battle(
            run: run,
            foeDefs: boss,
            rng: rng.fork('boss$seed-${run.act}-${v.id}'),
            kind: 'boss',
          );
          autoPlay(b, rng, maxTurns: 90);
          battles++;
          if (b.victory) wins++;
          cinematics += b.cinematicsFired;
          run.hp = run.maxHp;
        }

        for (final key in ['pen', 'break', 'finish', 'walk']) {
          expect(d.pickEnding(key), isNotEmpty);
        }
      }
    }

    // ignore: avoid_print
    print('simulated $battles battles, $wins wins, '
        '$cinematics cinematics, $reactions reactions');
    expect(battles, greaterThan(400));
    expect(cinematics, greaterThan(0));
    // Reactions are the core of the combat design — if a change makes them
    // unreachable this is the test that should scream.
    expect(reactions, greaterThan(battles ~/ 4),
        reason: 'elemental reactions are firing far too rarely');
  }, timeout: const Timeout(Duration(minutes: 6)));

  test('an event can drain you to zero — death is reachable off the map', () {
    final run = Director.newRun(991, 'ashcaller', MetaState());
    final d = Director(run);
    run.hp = 5;
    d.applyOutcome(const Out(OutKind.hp, value: 20));
    expect(run.hp, 0, reason: 'HP must be allowed to reach zero outside battle');
  });

  test('the Cinematic meter empties the instant it fires', () {
    final run = Director.newRun(4242, 'ashcaller', MetaState());
    final b = Battle(
      run: run,
      foeDefs: [enemyDef('drowned_choirboy')],
      rng: Rng(5),
      kind: 'normal',
    )..start();

    // three Ember frames in one turn
    var fired = false;
    for (var guard = 0; guard < 40 && !fired; guard++) {
      final ember = b.hand.where((c) => c.def.elem.name == 'ember' && b.canPlay(c));
      if (ember.isEmpty) {
        b.endTurn();
        continue;
      }
      b.energy = 9;
      b.play(ember.first, 0);
      fired = b.cinematicsFired > 0;
    }
    expect(fired, isTrue, reason: 'could not trigger a Cinematic to test');
    expect(b.elemsThisTurn, isEmpty,
        reason: 'the meter must reset immediately, not at end of turn');
  });

  test('every frame played leaves a record', () {
    final run = Director.newRun(77, 'saintcoralis', MetaState());
    final b = Battle(
      run: run,
      foeDefs: [enemyDef('cinder_wretch'), enemyDef('ash_hound')],
      rng: Rng(9),
      kind: 'normal',
    )..start();

    final before = b.log.length;
    var played = 0;
    for (final c in List.of(b.hand)) {
      if (!b.canPlay(c) || b.ended) continue;
      b.play(c, 0);
      played++;
    }
    expect(played, greaterThan(0));
    expect(b.log.length - before, greaterThanOrEqualTo(played),
        reason: 'each frame must add at least one line to the record');
    for (final l in b.log) {
      expect(l.text.length, lessThanOrEqualTo(64),
          reason: 'log lines must stay short enough to not truncate: "${l.text}"');
    }
  });

  test('every enemy pattern resolves', () {
    final run = Director.newRun(4242, 'ashcaller', MetaState());
    for (final def in kAllEnemies) {
      final b = Battle(
        run: run,
        foeDefs: [def],
        rng: Rng(def.id.length * 977 + 3),
        kind: def.tier == 2 ? 'boss' : (def.tier == 1 ? 'elite' : 'normal'),
      );
      run.hp = 9999;
      run.maxHp = 9999;
      autoPlay(b, Rng(def.id.length + 11), maxTurns: 25);
      expect(b.log, isNotEmpty, reason: def.id);
    }
  }, timeout: const Timeout(Duration(minutes: 4)));
}
