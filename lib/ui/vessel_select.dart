import 'package:flutter/material.dart';

import '../audio.dart';
import '../data/vessels.dart';
import '../engine/core.dart';
import '../engine/rng.dart';
import '../game.dart';
import '../theme.dart';
import 'map_screen.dart';
import 'widgets.dart';

class VesselSelectScreen extends StatefulWidget {
  const VesselSelectScreen({super.key});

  @override
  State<VesselSelectScreen> createState() => _VesselSelectScreenState();
}

class _VesselSelectScreenState extends State<VesselSelectScreen> {
  final _page = PageController(viewportFraction: .86);
  int _idx = 0;
  late int _seed = DateTime.now().millisecondsSinceEpoch & 0xFFFFFF;

  List<VesselDef> get _all => kVessels;

  @override
  void initState() {
    super.initState();
    _speak(_all.first.id);
  }

  Future<void> _speak(String id) => Audio.i.voice('vessel_$id');

  @override
  void dispose() {
    Audio.i.stopVoice();
    _page.dispose();
    super.dispose();
  }

  bool _isLocked(VesselDef v) => !Game.i.meta.vessels.contains(v.id);

  void _begin(VesselDef v) {
    Audio.i.sfx('confirm');
    Audio.i.stopVoice();
    Game.i.startRun(_seed, v.id);
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MapScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final list = _all;
    final v = list[_idx];
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Art(v.art, key: ValueKey(v.id)),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Ae.ink.withValues(alpha: .82),
                  Ae.ink.withValues(alpha: .62),
                  Ae.ink.withValues(alpha: .97),
                ],
                stops: const [0, .26, .52],
              ),
            ),
          ),
          Column(
            children: [
              AeBar('Choose a Vessel', onBack: () => Navigator.pop(context)),
              SizedBox(
                height: 168,
                child: PageView.builder(
                  controller: _page,
                  itemCount: list.length,
                  onPageChanged: (i) {
                    Audio.i.sfx('tap');
                    setState(() => _idx = i);
                    if (!_isLocked(list[i])) _speak(list[i].id);
                  },
                  itemBuilder: (_, i) {
                    final vd = list[i];
                    final locked = _isLocked(vd);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: AePanel(
                        border: i == _idx ? vd.elem.color : Ae.panelHi,
                        fill: Ae.ink2.withValues(alpha: .92),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 74,
                              height: 74,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Art(vd.crest, opacity: locked ? .3 : 1),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(vd.name, style: Ae.display(22)),
                                  Text(vd.title.toUpperCase(),
                                      style: Ae.label(13, c: vd.elem.color)),
                                  const SizedBox(height: 6),
                                  if (locked)
                                    Text('LOCKED · ${vd.unlockHint.isEmpty ? "Unlock in the Sanctum" : vd.unlockHint}',
                                        style: Ae.body(13, c: Ae.dim))
                                  else
                                    Row(children: [
                                      Text('♥ ${vd.hp}', style: Ae.body(14, c: Ae.blood, w: 700)),
                                      const SizedBox(width: 12),
                                      Text('⚡ ${vd.energy}',
                                          style: Ae.body(14, c: Ae.volt, w: 700)),
                                    ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 6, 22, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(v.blurb, style: Ae.body(17, c: Ae.goldSoft, w: 600)),
                      const SizedBox(height: 14),
                      AePanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PLAYSTYLE', style: Ae.label(13)),
                            const SizedBox(height: 6),
                            Text(v.playstyle, style: Ae.body(16, c: Ae.bone)),
                            const SizedBox(height: 14),
                            Text('CINEMATIC · ${v.cinematicName}',
                                style: Ae.label(13, c: v.elem.color)),
                            const SizedBox(height: 6),
                            Text(v.cinematic, style: Ae.body(16, c: Ae.bone)),
                            const SizedBox(height: 8),
                            Text('Fires when you play three ${v.elem.label} frames in one turn.',
                                style: Ae.body(14, c: Ae.dim)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(v.lore, style: Ae.body(16, c: Ae.dim, h: 1.6)),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Audio.i.sfx('tap');
                          setState(() =>
                              _seed = DateTime.now().millisecondsSinceEpoch & 0xFFFFFF);
                        },
                        child: AePanel(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SEED · tap to reroll', style: Ae.label(11)),
                              const SizedBox(height: 3),
                              Text(seedToWords(_seed),
                                  style: Ae.body(16, c: Ae.gold, w: 800)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
                child: AeButton(
                  label: _isLocked(v) ? 'Locked' : 'Fall as ${v.name}',
                  big: true,
                  color: v.elem.color,
                  enabled: !_isLocked(v),
                  onTap: _isLocked(v) ? null : () => _begin(v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
