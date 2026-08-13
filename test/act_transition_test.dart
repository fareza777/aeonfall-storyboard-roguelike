import 'package:aeonfall/engine/director.dart';
import 'package:aeonfall/engine/map_gen.dart';
import 'package:aeonfall/engine/run_state.dart';
import 'package:aeonfall/game.dart';
import 'package:aeonfall/ui/hub.dart';
import 'package:aeonfall/ui/map_screen.dart';
import 'package:aeonfall/ui/reward_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Beating the first boss dropped the player on a white screen. This drives
/// the real sequence — finish the boss node, advance the act, come back to the
/// map — and fails if anything in it throws or renders nothing.
void main() {
  setUp(() {
    Game.i.meta = MetaState()..tutorialDone = true;
    Game.i.battle = null;
  });

  /// Walk a run to its boss node the way a player would.
  RunState atBoss() {
    final run = Director.newRun(1234, 'ashcaller', MetaState()..tutorialDone = true);
    final map = run.map!;
    final boss = map.nodes.firstWhere((n) => n.type == NodeType.boss);
    // Everything before the boss is done.
    for (final n in map.nodes) {
      if (n.layer < boss.layer) n.visited = true;
    }
    map.available = [boss.id];
    run.floor = boss.layer - 1;
    run.setFlag('intro_act1'); // the Act I intro has already been seen
    Game.i.run = run;
    Game.i.director = Director(run);
    return run;
  }

  test('finishing the act-one boss leaves a run you can still walk', () {
    final run = atBoss();
    final bossId = run.map!.nodes.firstWhere((n) => n.type == NodeType.boss).id;

    Game.i.completeNode(bossId);
    Game.i.nextAct();

    expect(Game.i.run, isNotNull, reason: 'the run was thrown away');
    expect(Game.i.run!.act, 2);
    expect(Game.i.run!.floor, 0);
    expect(Game.i.hasRun, isTrue, reason: 'the Sanctum would offer a new run');

    final map = Game.i.run!.map!;
    expect(map.act, 2);
    expect(map.available, isNotEmpty,
        reason: 'no node is reachable — the map is a dead end');
    // Every reachable node must exist, or the map screen throws while painting.
    for (final id in map.available) {
      expect(() => map.byId(id), returnsNormally);
    }
    for (final n in map.nodes) {
      for (final id in n.next) {
        expect(() => map.byId(id), returnsNormally,
            reason: 'node ${n.id} points at missing node $id');
      }
    }
  });

  test('a second Continue after the act turned over does not throw', () {
    // The real sequence when a player taps the big button twice: the first
    // tap advances the act, the second arrives with the old act's node id
    // against the new act's map. StoryMap.byId was an unguarded firstWhere,
    // so this threw a StateError out of a tap handler in the middle of a
    // route transition — which is what left the screen blank.
    final run = atBoss();
    final bossId = run.map!.nodes.firstWhere((n) => n.type == NodeType.boss).id;

    Game.i.completeNode(bossId);
    Game.i.nextAct();

    final act2Map = Game.i.run!.map!;
    final before = act2Map.nodes.where((n) => n.visited).length;

    expect(() => Game.i.completeNode(bossId), returnsNormally,
        reason: 'the second tap threw');
    expect(act2Map.nodes.where((n) => n.visited).length, before,
        reason: 'the stale id marked a node in the new act as done');
    expect(Game.i.run!.act, 2, reason: 'the second tap advanced something');
  });

  test('an id from another map never resolves to the wrong node', () {
    final run = atBoss();
    final map = run.map!;
    expect(map.tryById(999999), isNull);
    expect(map.tryById(map.nodes.first.id), isNotNull);
  });

  testWidgets('the map still renders after the act turns over', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final run = atBoss();
    final bossId = run.map!.nodes.firstWhere((n) => n.type == NodeType.boss).id;
    Game.i.completeNode(bossId);
    Game.i.nextAct();
    Game.i.run!.setFlag('intro_act2'); // skip the act intro dialog

    await tester.pumpWidget(const MaterialApp(home: MapScreen()));
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull,
        reason: 'the map threw after the act advanced');
    expect(find.byType(MapScreen), findsOneWidget);
  });

  testWidgets('the Act II intro opens and closes without eating the map',
      (tester) async {
    // The real path does NOT pre-flag the intro: arriving in Act II fires an
    // act-intro dialog from didPopNext, mid-transition.
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final run = atBoss();
    final bossId = run.map!.nodes.firstWhere((n) => n.type == NodeType.boss).id;
    Game.i.completeNode(bossId);
    Game.i.nextAct();

    await tester.pumpWidget(const MaterialApp(home: MapScreen()));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(tester.takeException(), isNull, reason: 'the act intro threw');

    // Close it the way the button does.
    final close = find.text('BEGIN');
    if (close.evaluate().isNotEmpty) {
      await tester.tap(close.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }
    expect(tester.takeException(), isNull);
    expect(find.byType(MapScreen), findsOneWidget,
        reason: 'closing the act intro took the map with it');
  });

  testWidgets('the real navigation stack survives the act turning over',
      (tester) async {
    // The earlier version of this test pushed the reward onto a bare
    // Navigator, which is NOT the stack the game has. The real one is
    // Hub -> Map -> Battle, with the reward *replacing* Battle, and the
    // act-advance then calling pushAndRemoveUntil against it.
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final run = atBoss();
    final bossId = run.map!.nodes.firstWhere((n) => n.type == NodeType.boss).id;
    run.setFlag('intro_act2');

    await tester.pumpWidget(const MaterialApp(home: HubScreen()));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);

    // Hub -> Map (a plain push, as the Sanctum does)
    nav.push(MaterialPageRoute(builder: (_) => const MapScreen()));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Map -> the boss reward, which in the game replaces the battle screen.
    nav.push(MaterialPageRoute(
      builder: (_) => RewardScreen(
        nodeId: bossId,
        gold: 120,
        relic: true,
        cards: true,
        isBoss: true,
        title: 'THE ACT ENDS',
        blurb: 'You are still here.',
        art: 'site_treasure_room',
      ),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);

    // Exactly what Continue does.
    Game.i.completeNode(bossId);
    Game.i.nextAct();
    Game.i.run!.setFlag('intro_act2');
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MapScreen()),
      (r) => r.isFirst,
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(tester.takeException(), isNull,
        reason: 'the act transition threw on the real stack');
    expect(find.byType(MapScreen), findsOneWidget,
        reason: 'nothing rendered — this is the white screen');
  });

  testWidgets('the boss reward screen builds and its Continue works',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final run = atBoss();
    final bossId = run.map!.nodes.firstWhere((n) => n.type == NodeType.boss).id;

    await tester.pumpWidget(MaterialApp(
      home: Navigator(
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => const MapScreen(),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    // Stack the reward on top the way the battle screen does.
    final navigator = tester.state<NavigatorState>(find.byType(Navigator).last);
    navigator.push(MaterialPageRoute(
      builder: (_) => RewardScreen(
        nodeId: bossId,
        gold: 120,
        relic: true,
        cards: true,
        isBoss: true,
        title: 'THE ACT ENDS',
        blurb: 'You are still here.',
        art: 'site_treasure_room',
      ),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(tester.takeException(), isNull, reason: 'the reward screen threw');

    // The act turns over exactly as Continue does it.
    Game.i.completeNode(bossId);
    Game.i.nextAct();
    navigator.pop();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(tester.takeException(), isNull,
        reason: 'returning to the map after the act ended threw');
    expect(find.byType(MapScreen), findsOneWidget,
        reason: 'nothing is on screen — this is the white screen');
  });
}
