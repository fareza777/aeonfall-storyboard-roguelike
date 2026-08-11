import 'package:flutter/material.dart';

import '../theme.dart';
import 'widgets.dart';

/// Which part of the battle screen a coach mark points at.
enum TutTarget { none, energy, hand, foes, intent, combo, endTurn, log, hp }

class TutStep {
  const TutStep({
    required this.id,
    required this.title,
    required this.body,
    this.target = TutTarget.none,
    this.waitFor,
  });

  final String id;
  final String title;
  final String body;
  final TutTarget target;

  /// null = advance on tap. 'playCard' / 'endTurn' = wait for the real action.
  final String? waitFor;
}

/// The scripted first battle. Deliberately shallow: two required actions, the
/// rest is read-and-tap, so it can never dead-end.
const kTutorial = <TutStep>[
  TutStep(
    id: 'welcome',
    title: 'YOUR FIRST BATTLE',
    body: 'Take this one slowly. Nothing here happens until you tap.\n\n'
        'A battle is turns. On your turn you play cards. Then the foe moves. '
        'Then it is your turn again.',
  ),
  TutStep(
    id: 'hp',
    target: TutTarget.hp,
    title: 'THIS IS YOU',
    body: 'The red bar is your health. If it reaches zero, the run ends.\n\n'
        'A blue ⛨ number can appear above it — that is Guard, and it soaks up '
        'damage before your health does. Guard clears at the start of every turn, '
        'so spend it or lose it.',
  ),
  TutStep(
    id: 'energy',
    target: TutTarget.energy,
    title: 'ENERGY',
    body: 'The gold circle is your Energy. You get it back in full every turn.\n\n'
        'Every card costs Energy. When you run out, your turn is over.',
  ),
  TutStep(
    id: 'hand',
    target: TutTarget.hand,
    title: 'FRAMES',
    body: 'These cards are your Frames. Swipe sideways to see them all.\n\n'
        'The number in the top-left circle is what it costs. The text underneath '
        'says exactly what it does — no hidden rules.',
  ),
  TutStep(
    id: 'foes',
    target: TutTarget.foes,
    title: 'YOUR FOE',
    body: 'Its health bar sits under its name.\n\n'
        'Below that are its conditions — things currently stuck to it, good or bad.',
  ),
  TutStep(
    id: 'intent',
    target: TutTarget.intent,
    title: 'IT TELLS YOU ITS PLAN',
    body: 'The red badge above the foe is its INTENT. It is not a guess — it is '
        'exactly what it will do on its next turn.\n\n'
        '⚔ 6 means it hits you for 6.  ⚔ 6 ×3 means three hits of 6.  '
        '⛨ means it is defending instead.\n\n'
        'Read it every turn. That is the whole skill of this game.',
  ),
  TutStep(
    id: 'aura',
    target: TutTarget.foes,
    title: 'THE AURA',
    body: 'See the coloured chip under the foe — ✹ Ember, ❄ Frost, ⚡ Volt, '
        '● Umbra or ☀ Lumen? That is its **aura**.\n\n'
        'Hit an aura with a DIFFERENT element and the two collide into a '
        '**Reaction** — a big free bonus effect.\n\n'
        'Your card\'s element is the small symbol in its top-right corner.',
  ),
  TutStep(
    id: 'play',
    target: TutTarget.hand,
    waitFor: 'playCard',
    title: 'NOW PLAY ONE',
    body: 'Tap a Frame to pick it up, then tap the foe to hit it.\n\n'
        'If only one foe is left alive, tapping the card plays it straight away.',
  ),
  TutStep(
    id: 'result',
    target: TutTarget.log,
    title: 'WHAT JUST HAPPENED',
    body: 'This strip narrates every single thing that resolves — damage, '
        'conditions, Reactions.\n\n'
        'If you ever lose track of why your health moved, it is written here.',
  ),
  TutStep(
    id: 'combo',
    target: TutTarget.combo,
    title: 'THE CINEMATIC',
    body: 'This meter fills when you play cards of the same element in one turn.\n\n'
        'Fill all three and your Vessel fires its signature move for free. It is '
        'the strongest thing you can do, and it costs nothing but planning.',
  ),
  TutStep(
    id: 'endturn',
    target: TutTarget.endTurn,
    waitFor: 'endTurn',
    title: 'END YOUR TURN',
    body: 'Spend what Energy you can, then tap End Turn.\n\n'
        'Any cards left in your hand are discarded — holding on to them does '
        'nothing. Then the foe moves.',
  ),
  TutStep(
    id: 'enemy',
    title: 'WATCH IT MOVE',
    body: 'The foe lights up red when it acts, one at a time, and it does '
        'exactly what its Intent said it would.\n\n'
        'Nothing is hidden from you. If you got hurt, it was on the badge.',
  ),
  TutStep(
    id: 'done',
    title: 'THAT IS EVERYTHING',
    body: 'Read the intent. Decide whether to block it or race it. Chain your '
        'elements for Reactions and Cinematics.\n\n'
        'Finish this fight and the run is yours. You can reopen this guide any '
        'time from HOW TO PLAY in the Sanctum.',
  ),
];

