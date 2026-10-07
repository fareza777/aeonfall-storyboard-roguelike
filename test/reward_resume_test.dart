import 'dart:convert';

import 'package:aeonfall/data/potions.dart';
import 'package:aeonfall/engine/director.dart';
import 'package:aeonfall/engine/map_gen.dart';
import 'package:aeonfall/engine/pending_reward.dart';
import 'package:aeonfall/engine/run_state.dart';
import 'package:aeonfall/game.dart';
import 'package:aeonfall/ui/map_screen.dart';
import 'package:aeonfall/ui/reward_screen.dart';
import 'package:aeonfall/ui/result_screen.dart';
import 'package:aeonfall/ui/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final name in [
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global/events',
      'xyz.luan/audioplayers/events/aeon_music',
      'xyz.luan/audioplayers/events/aeon_voice',
      for (var i = 0; i < 6; i++) 'xyz.luan/audioplayers/events/aeon_sfx_$i',
    ]) {
      messenger.setMockMethodCallHandler(
        MethodChannel(name),
        (_) async => null,
      );
    }
  });

  RunState prepare(WidgetTester tester, {int seed = 4567}) {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final run = Director.newRun(seed, 'ashcaller', MetaState());
    final node = run.map!.nodes.firstWhere((n) => n.type == NodeType.treasure);
    run.map!.available = [node.id];
    run.map!.currentId = node.id;
    run.setFlag('intro_act1');
    Game.i.meta = MetaState()..tutorialDone = true;
    Game.i.run = run;
    Game.i.director = Director(run);
    Game.i.battle = null;
    return run;
  }

  Widget reward(int nodeId, {bool cards = false, bool relic = false}) =>
      MaterialApp(
        home: RewardScreen(
          nodeId: nodeId,
          gold: 65,
          cards: cards,
          relic: relic,
          title: 'A CACHE',
          blurb: 'A saved reward.',
          art: 'site_treasure_room',
        ),
      );

  Future<RunState> restore(WidgetTester tester) async {
    final snapshot =
        jsonDecode(jsonEncode(Game.i.run!.toJson())) as Map<String, dynamic>;
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    final run = RunState.fromJson(snapshot);
    Game.i.run = run;
    Game.i.director = Director(run);
    Game.i.battle = null;
    return run;
  }

  testWidgets('Gold cannot be collected twice after a real reward UI restore', (
    tester,
  ) async {
    final run = prepare(tester);
    final id = run.map!.currentId;
    await tester.pumpWidget(reward(id));
    await tester.pumpAndSettle();
    await tester.tap(find.text('65 Aeon'));
    await tester.pump();
    expect(run.gold, 185);
    final restored = await restore(tester);
    await tester.pumpWidget(reward(id));
    await tester.pumpAndSettle();
    await tester.tap(find.text('65 Aeon'));
    await tester.pump();
    expect(restored.gold, 185);
  });

  testWidgets('A chosen frame cannot be chosen again after restore', (
    tester,
  ) async {
    final run = prepare(tester);
    final id = run.map!.currentId;
    final before = run.deck.length;
    await tester.pumpWidget(reward(id, cards: true));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(FrameCard).first);
    await tester.tap(find.byType(FrameCard).first);
    await tester.pump();
    expect(run.deck.length, before + 1);
    final restored = await restore(tester);
    await tester.pumpWidget(reward(id, cards: true));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(FrameCard).first);
    await tester.tap(find.byType(FrameCard).first);
    await tester.pump();
    expect(restored.deck.length, before + 1);
  });

  testWidgets('A draught cannot be collected again after restore', (
    tester,
  ) async {
    // Pick a deterministic eligible drop, rather than mocking the director.
    final seed = Iterable<int>.generate(100, (i) => i + 1).firstWhere(
      (s) =>
          Director(
            Director.newRun(s, 'ashcaller', MetaState()),
          ).potionDrop('elite') !=
          null,
    );
    final run = prepare(tester, seed: seed);
    final id = run.map!.currentId;
    final p = Director(run).potionDrop('elite')!;
    await tester.pumpWidget(reward(id, relic: true));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(p.name.toUpperCase()));
    await tester.tap(find.text(p.name.toUpperCase()));
    await tester.pump();
    expect(run.potions, [p.id]);
    final restored = await restore(tester);
    await tester.pumpWidget(reward(id, relic: true));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text(p.name.toUpperCase()));
    await tester.tap(find.text(p.name.toUpperCase()));
    await tester.pump();
    expect(restored.potions, [p.id]);
  });

  testWidgets('Unclaimed offers are stored with the run snapshot', (
    tester,
  ) async {
    final run = prepare(tester);
    await tester.pumpWidget(
      reward(run.map!.currentId, cards: true, relic: true),
    );
    await tester.pumpAndSettle();
    final saved = jsonDecode(jsonEncode(run.toJson())) as Map<String, dynamic>;
    expect(saved['pendingReward'], isA<Map<String, dynamic>>());
    final pending = saved['pendingReward'] as Map<String, dynamic>;
    expect(pending['cardIds'], hasLength(3));
    expect(pending['relicId'], isA<String>());
  });

  testWidgets('Continue run reopens the saved reward, not a new map choice', (
    tester,
  ) async {
    final run = prepare(tester);
    await tester.pumpWidget(reward(run.map!.currentId, cards: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('65 Aeon'));
    await tester.pump();
    await restore(tester);
    await tester.pumpWidget(const MaterialApp(home: MapScreen()));
    await tester.pumpAndSettle();
    expect(find.byType(RewardScreen), findsOneWidget);
    expect(find.text('TAKEN'), findsOneWidget);
    expect(Game.i.battle, isNull);
  });

  testWidgets('A stale screen cannot grant gold for a resolved node', (
    tester,
  ) async {
    final run = prepare(tester);
    final id = run.map!.currentId;
    Game.i.completeNode(id);
    await tester.pumpWidget(reward(id));
    await tester.pumpAndSettle();
    await tester.tap(find.text('65 Aeon'));
    await tester.pump();
    expect(run.gold, 120);
  });

  for (final act in [1, 3]) {
    testWidgets(
      'A resolved Act $act boss survives reload during its transition',
      (tester) async {
        final run = prepare(tester);
        while (run.act < act) {
          Game.i.director!.advanceAct();
        }
        run.setFlag('intro_act$act');
        final boss = run.map!.nodes.firstWhere((n) => n.type == NodeType.boss);
        run.map!.currentId = boss.id;
        run.map!.available = [boss.id];
        await tester.pumpWidget(
          MaterialApp(
            home: RewardScreen(
              nodeId: boss.id,
              gold: 120,
              cards: true,
              relic: true,
              isBoss: true,
              title: 'THE ACT ENDS',
              blurb: 'A saved boss reward.',
              art: 'site_treasure_room',
            ),
          ),
        );
        await tester.pumpAndSettle();
        Game.i.completeNode(boss.id);
        await restore(tester);
        await tester.pumpWidget(const MaterialApp(home: MapScreen()));
        await tester.pumpAndSettle();
        if (act == 3) {
          expect(find.byType(FinaleScreen), findsOneWidget);
        } else {
          expect(find.byType(RewardScreen), findsOneWidget);
          await tester.ensureVisible(find.text('SKIP THE REST AND CONTINUE'));
          await tester.tap(find.text('SKIP THE REST AND CONTINUE'));
          Game.i.run!.setFlag('intro_act2');
          await tester.pumpAndSettle();
          expect(Game.i.run!.act, 2);
          expect(Game.i.run!.map!.available, isNotEmpty);
        }
        expect(Game.i.run!.combatClears, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  test(
    'A legacy save keeps its deck, gold and belt when new reward fields are absent',
    () {
      final run = Director.newRun(44, 'ashcaller', MetaState());
      run.gold = 321;
      run.addPotion(kPotions.first.id);
      final saved =
          jsonDecode(jsonEncode(run.toJson())) as Map<String, dynamic>;
      saved.remove('pendingReward');
      final restored = RunState.fromJson(saved);
      expect(restored.gold, 321);
      expect(restored.deck.map((c) => c.def.id), run.deck.map((c) => c.def.id));
      expect(restored.potions, [kPotions.first.id]);
    },
  );

  RunState offeredReward() {
    final run = Director.newRun(4567, 'ashcaller', MetaState());
    final node = run.map!.nodes.firstWhere((n) => n.type == NodeType.treasure);
    run.map!.available = [node.id];
    run.map!.currentId = node.id;
    run.pendingReward = PendingReward(
      act: 1,
      nodeId: node.id,
      gold: 65,
      title: 'A CACHE',
      blurb: 'Saved.',
      art: 'site_treasure_room',
      cards: true,
      relic: true,
      cardIds: ['em_strike'],
      relicId: 'bone_flute',
      extraRelicId: 'ash_locket',
      potionId: 'ashflask',
    );
    return run;
  }

  test('Every reward category grants once, including after serialization', () {
    final run = offeredReward();
    final beforeDeck = run.deck.length;
    expect(run.claimRewardGold(), isTrue);
    expect(run.claimRewardBonus(35), isTrue);
    expect(run.claimRewardCard('em_strike'), isTrue);
    expect(run.claimRewardRelic(), isTrue);
    expect(run.claimRewardRelic(extra: true), isTrue);
    expect(run.claimRewardPotion(), isTrue);
    final restored = RunState.fromJson(jsonDecode(jsonEncode(run.toJson())));
    expect(restored.claimRewardGold(), isFalse);
    expect(restored.claimRewardBonus(35), isFalse);
    expect(restored.claimRewardCard('em_strike'), isFalse);
    expect(restored.claimRewardRelic(), isFalse);
    expect(restored.claimRewardRelic(extra: true), isFalse);
    expect(restored.claimRewardPotion(), isFalse);
    expect(restored.gold, 220);
    expect(restored.deck.length, beforeDeck + 1);
    expect(restored.potions, ['ashflask']);
    expect(restored.relics.where((id) => id == 'bone_flute'), hasLength(1));
    expect(restored.relics.where((id) => id == 'ash_locket'), hasLength(1));
  });

  test(
    'A full belt keeps the unclaimed draught available until space opens',
    () {
      final run = offeredReward();
      run.potions = ['stillwater', 'torndraft', 'quickink'];
      expect(run.claimRewardPotion(), isFalse);
      expect(run.pendingReward!.potionTaken, isFalse);
      run.potions.removeLast();
      expect(run.claimRewardPotion(), isTrue);
      expect(run.potions, ['stillwater', 'torndraft', 'ashflask']);
    },
  );

  test('Resolved and wrong-act reward snapshots cannot grant any category', () {
    for (final wrongAct in [false, true]) {
      final run = offeredReward();
      if (wrongAct) {
        run.act = 2;
      } else {
        run.pendingReward!.resolved = true;
      }
      expect(run.claimRewardGold(), isFalse);
      expect(run.claimRewardBonus(35), isFalse);
      expect(run.claimRewardCard('em_strike'), isFalse);
      expect(run.claimRewardRelic(), isFalse);
      expect(run.claimRewardRelic(extra: true), isFalse);
      expect(run.claimRewardPotion(), isFalse);
      expect(run.gold, 120);
    }
  });

  testWidgets('Reloading cannot reroll the saved relic, potion or card IDs', (
    tester,
  ) async {
    final run = prepare(tester);
    run.addRelic('keystone');
    final id = run.map!.currentId;
    await tester.pumpWidget(reward(id, cards: true, relic: true));
    await tester.pumpAndSettle();
    final offer = jsonDecode(jsonEncode(run.pendingReward!.toJson()));
    final restored = await restore(tester);
    for (var i = 0; i < 20; i++) {
      restored.rng.nextInt(1000000);
    }
    await tester.pumpWidget(reward(id, cards: true, relic: true));
    await tester.pumpAndSettle();
    expect(restored.pendingReward!.toJson(), offer);
  });
}
