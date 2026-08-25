import 'package:flutter/material.dart';
import 'dart:async';

import '../audio.dart';
import '../game.dart';
import '../monetization/monetization_service.dart';
import '../theme.dart';
import 'hub.dart';
import 'onboarding.dart';
import 'widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..forward();
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();
  bool _booted = false;
  bool _canTap = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await Game.i.boot();
    // Consent and billing are best-effort and never delay the title screen.
    unawaited(MonetizationService.i.initialize());
    if (!mounted) return;
    setState(() => _booted = true);
    Audio.i.music('title');
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (mounted) setState(() => _canTap = true);
  }

  @override
  void dispose() {
    _in.dispose();
    _drift.dispose();
    super.dispose();
  }

  void _go() {
    if (!_booted) return;
    Audio.i.sfx('confirm');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => Game.i.meta.onboarded
            ? const HubScreen()
            : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _canTap ? _go : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _drift,
              builder: (_, child) => Transform.scale(
                scale: 1.10 + 0.05 * (0.5 - (_drift.value - 0.5).abs()),
                child: child,
              ),
              child: const Art('brand_splash'),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Ae.ink.withValues(alpha: .70),
                    Ae.ink.withValues(alpha: .30),
                    Ae.ink.withValues(alpha: .92),
                  ],
                  stops: const [0, .42, 1],
                ),
              ),
            ),
            SafeArea(
              child: FadeTransition(
                opacity: CurvedAnimation(parent: _in, curve: Curves.easeIn),
                child: Column(
                  children: [
                    const Spacer(flex: 3),
                    Text(
                      'AEONFALL',
                      textAlign: TextAlign.center,
                      style: Ae.display(52, c: Ae.bone, w: 700),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: 190,
                      height: 1.6,
                      color: Ae.gold.withValues(alpha: .8),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 34),
                      child: Text(
                        'EVERY FALL REWRITES THE TALE',
                        textAlign: TextAlign.center,
                        style: Ae.label(15, c: Ae.goldSoft),
                      ),
                    ),
                    const Spacer(flex: 4),
                    AnimatedOpacity(
                      opacity: _canTap ? 1 : 0,
                      duration: const Duration(milliseconds: 700),
                      child: Column(
                        children: [
                          Text('TAP TO BEGIN', style: Ae.label(18, c: Ae.bone)),
                          const SizedBox(height: 8),
                          Text(
                            _booted && Game.i.meta.runs > 0
                                ? '${Game.i.meta.runs} runs · ${Game.i.meta.wins} finished'
                                : 'a storyboard roguelite',
                            style: Ae.body(14, c: Ae.dim),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 44),
                    if (!_booted)
                      const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Ae.gold,
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
