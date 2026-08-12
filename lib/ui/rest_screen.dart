import 'package:flutter/material.dart';

import '../audio.dart';
import '../data/ascension.dart';
import '../data/narrative_model.dart';
import '../game.dart';
import '../theme.dart';
import 'run_hud.dart';
import 'widgets.dart';

class RestScreen extends StatefulWidget {
  const RestScreen({super.key, required this.nodeId});
  final int nodeId;

  @override
  State<RestScreen> createState() => _RestScreenState();
}

class _RestScreenState extends State<RestScreen> {
  bool _used = false;
  String? _log;
  Companion? _offer;

  @override
  void initState() {
    super.initState();
    Audio.i.music('event');
    _offer = Game.i.director!.offerCompanion();
  }

  @override
  void dispose() {
    Audio.i.stopVoice();
    super.dispose();
  }

  void _finish() {
    Audio.i.sfx('tap');
    Game.i.completeNode(widget.nodeId);
    Navigator.of(context).pop();
  }

  void _rest() {
    final r = Game.i.run!;
    var amount = (r.maxHp * .32 * AscensionRules(r.ascension).restHealing).round();
    if (r.relics.contains('chalk_stub')) amount += 12;
    r.heal(amount);
    Audio.i.sfx('heal');
    setState(() {
      _used = true;
      _log = 'You sleep without dreaming. +$amount HP.';
    });
    Game.i.saveRun();
  }

  void _forge() {
    final r = Game.i.run!;
    final ups = r.deck.where((c) => c.canUpgrade).toList();
    if (ups.isEmpty) {
      setState(() => _log = 'Nothing left to sharpen.');
      return;
    }
    Audio.i.sfx('draw', volume: .5);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * .78,
        decoration: const BoxDecoration(
          color: Ae.ink2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          border: Border(top: BorderSide(color: Ae.gold, width: 2)),
        ),
        child: Column(children: [
          const SizedBox(height: 14),
          Text('SHARPEN A FRAME', style: Ae.display(21)),
          const SizedBox(height: 4),
          Text('Stronger at the break. Always is.', style: Ae.body(15, c: Ae.dim)),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(14),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1 / 1.52,
              ),
              itemCount: ups.length,
              itemBuilder: (_, i) => FrameCard(
                card: ups[i],
                width: 108,
                onTap: () {
                  Audio.i.sfx('levelup');
                  ups[i].upgraded = true;
                  Game.i.saveRun();
                  Navigator.pop(context);
                  setState(() {
                    _used = true;
                    _log = '${ups[i].def.name} is sharper now.';
                  });
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _recruit() {
    final c = _offer!;
    Audio.i.sfx('relic');
    Audio.i.voice('comp_${c.id}');
    Game.i.director!.recruit(c.id);
    Game.i.save();
    setState(() {
      _used = true;
      _offer = null;
      _log = '${c.name} walks with you now.';
    });
  }

  void _study() {
    final r = Game.i.run!;
    final gain = 8 * r.pages.length;
    Game.i.meta.shards += gain;
    Audio.i.sfx('page');
    setState(() {
      _used = true;
      _log = 'You read what you have of the original. +$gain Aeon Shards for the Sanctum.';
    });
    Game.i.save();
  }

  @override
  Widget build(BuildContext context) {
    final r = Game.i.run!;
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
                    Stack(children: [
                      SizedBox(
                          height: 190, width: double.infinity, child: Art('site_restsite')),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Ae.ink],
                              stops: const [.3, 1],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        bottom: 10,
                        child: Text('RESPITE', style: Ae.display(26)),
                      ),
                    ]),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'A fire between two broken statues. It will hold for one night, '
                            'and one night is all anybody has ever been given here.',
                            style: Ae.body(16, c: Ae.dim, h: 1.55),
                          ),
                          const SizedBox(height: 20),
                          if (_offer != null && !_used) ...[
                            AePanel(
                              border: Ae.gold,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    SizedBox(
                                      width: 64,
                                      height: 64,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Art(_offer!.art),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(_offer!.name, style: Ae.display(20)),
                                          Text(_offer!.title.toUpperCase(),
                                              style: Ae.label(12)),
                                        ],
                                      ),
                                    ),
                                  ]),
                                  const SizedBox(height: 12),
                                  Prose(_offer!.recruit, size: 16),
                                  const SizedBox(height: 12),
                                  Text('${_offer!.perk.toUpperCase()} · ${_offer!.perkDesc}',
                                      style: Ae.body(15, c: Ae.goldSoft, w: 600)),
                                  const SizedBox(height: 14),
                                  AeButton(label: 'Let them come', onTap: _recruit),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                          if (_log != null) ...[
                            AePanel(
                              border: Ae.good,
                              child: Text(_log!, style: Ae.body(16, c: Ae.bone)),
                            ),
                            const SizedBox(height: 18),
                          ],
                          if (!_used) ...[
                            AeButton(
                              label: 'Sleep',
                              sub: 'Recover ${(r.maxHp * .32).round()} HP',
                              onTap: _rest,
                            ),
                            const SizedBox(height: 11),
                            AeButton(
                              label: 'Sharpen a Frame',
                              sub: 'Permanently upgrade one card',
                              color: Ae.frost,
                              onTap: _forge,
                            ),
                            if (r.pages.isNotEmpty) ...[
                              const SizedBox(height: 11),
                              AeButton(
                                label: 'Read the Torn Pages',
                                sub: '${r.pages.length} pages · +${8 * r.pages.length} Shards',
                                color: Ae.lumen,
                                onTap: _study,
                              ),
                            ],
                            const SizedBox(height: 18),
                          ],
                          AeButton(
                            label: 'Move on',
                            big: true,
                            color: _used ? Ae.gold : Ae.dim,
                            onTap: _finish,
                          ),
                        ],
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
