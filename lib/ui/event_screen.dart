import 'package:flutter/material.dart';

import '../audio.dart';
import '../data/narrative_model.dart';
import '../data/story_digest.dart';
import '../game.dart';
import '../theme.dart';
import 'result_screen.dart';
import 'run_hud.dart';
import 'widgets.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key, required this.nodeId, this.mystery = false});
  final int nodeId;
  final bool mystery;

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  GameEvent? _ev;
  EvChoice? _picked;
  List<String> _results = [];
  bool _fatal = false;

  @override
  void initState() {
    super.initState();
    Audio.i.music('event');
    _ev = Game.i.director!.nextEvent(mystery: widget.mystery);
    final id = _ev?.id;
    if (id != null && id.startsWith('beat_act')) {
      final n = id.replaceAll('beat_act', '');
      Audio.i.voice('beat$n');
    }
  }

  @override
  void dispose() {
    Audio.i.stopVoice();
    super.dispose();
  }

  bool _visible(EvChoice c) {
    final r = Game.i.run!;
    if (c.hidden &&
        !(r.relics.contains('witness_stone') || r.relics.contains('hollow_key'))) {
      return false;
    }
    if (c.needFlag != null && !r.flag(c.needFlag!)) return false;
    return true;
  }

  bool _enabled(EvChoice c) {
    final r = Game.i.run!;
    if (c.needGold > 0 && r.gold < c.needGold) return false;
    if (c.needRelic != null && !r.relics.contains(c.needRelic!)) return false;
    if (c.needPages > 0 && r.pages.length < c.needPages) return false;
    return true;
  }

  void _choose(EvChoice c) {
    Audio.i.sfx('confirm');
    Audio.i.stopVoice();
    final d = Game.i.director!;
    final r = Game.i.run!;
    if (c.needGold > 0) r.gold -= c.needGold;
    final out = <String>[];
    for (final o in c.out) {
      final s = d.applyOutcome(o);
      if (s.isNotEmpty) out.add(s);
      if (o.kind == OutKind.page) Audio.i.sfx('page');
      if (o.kind == OutKind.relic) Audio.i.sfx('relic');
      if (o.kind == OutKind.shards) Game.i.meta.shards += o.value;
    }
    setState(() {
      _picked = c;
      _results = out;
      _fatal = Game.i.checkDeathOutsideBattle();
    });
    if (_fatal) _results.add('This is what killed you.');
    Game.i.save();
  }

  void _leave() {
    Audio.i.sfx('tap');
    if (_fatal) {
      Audio.i.sfx('defeat', volume: .8);
      Game.i.die();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ResultScreen(endingId: null)),
        (route) => route.isFirst,
      );
      return;
    }
    Game.i.completeNode(widget.nodeId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ev = _ev;
    if (ev == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('The panel is blank.', style: Ae.display(22)),
              const SizedBox(height: 12),
              Text('Nothing was drawn here. Move on.',
                  textAlign: TextAlign.center, style: Ae.body(16, c: Ae.dim)),
              const SizedBox(height: 22),
              AeButton(label: 'Continue', onTap: _leave),
            ]),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Column(
          children: [
            RunHud(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          height: 210,
                          width: double.infinity,
                          child: Art(ev.art),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Ae.ink.withValues(alpha: .55),
                                  Ae.ink,
                                ],
                                stops: const [.35, .75, 1],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 18,
                          right: 18,
                          bottom: 12,
                          child: Text(ev.title, style: Ae.display(24)),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
                      child: _picked == null ? _prompt(ev) : _outcome(),
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

  Widget _prompt(GameEvent ev) {
    final plain = ev.plain ?? StoryDigest.beatPlain[ev.id];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Prose(ev.body, size: 17),
        if (plain != null) ...[
          const SizedBox(height: 18),
          AePanel(
            border: Ae.frost,
            fill: const Color(0xCC101826),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.lightbulb_outline, color: Ae.frost, size: 19),
                  const SizedBox(width: 8),
                  Text('WHAT THIS MEANS', style: Ae.label(13, c: Ae.frost)),
                ]),
                const SizedBox(height: 9),
                Text(plain, style: Ae.body(16, c: Ae.bone, h: 1.55)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 22),
          for (final c in ev.choices.where(_visible)) ...[
            AeButton(
              label: c.label,
              sub: c.hint,
              enabled: _enabled(c),
              color: c.hidden ? Ae.umbra : Ae.gold,
              onTap: () => _choose(c),
            ),
            const SizedBox(height: 11),
          ],
      ],
    );
  }

  Widget _outcome() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Prose(_picked!.result, size: 17),
          if (_results.isNotEmpty) ...[
            const SizedBox(height: 20),
            AePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CONSEQUENCE', style: Ae.label(13)),
                  const SizedBox(height: 8),
                  for (final s in _results)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text('· $s', style: Ae.body(16, c: Ae.goldSoft, w: 600)),
                    ),
                ],
              ),
            ),
          ],
          if (_fatal) ...[
            const SizedBox(height: 18),
            AePanel(
              border: Ae.blood,
              glow: Ae.blood,
              child: Row(children: [
                const Icon(Icons.close, color: Ae.blood, size: 22),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    'That took the last of you. The run ends here.',
                    style: Ae.body(16.5, c: Ae.blood, w: 700, h: 1.4),
                  ),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 24),
          AeButton(
            label: _fatal ? 'You fall' : 'Walk on',
            big: true,
            color: _fatal ? Ae.blood : Ae.gold,
            onTap: _leave,
          ),
        ],
      );
}