/// Dims the screen except for one rectangle, and floats an explanation card
/// on the opposite half so it never covers what it is pointing at.
class CoachOverlay extends StatelessWidget {
  const CoachOverlay({
    super.key,
    required this.step,
    required this.rect,
    required this.index,
    required this.total,
    required this.onNext,
    required this.onSkip,
  });

  final TutStep step;
  final Rect? rect;
  final int index;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final r = rect;
    // Sit at the bottom by default and only jump to the top when the highlight
    // is genuinely down there, so the card is not bouncing around every step.
    final cardAtTop = r != null && r.center.dy > size.height * .62;

    // On a step that asks you to act, barely dim at all — you need to see and
    // reach the foes, not just the highlighted corner.
    final acting = step.waitFor != null;
    final painter = CustomPaint(painter: _SpotlightPainter(r, dim: acting ? .30 : .85));
    return Stack(
      children: [
        // While explaining, the scrim swallows taps so you cannot accidentally
        // play a card through it. On a step that asks you to *do* something, it
        // lets everything through instead.
        Positioned.fill(
          child: step.waitFor == null
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: painter,
                )
              : IgnorePointer(child: painter),
        ),
        Positioned(
          left: 14,
          right: 14,
          top: cardAtTop ? 76 : null,
          bottom: cardAtTop ? null : 40,
          child: _card(context),
        ),
      ],
    );
  }

  Widget _card(BuildContext context) {
    final waiting = step.waitFor != null;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        decoration: BoxDecoration(
          color: const Color(0xFB0E1018),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Ae.gold, width: 1.8),
          boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 30)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(step.title, style: Ae.display(20))),
                Text('${index + 1}/$total', style: Ae.label(13)),
              ],
            ),
            const SizedBox(height: 10),
            Prose(step.body, size: 16),
            const SizedBox(height: 14),
            if (waiting)
              _pulse()
            else
              Row(
                children: [
                  Expanded(
                    child: AeButton(label: 'Got it', onTap: onNext),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onSkip,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      child: Text('SKIP', style: Ae.label(13, c: Ae.dim)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _pulse() => Row(
        children: [
          const _Blink(),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              step.waitFor == 'endTurn'
                  ? 'Waiting for you to end the turn…'
                  : 'Waiting for you to play a Frame…',
              style: Ae.body(15, c: Ae.goldSoft, w: 600),
            ),
          ),
          GestureDetector(
            onTap: onSkip,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
              child: Text('SKIP', style: Ae.label(13, c: Ae.dim)),
            ),
          ),
        ],
      );
}

class _Blink extends StatefulWidget {
  const _Blink();
  @override
  State<_Blink> createState() => _BlinkState();
}

class _BlinkState extends State<_Blink> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 850))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _c.drive(Tween(begin: .25, end: 1)),
        child: Container(
          width: 14,
          height: 14,
          decoration: const BoxDecoration(color: Ae.gold, shape: BoxShape.circle),
        ),
      );
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter(this.rect, {this.dim = .85});
  final Rect? rect;
  final double dim;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;
    final scrim = Paint()..color = Colors.black.withValues(alpha: dim);

    if (rect == null) {
      canvas.drawRect(full, scrim);
      return;
    }
    final hole = RRect.fromRectAndRadius(rect!.inflate(8), const Radius.circular(14));
    canvas.saveLayer(full, Paint());
    canvas.drawRect(full, scrim);
    canvas.drawRRect(hole, Paint()..blendMode = BlendMode.clear);
    canvas.restore();
    canvas.drawRRect(
      hole,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = Ae.gold,
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter old) =>
      old.rect != rect || old.dim != dim;
}
