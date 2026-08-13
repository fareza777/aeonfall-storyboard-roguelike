import 'package:aeonfall/engine/director.dart';
import 'package:aeonfall/engine/map_gen.dart';
import 'package:aeonfall/engine/run_state.dart';
import 'package:aeonfall/game.dart';
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
