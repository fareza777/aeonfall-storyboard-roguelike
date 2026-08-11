import 'package:flutter/material.dart';

import '../data/story_digest.dart';
import '../engine/core.dart';
import '../engine/map_gen.dart';
import '../theme.dart';
import 'widgets.dart';

/// A permanent, plain-language reference. Reachable any time from the Sanctum.
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: [
            AeBar('How to Play', onBack: () => Navigator.pop(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
                children: [
                  _section('1 · THE POINT', [
                    'Climb three Acts. Each Act is a branching map; you pick one node '
                        'per row and fight your way to a boss at the top.',
                    'Battles are card battles. You win by reducing every foe to 0 health '
                        'before they do the same to you.',
                    'When you die, the run ends — but the Sanctum keeps your Aeon Shards, '
                        'so the next run starts stronger. Dying is part of it.',
                  ]),
                  _section('2 · ONE TURN, STEP BY STEP', [
                    'You draw 5 Frames (cards) and get 3 Energy.',
                    'Play any Frames you can afford. Tap a Frame to select it, then tap a '
                        'foe to aim. With only one foe alive it fires immediately.',
                    'Tap END TURN when you are done.',
                    'Your leftover Guard disappears, your hand is discarded, and then each '
                        'foe acts one at a time — you will see it light up red.',
                    'New turn: full Energy, fresh hand of 5.',
                  ]),
                  _section('3 · READ THE FOE FIRST', [
                    'Every foe shows an INTENT badge above it. It is not a hint — it is '
                        'exactly what it will do next turn.',
                    '⚔ 12 means one hit for 12. ⚔ 6 ×3 means three hits of 6 (so 18, but '
                        'Guard has to stop each hit separately).',
                    '⛨ means it is defending. ▲ means it is buffing itself. ▼ means it is '
                        'about to weaken you. ✦ means a special move — the text says which.',
                    'Decide every turn: can I kill it before it swings, or should I block?',
                  ]),
                  _section('4 · GUARD IS NOT HEALTH', [
                    'Guard (the blue ⛨ number) absorbs damage first. Health only drops '
                        'once Guard is gone.',
                    'Guard is wiped at the start of your next turn. Guard you did not need '
                        'is Guard you wasted — but so is health you did not protect.',
                    'Some effects ignore Guard entirely. Those cards say so.',
                  ]),
                  _elements(),
                  _section('6 · THE CINEMATIC', [
                    'Play three Frames of the SAME element in one turn and your Vessel '
                        'fires its signature move for free.',
                    'The meter above your hand shows how close you are. It resets every '
                        'turn, so it rewards planning a single big turn instead of '
                        'dribbling cards out.',
                  ]),
                  _nodes(),
                  _section('8 · BETWEEN RUNS', [
                    'Aeon Shards are permanent. Spend them in the Sanctum on max health, '
                        'starting gold, extra sigils and new Vessels.',
                    'Every win raises your Ascension level, which makes foes tougher '
                        'forever. That is the long game.',
                    'The Codex fills in as you play: every foe you meet, every ending you '
                        'reach, every condition explained.',
                  ]),
                  _story(),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _section(String title, List<String> lines) => Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: AePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Ae.label(14)),
              const SizedBox(height: 12),
              for (final l in lines) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8, right: 10),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            color: Ae.gold, shape: BoxShape.circle),
                      ),
                    ),
                    Expanded(child: Text(l, style: Ae.body(16, h: 1.55))),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      );

  Widget _elements() {
    const elems = [Elem.ember, Elem.frost, Elem.volt, Elem.umbra, Elem.lumen];
    final pairs = <List<Elem>>[];
    for (var i = 0; i < elems.length; i++) {
      for (var j = i + 1; j < elems.length; j++) {
        pairs.add([elems[i], elems[j]]);
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: AePanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('5 · ELEMENTS AND REACTIONS', style: Ae.label(14)),
            const SizedBox(height: 12),
            Text(
              'Every foe wears its own element as an aura — the coloured chip under its '
              'health bar. Hit that aura with a DIFFERENT element and the two collide '
              'into a free bonus effect called a Reaction.\n\n'
              'Your card\'s element is the symbol in its top-right corner. After a '
              'Reaction the aura returns two turns later, so you can do it again.',
              style: Ae.body(16, h: 1.55),
            ),
            const SizedBox(height: 16),
            for (final p in pairs)
              Builder(builder: (_) {
                final id = reactionFor(p[0], p[1]);
                if (id == null) return const SizedBox.shrink();
                final r = kReactions[id]!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 54,
                        child: Text('${p[0].glyph}${p[1].glyph}',
                            style: TextStyle(fontSize: 19, color: p[0].color)),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name, style: Ae.label(14, c: r.color)),
                            Text(r.blurb, style: Ae.body(14.5, c: Ae.dim)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _nodes() {
    const info = {
      NodeType.battle: 'An ordinary fight. Rewards Aeon and a choice of Frame.',
      NodeType.elite: 'A much harder fight. Also drops a Sigil. Worth it if you can win.',
      NodeType.boss: 'The end of the Act. Beat it to move on.',
      NodeType.event: 'A story scene with choices. Some choices have hidden options.',
      NodeType.shop: 'Buy Frames and Sigils, or pay to burn a card out of your deck.',
      NodeType.rest: 'Sleep to heal, sharpen a Frame, or recruit a companion.',
      NodeType.treasure: 'Free Aeon and a Sigil, no fight.',
      NodeType.mystery: 'Could be anything. Usually a story scene.',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: AePanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('7 · THE MAP', style: Ae.label(14)),
            const SizedBox(height: 6),
            Text('You always move upward, one row at a time. Lines show where you can '
                'go next — plan a route, not just a step.',
                style: Ae.body(16, h: 1.55)),
            const SizedBox(height: 14),
            for (final e in info.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 38,
                      height: 38,
                      child: ClipOval(child: Art(e.key.icon)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.key.label, style: Ae.label(13, c: Ae.bone)),
                          const SizedBox(height: 2),
                          Text(e.value, style: Ae.body(14.5, c: Ae.dim)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _story() => AePanel(
        border: Ae.frost,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('9 · THE STORY, PLAINLY', style: Ae.label(14, c: Ae.frost)),
            const SizedBox(height: 12),
            for (var i = 0; i < StoryDigest.premise.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 26,
                    child: Text('${i + 1}.', style: Ae.body(15, c: Ae.gold, w: 800)),
                  ),
                  Expanded(
                    child: Text(StoryDigest.premise[i], style: Ae.body(16, h: 1.55)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 4),
            Text(
              'Everything else — the Chronicles, the companions, the twists — is detail '
              'hung on those nine lines. If you ever feel lost, open THE STORY SO FAR '
              'from the map and it will tell you exactly where you are.',
              style: Ae.body(15, c: Ae.dim, h: 1.55),
            ),
          ],
        ),
      );
}
