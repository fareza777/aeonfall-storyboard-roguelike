import 'dart:convert';

import 'package:aeonfall/engine/director.dart';
import 'package:aeonfall/engine/run_state.dart';
import 'package:aeonfall/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final fixture in [
    (0, false, false, 3),
    (0, true, false, 4),
    (0, true, true, 5),
    (19, false, false, 2),
    (19, true, false, 3),
    (19, true, true, 4),
  ]) {
    test(
      'Archive/A${fixture.$1}/Marrow offers ${fixture.$4} distinct frames (${fixture.$2}/${fixture.$3})',
      () {
        final meta = MetaState()..ascension = fixture.$1;
        if (fixture.$2) meta.upgrades.add('archive');
        final run = Director.newRun(1234, 'ashcaller', meta);
        if (fixture.$3) run.addRelic('marrow_die');
        final cards = Director(run).cardReward();
        expect(cards, hasLength(fixture.$4));
        expect(cards.map((c) => c.id).toSet(), hasLength(fixture.$4));
      },
    );
  }

  test('The extra reward choice survives saving and restoring a run', () {
    final run = Director.newRun(
      1234,
      'ashcaller',
      MetaState()..upgrades.add('archive'),
    );
    final restored = RunState.fromJson(jsonDecode(jsonEncode(run.toJson())));
    expect(Director(restored).cardReward(), hasLength(4));
  });

  test(
    'Archive purchased with an active run applies to future rewards immediately',
    () {
      Game.i.meta = MetaState();
      Game.i.run = Director.newRun(1234, 'ashcaller', Game.i.meta);
      Game.i.director = Director(Game.i.run!);
      expect(Game.i.director!.cardReward(), hasLength(3));
      Game.i.meta.upgrades.add('archive');
      Game.i.saveMeta(); // Same boundary used by the Sanctum purchase.
      expect(Game.i.director!.cardReward(), hasLength(4));
    },
  );

  test(
    'A legacy run receives an already-owned Archive without resetting progress',
    () {
      final oldRun = Director.newRun(1234, 'ashcaller', MetaState())
        ..gold = 444;
      final snapshot =
          jsonDecode(jsonEncode(oldRun.toJson())) as Map<String, dynamic>;
      snapshot.remove('extraCardChoice');
      Game.i.run = RunState.fromJson(snapshot);
      Game.i.meta = MetaState()
        ..shards = 99
        ..upgrades.add('archive')
        ..adsRemoved = true;
      Game.i.saveMeta();
      expect(Director(Game.i.run!).cardReward(), hasLength(4));
      expect(Game.i.run!.gold, 444);
      expect(Game.i.meta.shards, 99);
      expect(Game.i.meta.adsRemoved, isTrue);
      expect(Game.i.run!.deck, hasLength(11));
    },
  );
}
