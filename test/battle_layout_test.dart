import 'package:aeonfall/data/enemies.dart';
import 'package:aeonfall/engine/battle.dart';
import 'package:aeonfall/engine/core.dart';
import 'package:aeonfall/engine/director.dart';
import 'package:aeonfall/engine/map_gen.dart';
import 'package:aeonfall/engine/rng.dart';
import 'package:aeonfall/engine/run_state.dart';
import 'package:aeonfall/game.dart';
import 'package:aeonfall/ui/battle_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The battle screen has to survive its worst case: three foes at once, every
/// one of them carrying a pile of conditions and a long mutated name. If the
/// foe columns grow past their box they slide underneath the readout panel and
/// the player loses information — which is exactly what this guards against.
void main() {
  Future<void> pumpBattle(WidgetTester tester, List<String> foeIds,
      {bool loadStatuses = true}) async {
    final run = Director.newRun(1234, 'ashcaller', MetaState());
    final b = Battle(
      run: run,
      foeDefs: foeIds.map(enemyDef).toList(),
      rng: Rng(3),
      kind: 'normal',
    )..start();

    if (loadStatuses) {
      // Worst case that the game can actually produce: pile on every single
      // condition that exists, on every foe, at once.
      for (final f in b.foes) {
        var n = 2;
        for (final key in kStatus.keys) {
          f.add(key, n++);
        }
        f.block = 12;
      }
    }

    Game.i.meta.tutorialDone = true;
    Game.i.run = run;
    Game.i.battle = b;

    await tester.pumpWidget(MaterialApp(
      home: BattleScreen(nodeId: 0, type: NodeType.battle),
    ));
    // Long enough for the floating-text timers to drain, or teardown trips on
    // pending timers instead of telling us about the layout.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('three heavily loaded foes do not overflow', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpBattle(tester, [
      'bell_wraith',
      'hoarfrost_stag',
      'cinder_wretch',
    ]);

    expect(tester.takeException(), isNull,
        reason: 'the foe row overflowed its box');
  });

  testWidgets('a single boss with conditions does not overflow', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await pumpBattle(tester, ['aeonfall']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('survives a short screen', (tester) async {
    // A 16:9 budget phone — the tightest layout we realistically ship to.
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await pumpBattle(tester, ['bell_wraith', 'gravebloom', 'bone_florist']);
    expect(tester.takeException(), isNull,
        reason: 'layout must still fit on a small screen');
  });
}
