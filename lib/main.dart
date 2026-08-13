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

/// The handful of stack frames that belong to this app, which is the only
/// part anyone can act on.
String _ourFrames(StackTrace? stack) {
  if (stack == null) return 'no stack';
  final lines = stack
      .toString()
      .split('\n')
      .where((l) => l.contains('package:aeonfall'))
      .take(6)
      .map((l) => l.replaceAll('package:aeonfall/', '').trim())
      .toList();
  return lines.isEmpty ? 'no aeonfall frames' : lines.join('\n');
}

/// Replaces the framework's blank error box with something a player can read
/// and, more importantly, leave. A build failure used to render nothing at
/// all, which on a phone is an unrecoverable white screen with the music
/// still playing.
Widget _errorScreen(FlutterErrorDetails details) => Material(
      color: Ae.ink,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('THE PAGE TORE', style: Ae.display(24)),
              const SizedBox(height: 10),
              Text(
                'Something in this frame could not be drawn. Your run is saved '
                'up to the last floor you finished.',
                style: Ae.body(16, c: Ae.dim, h: 1.5),
              ),
              const SizedBox(height: 18),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${details.exception}',
                          style: Ae.body(13, c: Ae.blood, h: 1.4)),
                      const SizedBox(height: 12),
                      // Only this app's own frames. A raw Flutter stack is
                      // forty lines of framework noise and the one line that
                      // matters is never on screen.
                      Text(_ourFrames(details.stack),
                          style: Ae.body(11.5, c: Ae.goldSoft, h: 1.45)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = _errorScreen;
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
