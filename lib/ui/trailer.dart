import 'dart:async';

import 'package:flutter/material.dart';

import '../audio.dart';
import '../theme.dart';
import 'widgets.dart';

class _Beat {
  const _Beat(this.art, this.text, this.seconds);
  final String art;
  final String text;
  final double seconds;
}

/// Timed to the narration in assets/audio/vo_trailer.mp3.
const _beats = <_Beat>[
  _Beat('brand_splash', 'The world of Aevum was not created.\nIt was drawn.', 5.4),
  _Beat('biome_ashfall', 'Panel by panel. Life by life.', 3.6),
  _Beat('event_burning_library',
      'When a story grows too tangled to finish, its Author does what every artist does.', 5.6),
  _Beat('boss_aeonfall', 'He crumples the page. And he starts again.', 4.6),
  _Beat('chron_chorus_of_falls',
      'They call it a Fall.\nThere have been three thousand of them.', 5.0),
  _Beat('event_loop_revealed', 'You will not remember the others.\nMemory is drawn, too.', 4.8),
  _Beat('vessel_ashcaller', 'But you are a Vessel — drawn too well to erase.', 4.4),
  _Beat('event_first_fall', 'Kept. Wiped. Used again.', 3.2),
  _Beat('brand_onboard_3', 'Until now.\nThis time, you woke up before the ending.', 5.0),
  _Beat('event_betrayal',
      'Every companion who walks beside you was given an instruction before you ever met.', 6.2),
  _Beat('event_authors_study',
      'And at the top of the tower, behind a desk that has never once been empty, '
      'something is still writing.', 6.4),
  _Beat('brand_title_bg', 'AEONFALL', 6.0),
];

class TrailerScreen extends StatefulWidget {
  const TrailerScreen({super.key});

  @override
  State<TrailerScreen> createState() => _TrailerScreenState();
}

class _TrailerScreenState extends State<TrailerScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _kb =
      AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
  int _i = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Audio.i.stopMusic();
    _play();
    _schedule();
  }

  Future<void> _play() async {
    try {
      await Audio.i.voice('trailer');
    } catch (_) {}
  }

  void _schedule() {
    if (_i >= _beats.length) return;
    _timer = Timer(
      Duration(milliseconds: (_beats[_i].seconds * 1000).round()),
      () {
        if (!mounted) return;
        if (_i >= _beats.length - 1) {
          _exit();
          return;
        }
        setState(() => _i++);
        _schedule();
      },
    );
  }

  void _exit() {
    _timer?.cancel();
    Audio.i.stopVoice();
    Audio.i.music('hub');
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _kb.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = _beats[_i];
    final last = _i == _beats.length - 1;
    return Scaffold(
      backgroundColor: Ae.ink,
      body: GestureDetector(
        onTap: _exit,
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 900),
              child: AnimatedBuilder(
                key: ValueKey(_i),
                animation: _kb,
                builder: (_, child) => Transform.scale(
                  scale: 1.08 + .10 * _kb.value,
                  child: child,
                ),
                child: Art(b.art),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Ae.ink.withValues(alpha: .72),
                    Ae.ink.withValues(alpha: .34),
                    Ae.ink.withValues(alpha: .94),
                  ],
                  stops: const [0, .40, .88],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(26, 20, 26, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                          onPressed: _exit,
                          child: Text('SKIP', style: Ae.label(14, c: Ae.dim))),
                    ),
                    const Spacer(),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: last
                          ? Column(
                              key: const ValueKey('logo'),
                              children: [
                                Text('AEONFALL',
                                    textAlign: TextAlign.center, style: Ae.display(46)),
                                const SizedBox(height: 12),
                                Container(width: 160, height: 1.6, color: Ae.gold),
                                const SizedBox(height: 12),
                                Text('EVERY FALL REWRITES THE TALE',
                                    style: Ae.label(14, c: Ae.goldSoft)),
                              ],
                            )
                          : Text(
                              b.text,
                              key: ValueKey(_i),
                              textAlign: TextAlign.center,
                              style: Ae.body(21, w: 600, h: 1.5),
                            ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _beats.length,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: i <= _i ? 16 : 8,
                          height: 3,
                          color: i <= _i ? Ae.gold : Ae.panelHi,
                        ),
                      ),
                    ),
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
