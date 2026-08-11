import 'package:flutter/material.dart';

import '../audio.dart';
import '../game.dart';
import '../theme.dart';
import 'hub.dart';
import 'widgets.dart';

class _Page {
  const _Page(this.art, this.kicker, this.title, this.body);
  final String art;
  final String kicker;
  final String title;
  final String body;
}

const _pages = <_Page>[
  _Page(
    'brand_onboard_1',
    'THE WORLD',
    'It was drawn.',
    'Aevum was never created. It was **drawn** — panel by panel, life by life. When a '
        'story grows too tangled to finish, its Author does what every artist does: '
        'crumples the page and starts again.\n\n'
        'That is a **Fall**. There have been three thousand of them. Nobody remembers, '
        'because memory is drawn too.',
  ),
  _Page(
    'brand_onboard_2',
    'THE FIGHT',
    'Frames, elements, reactions.',
    'You fight by playing **Frames** — cards drawn from your deck each turn.\n\n'
        'Every foe wears its own element as an **aura**. Hit that aura with a different '
        'element and it **reacts**: Ember into Frost vaporises, Volt into Lumen calls '
        'down judgment, Umbra into Lumen eclipses.\n\n'
        'Play three frames of one element in a single turn and your Vessel fires its '
        '**Cinematic** — a signature panel that ends arguments.',
  ),
  _Page(
    'brand_onboard_3',
    'THE CATCH',
    'You are not new here.',
    'You are a **Vessel** — a character drawn too well to erase. Every Fall, the Author '
        'wipes you and reuses you.\n\n'
        'This run is the first time one of you woke up **before the end**.\n\n'
        'The map branches. Companions join you, and one of them is carrying an instruction '
        'they were given before you met. No two runs will hand you the same story.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _idx = 0;

  void _finish() {
    Audio.i.sfx('confirm');
    Game.i.meta.onboarded = true;
    Game.i.saveMeta();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const HubScreen()));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _idx == _pages.length - 1;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _ctrl,
            itemCount: _pages.length,
            onPageChanged: (i) {
              Audio.i.sfx('page', volume: .5);
              setState(() => _idx = i);
            },
            itemBuilder: (_, i) {
              final p = _pages[i];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Art(p.art),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Ae.ink.withValues(alpha: .55),
                          Ae.ink.withValues(alpha: .80),
                          Ae.ink.withValues(alpha: .97),
                        ],
                        stops: const [0, .38, .72],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 160),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.kicker, style: Ae.label(15)),
                          const SizedBox(height: 10),
                          Text(p.title, style: Ae.display(32)),
                          const SizedBox(height: 18),
                          Prose(p.body, size: 17),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 34,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: i == _idx ? 28 : 9,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _idx ? Ae.gold : Ae.panelHi,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AeButton(
                    label: last ? 'Enter the Sanctum' : 'Next',
                    big: true,
                    onTap: () {
                      if (last) {
                        _finish();
                      } else {
                        _ctrl.nextPage(
                            duration: const Duration(milliseconds: 320),
                            curve: Curves.easeOutCubic);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  if (!last)
                    TextButton(
                      onPressed: _finish,
                      child: Text('Skip', style: Ae.body(15, c: Ae.dim)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
