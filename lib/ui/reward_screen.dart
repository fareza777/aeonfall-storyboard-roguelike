import 'package:flutter/material.dart';

import '../audio.dart';
import '../data/potions.dart';
import '../data/relics.dart';
import '../engine/core.dart';
import '../engine/pending_reward.dart';
import '../engine/run_state.dart';
import '../data/cards.dart';
import '../game.dart';
import '../monetization/monetization_service.dart';
import '../theme.dart';
import 'map_screen.dart';
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
    this.bossRelicId,
  });

  final int nodeId;
  final int gold;
  final bool relic;
  final bool cards;
  final bool isBoss;

  /// Set when a boss with a bespoke sigil has just gone down.
  final String? bossRelicId;
  final String title;
  final String blurb;
  final String art;

  factory RewardScreen.resume(PendingReward reward) => RewardScreen(
    nodeId: reward.nodeId,
    gold: reward.gold,
    relic: reward.relic,
    cards: reward.cards,
    isBoss: reward.isBoss,
    bossRelicId: reward.relicId,
    title: reward.title,
    blurb: reward.blurb,
    art: reward.art,
  );

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  late final RunState _run;
  late final PendingReward _reward;
  bool get _goldTaken => _reward.goldTaken;
  bool get _relicTaken => _reward.relicTaken;
  bool get _cardTaken => _reward.cardTaken;
  bool get _potionTaken => _reward.potionTaken;
  bool get _bonusWatched => _reward.bonusTaken;
  bool get _extraTaken => _reward.extraTaken;
  bool get _active =>
      identical(Game.i.run, _run) &&
      identical(_run.pendingReward, _reward) &&
      _run.canClaimReward;
  bool _watchBusy = false;
  List<CardDef> get _offer => _reward.cardIds.map(cardDef).toList();
  RelicDef get _relic => relicDef(_reward.relicId!);
  PotionDef? get _potion =>
      _reward.potionId == null ? null : potionDef(_reward.potionId!);
  RelicDef? get _extraRelic =>
      _reward.extraRelicId == null ? null : relicDef(_reward.extraRelicId!);

  bool get _done =>
      _goldTaken &&
      (!widget.relic || _relicTaken) &&
      (!widget.cards || _cardTaken);

  @override
  void initState() {
    super.initState();
    final g = Game.i;
    _run = g.run!;
    final saved = _run.pendingReward;
    if (saved != null &&
        saved.act == _run.act &&
        saved.nodeId == widget.nodeId) {
      _reward = saved;
    } else {
      final d = g.director!;
      _reward = PendingReward(
        act: _run.act,
        nodeId: widget.nodeId,
        gold: widget.gold,
        relic: widget.relic,
        cards: widget.cards,
        isBoss: widget.isBoss,
        title: widget.title,
        blurb: widget.blurb,
        art: widget.art,
        cardIds: widget.cards
            ? d.cardReward().map((c) => c.id).toList()
            : const [],
        relicId: widget.relic
            ? (widget.bossRelicId ?? d.relicReward().id)
            : null,
        potionId: d
            .potionDrop(
              widget.isBoss ? 'boss' : (widget.relic ? 'elite' : 'normal'),
            )
            ?.id,
        extraRelicId:
            widget.relic && !widget.isBoss && _run.relics.contains('keystone')
            ? d.relicReward().id
            : null,
      );
      final node = _run.map?.tryById(widget.nodeId);
      if (node != null &&
          !node.visited &&
          _run.map!.available.contains(node.id)) {
        _run.pendingReward = _reward;
        // Do not notify sibling routes while this route is being built.
        g.saveRun(notify: false);
      }
    }
    MonetizationService.i.addListener(_refreshAds);
    Audio.i.music(widget.isBoss ? 'hub' : 'map');
  }

  void _refreshAds() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    MonetizationService.i.removeListener(_refreshAds);
    super.dispose();
  }

  /// Guards against a second tap. The act-advance route transition takes a
  /// few hundred milliseconds, during which the button is still on screen and
  /// still looks live — and a second tap used to re-run the whole sequence
  /// against a map that had already been replaced.
  bool _leaving = false;

  void _continue() async {
    if (_leaving || _watchBusy) return;
    final canFinishBoss =
        identical(Game.i.run, _run) &&
        identical(_run.pendingReward, _reward) &&
        _reward.act == _run.act &&
        _reward.isBoss &&
        _reward.resolved;
    if (!_active && !canFinishBoss) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _leaving = true);
    Audio.i.sfx('confirm');
    final g = Game.i;
    if (!identical(g.run, _run)) return;
    g.completeNode(widget.nodeId);
    if (!widget.isBoss) {
      if (widget.cards) {
        await MonetizationService.i.showInterstitialIfDue(
          InterstitialBreak.combat,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }
    if (g.run!.act >= 3) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const FinaleScreen()),
        (r) => r.isFirst,
      );
      return;
    }
    await MonetizationService.i.showInterstitialIfDue(
      InterstitialBreak.actClear,
    );
    if (!mounted) return;
    g.nextAct();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MapScreen()),
      (r) => r.isFirst,
    );
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
                  Stack(
                    children: [
                      SizedBox(
                        height: 168,
                        width: double.infinity,
                        child: Art(widget.art),
                      ),
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
                    ],
                  ),
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
                        if (_extraRelic != null) ...[
                          const SizedBox(height: 14),
                          _relicRow(_extraRelic, true),
                        ],
                        if (_potion != null) ...[
                          const SizedBox(height: 14),
                          _potionRow(_potion!),
                        ],
                        if (widget.cards) ...[
                          const SizedBox(height: 20),
                          Text('CHOOSE A FRAME', style: Ae.label(14)),
                          const SizedBox(height: 10),
                          _cardOffer(),
                        ],
                        const SizedBox(height: 26),
                        AeButton(
                          label: _done
                              ? 'Continue'
                              : 'Skip the rest and continue',
                          big: true,
                          color: _done ? Ae.gold : Ae.dim,
                          enabled: !_watchBusy && !_leaving,
                          onTap: _continue,
                        ),
                        if (widget.cards &&
                            MonetizationService.i.rewardedReady &&
                            !_bonusWatched) ...[
                          const SizedBox(height: 10),
                          AeButton(
                            label: _watchBusy
                                ? 'Loading…'
                                : 'Watch for +${MonetizationService.combatWatchGold} Aeon',
                            color: Ae.volt,
                            enabled: !_watchBusy && !_leaving,
                            onTap: _watchGold,
                          ),
                        ],
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

  Future<void> _watchGold() async {
    if (_watchBusy || _bonusWatched || _leaving || !_active) return;
    final run = _run;
    setState(() => _watchBusy = true);
    final earned = await MonetizationService.i.showRewarded(
      onEarned: () {
        if (_active &&
            run.claimRewardBonus(MonetizationService.combatWatchGold)) {
          Game.i.saveRun();
        }
      },
    );
    if (!mounted) return;
    if (earned) {
      Audio.i.sfx('coin');
      setState(() {
        _watchBusy = false;
      });
    } else {
      setState(() => _watchBusy = false);
    }
  }

  Widget _goldRow() => GestureDetector(
    onTap: _goldTaken || !_active
        ? null
        : () {
            if (!_run.claimRewardGold()) return;
            Audio.i.sfx('coin');
            setState(() {});
            Game.i.saveRun();
          },
    child: AePanel(
      border: _goldTaken ? Ae.panelHi : Ae.gold,
      child: Row(
        children: [
          const Text('◈', style: TextStyle(fontSize: 30, color: Ae.gold)),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '${_reward.gold} Aeon',
              style: Ae.body(19, w: 800, c: _goldTaken ? Ae.dim : Ae.bone),
            ),
          ),
          Text(_goldTaken ? 'TAKEN' : 'TAP TO TAKE', style: Ae.label(12)),
        ],
      ),
    ),
  );

  Widget _relicRow([RelicDef? which, bool extra = false]) {
    final rel = which ?? _relic;
    final taken = extra ? _extraTaken : _relicTaken;
    return GestureDetector(
      onTap: taken || !_active
          ? null
          : () {
              if (!_run.claimRewardRelic(extra: extra)) return;
              Audio.i.sfx('relic');
              setState(() {});
              Game.i.saveRun();
            },
      child: AePanel(
        border: taken ? Ae.panelHi : rel.rarity.color,
        child: Row(
          children: [
            SizedBox(width: 52, height: 52, child: Art(rel.artKey())),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    extra
                        ? '${rel.name.toUpperCase()}  ·  KEYSTONE'
                        : rel.name.toUpperCase(),
                    style: Ae.label(15, c: taken ? Ae.dim : Ae.bone),
                  ),
                  const SizedBox(height: 4),
                  Text(rel.desc, style: Ae.body(15, c: Ae.dim)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A draught drop. If the belt is full the row says so rather than
  /// silently swallowing the tap.
  Widget _potionRow(PotionDef p) {
    final run = Game.i.run!;
    final c = p.elem == Elem.none ? Ae.gold : p.elem.color;
    final full = run.beltFull && !_potionTaken;
    return GestureDetector(
      onTap: _potionTaken || full || !_active
          ? null
          : () {
              if (!_run.claimRewardPotion()) return;
              Audio.i.sfx('relic');
              setState(() {});
              Game.i.saveRun();
            },
      child: AePanel(
        border: _potionTaken ? Ae.panelHi : (full ? Ae.blood : c),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: c.withValues(alpha: .9), width: 1.4),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [c.withValues(alpha: .38), c.withValues(alpha: .10)],
                ),
              ),
              child: Center(
                child: Text(
                  p.elem == Elem.none ? '◈' : p.elem.glyph,
                  style: TextStyle(fontSize: 22, color: c, height: 1),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name.toUpperCase(),
                    style: Ae.label(15, c: _potionTaken ? Ae.dim : Ae.bone),
                  ),
                  const SizedBox(height: 4),
                  Text(p.desc, style: Ae.body(15, c: Ae.dim)),
                  if (full) ...[
                    const SizedBox(height: 4),
                    Text(
                      'YOUR BELT IS FULL — DRINK ONE FIRST',
                      style: Ae.label(11, c: Ae.blood),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          playable: !_cardTaken && _active,
          onTap: _cardTaken || !_active
              ? null
              : () {
                  if (!_run.claimRewardCard(c.id)) return;
                  Audio.i.sfx('levelup');
                  setState(() {});
                  Game.i.saveRun();
                },
        );
      },
    ),
  );
}
