import 'package:aeonfall/engine/run_state.dart';
import 'package:aeonfall/game.dart';
import 'package:aeonfall/ui/hub.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('audio and accessibility toggles change once per tap', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    Game.i.meta = MetaState();
    await tester.pumpWidget(const MaterialApp(home: HubScreen()));
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    final music = Game.i.meta.music;
    final sfx = Game.i.meta.sfx;
    await tester.tap(find.textContaining('MUSIC').first);
    await tester.pump();
    expect(Game.i.meta.music, !music);
    await tester.tap(find.textContaining('SOUND').first);
    await tester.pump();
    expect(Game.i.meta.sfx, !sfx);
    await tester.tap(find.text('READABILITY'));
    await tester.pumpAndSettle();
    final reducedMotion = Game.i.meta.reducedMotion;
    await tester.ensureVisible(find.text('REDUCED MOTION'));
    await tester.tap(find.text('REDUCED MOTION'));
    await tester.pump();
    expect(Game.i.meta.reducedMotion, !reducedMotion);
    expect(tester.takeException(), isNull);
  });
}
