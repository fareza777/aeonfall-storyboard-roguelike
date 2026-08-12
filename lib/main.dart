import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'audio.dart';
import 'game.dart';
import 'theme.dart';
import 'ui/splash.dart';

/// Lets screens know when they have been revealed again after a push, which is
/// the only reliable signal when routes are swapped with pushReplacement.
final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const AeonfallApp());
}

class AeonfallApp extends StatefulWidget {
  const AeonfallApp({super.key});

  @override
  State<AeonfallApp> createState() => _AeonfallAppState();
}

class _AeonfallAppState extends State<AeonfallApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Android will happily keep our soundtrack playing after the player has
  /// switched apps. Stop it the moment we lose the foreground.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Audio.i.resumeAll();
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        Audio.i.pauseAll();
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'AEONFALL',
        debugShowCheckedModeBanner: false,
        theme: Ae.theme(),
        navigatorObservers: [routeObserver],
        builder: (context, child) => AnimatedBuilder(
          animation: Game.i,
          builder: (_, __) {
            // The player's own text-size choice multiplies whatever the system
            // asks for, then the whole thing is clamped so no layout can be
            // driven off a cliff.
            final chosen = Game.i.meta.textScale;
            final system = MediaQuery.textScalerOf(context).scale(1);
            final factor = (system * chosen).clamp(0.85, 1.6);
            return MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(factor)),
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
        home: const SplashScreen(),
      );
}
