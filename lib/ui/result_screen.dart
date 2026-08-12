import 'package:flutter/material.dart';

import '../audio.dart';
import '../data/chronicles.dart';
import '../data/endings.dart';
import '../data/narrative_model.dart';
import '../engine/rng.dart';
import '../game.dart';
import '../theme.dart';
import 'run_summary.dart';
import 'widgets.dart';

/// The top of the tower. Four doors, and the run decides which one means what.
class FinaleScreen extends StatefulWidget {
  const FinaleScreen({super.key});

  @override
  State<FinaleScreen> createState() => _FinaleScreenState();
}

class _FinaleScreenState extends State<FinaleScreen> {
  @override
  void initState() {
    super.initState();
    Audio.i.music('boss');
  }

  void _choose(EvChoice c, String key) {
    Audio.i.sfx('cinematic', volume: .9);
    final g = Game.i;
    final id = g.director!.pickEnding(key);
    g.finishRun(id, won: true);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => ResultScreen(endingId: id)),
      (r) => r.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final g = Game.i;
    final r = g.run!;
    final chron = chronicleById(r.chronicleId);
    final choices = g.director!.finaleChoices();
    const keys = ['pen', 'break', 'finish', 'walk'];

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: AeBackdrop(
          image: 'event_authors_study',
          dark: .70,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DRAFT ${chron.number}', style: Ae.label(13)),
                  const SizedBox(height: 8),
                  Text('THE DESK', style: Ae.display(34)),
                  const SizedBox(height: 18),
                  Prose(
                    'The pen is on the blotter where it has been for three thousand years. '
                    'The chair is empty because you are standing where the person who sat '
                    'in it used to stand.\n\n'
                    'There is nothing above this room. There never was. Whatever happens '
                    'to Aevum next is a decision somebody in this room is about to make, '
                    'and there is only one person in this room.\n\n'
                    '**What do you do?**',
                    size: 17,
                  ),
                  const SizedBox(height: 22),
                  AePanel(
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          'Torn Pages ${r.pages.length}/9 · Mercy ${r.mercy} · '
                          'Cruelty ${r.cruelty} · '
                          '${r.companions.isEmpty ? "alone" : "${r.companions.length} beside you"}',
                          style: Ae.body(15, c: Ae.goldSoft),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  for (var i = 0; i < choices.length; i++) ...[
                    AeButton(
                      label: choices[i].label,
                      sub: choices[i].hint,
                      big: true,
                      color: switch (i) {
                        0 => Ae.umbra,
                        1 => Ae.blood,
                        2 => Ae.lumen,
                        _ => Ae.frost,
                      },
                      onTap: () => _choose(choices[i], keys[i]),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Death, or an ending.
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.endingId});
  final String? endingId;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {

  @override
  void initState() {
    super.initState();
    Audio.i.music(widget.endingId == null ? 'event' : 'hub');
    if (widget.endingId != null) {
      Audio.i.voice(widget.endingId!);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _leave() {
    Audio.i.sfx('confirm');
    Audio.i.stopVoice();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.endingId == null ? null : endingById(widget.endingId!);
    final m = Game.i.meta;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Art(e?.art ?? 'brand_defeat'),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Ae.ink.withValues(alpha: .70),
                    Ae.ink.withValues(alpha: .86),
                    Ae.ink,
                  ],
                  stops: const [0, .40, .78],
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (e == null) ...[
                      Text('THE DRAFT ENDS', style: Ae.label(14, c: Ae.blood)),
                      const SizedBox(height: 10),
                      Text('YOU FALL', style: Ae.display(40)),
                      const SizedBox(height: 20),
                      Prose(
                        'Somebody will find you in the road. They will straighten your '
                        'hands and close your eyes, the way it has been done forty-one '
                        'times before.\n\n'
                        'Then they will keep walking, because that is what all of you do.\n\n'
                        '**The page turns. It always turns.**',
                        size: 17,
                      ),
                    ] else ...[
                      Text('ENDING · ${m.endings.length} OF 12 FOUND',
                          style: Ae.label(13)),
                      const SizedBox(height: 10),
                      Text(e.title, style: Ae.display(32)),
                      const SizedBox(height: 6),
                      Text(e.epitaph, style: Ae.body(16, c: Ae.goldSoft, w: 600)),
                      const SizedBox(height: 20),
                      Prose(e.body, size: 17),
                    ],
                    const SizedBox(height: 26),
                    if (Game.i.lastRun != null) ...[
                      RunSummary(
                        run: Game.i.lastRun!,
                        won: widget.endingId != null,
                      ),
                      const SizedBox(height: 26),
                    ],
                    AePanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('THE SANCTUM REMEMBERS', style: Ae.label(13)),
                          const SizedBox(height: 8),
                          Text(
                            '${m.shards} Aeon Shards · ${m.runs} runs · '
                            '${m.wins} finished · ${m.endings.length}/12 endings',
                            style: Ae.body(16, c: Ae.bone),
                          ),
                          const SizedBox(height: 8),
                          Text('Ascension ${m.ascension} — every foe is a little harder now.',
                              style: Ae.body(14, c: Ae.dim)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    AeButton(label: 'Return to the Sanctum', big: true, onTap: _leave),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        'seed ${seedToWords(DateTime.now().millisecondsSinceEpoch & 0xFFFFFF)}',
                        style: Ae.body(12, c: Ae.dim.withValues(alpha: .5)),
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
