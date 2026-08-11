import 'package:flutter/material.dart';

import '../audio.dart';
import '../engine/core.dart';
import '../game.dart';
import '../theme.dart';
import 'result_screen.dart';
import 'run_hud.dart';
import 'widgets.dart';

class RewardScreen extends StatefulWidget {
  const RewardScreen({
    super.key,
    required this.nodeId,
    required this.gold,
    required this.title,
    required this.blurb,
    required this.art,
    this.relic = false,
    this.cards = false,
    this.isBoss = false,
  });

  final int nodeId;
  final int gold;
  final bool relic;
  final bool cards;
  final bool isBoss;
  final String title;
  final String blurb;
  final String art;

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  bool _goldTaken = false;
  bool _relicTaken = false;
  bool _cardTaken = false;
  late final List<CardDef> _offer = Game.i.director!.cardReward();
  late final RelicDef _relic = Game.i.director!.relicReward();

  bool get _done =>
      _goldTaken && (!widget.relic || _relicTaken) && (!widget.cards || _cardTaken);

  @override
  void initState() {
    super.initState();
    Audio.i.music(widget.isBoss ? 'hub' : 'map');
  }

  void _continue() {
    Audio.i.sfx('confirm');
    final g = Game.i;
    g.completeNode(widget.nodeId);
    if (!widget.isBoss) {
      Navigator.of(context).pop();
      return;
    }
    if (g.run!.act >= 3) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const FinaleScreen()),
        (r) => r.isFirst,
      );
    } else {
      g.nextAct();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
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
                        SizedBox(height: 168, width: double.infinity, child: Art(widget.art)),
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
                          right: 18,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.title, style: Ae.display(24)),
                              const SizedBox(height: 4),
                              Text(widget.blurb, style: Ae.body(15, c: Ae.dim)),
                            ],
                          ),
                        ),
                      ]),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _goldRow(),
                            if (widget.relic) ...[
                              const SizedBox(height: 14),
                              _relicRow(),
                            ],
                            if (widget.cards) ...[
                              const SizedBox(height: 20),
                              Text('CHOOSE A FRAME', style: Ae.label(14)),
                              const SizedBox(height: 10),
                              _cardOffer(),
                            ],
                            const SizedBox(height: 26),
                            AeButton(
                              label: _done ? 'Continue' : 'Skip the rest and continue',
                              big: true,
                              color: _done ? Ae.gold : Ae.dim,
                              onTap: _continue,
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

  Widget _goldRow() => GestureDetector(
        onTap: _goldTaken
            ? null
            : () {
                Audio.i.sfx('coin');
                setState(() {
                  Game.i.run!.gold += widget.gold;
                  _goldTaken = true;
                });
                Game.i.saveRun();
              },
        child: AePanel(
          border: _goldTaken ? Ae.panelHi : Ae.gold,
          child: Row(children: [
            const Text('◈', style: TextStyle(fontSize: 30, color: Ae.gold)),
            const SizedBox(width: 14),
            Expanded(
              child: Text('${widget.gold} Aeon',
                  style: Ae.body(19, w: 800, c: _goldTaken ? Ae.dim : Ae.bone)),
            ),
            Text(_goldTaken ? 'TAKEN' : 'TAP TO TAKE', style: Ae.label(12)),
          ]),
        ),
      );

  Widget _relicRow() => GestureDetector(
        onTap: _relicTaken
            ? null
            : () {
                Audio.i.sfx('relic');
                setState(() {
                  Game.i.run!.addRelic(_relic.id);
                  _relicTaken = true;
                });
                Game.i.saveRun();
              },
        child: AePanel(
          border: _relicTaken ? Ae.panelHi : _relic.rarity.color,
          child: Row(children: [
            SizedBox(width: 52, height: 52, child: Art(_relic.artKey())),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_relic.name.toUpperCase(),
                    style: Ae.label(15, c: _relicTaken ? Ae.dim : Ae.bone)),
                const SizedBox(height: 4),
                Text(_relic.desc, style: Ae.body(15, c: Ae.dim)),
              ]),
            ),
          ]),
        ),
      );

  Widget _cardOffer() => SizedBox(
        height: 232,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _offer.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) {
            final c = _offer[i];
            return FrameCard(
              card: CardInst(c),
              width: 146,
              playable: !_cardTaken,
              onTap: _cardTaken
                  ? null
                  : () {
                      Audio.i.sfx('levelup');
                      setState(() {
                        Game.i.run!.addCard(c.id);
                        _cardTaken = true;
                      });
                      Game.i.saveRun();
                    },
            );
          },
        ),
      );
}
