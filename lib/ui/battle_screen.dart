import 'dart:async';
import 'dart:math' as math;

// Flutter's own `Intent` clashes with the battle engine's enemy Intent.
import 'package:flutter/material.dart' hide Intent;
import 'package:flutter/services.dart';

import '../audio.dart';
import '../data/companion_aid.dart';
import '../data/companions.dart';
import '../data/potions.dart';
import '../data/relics_b.dart';
import '../engine/battle.dart';
import '../engine/core.dart';
import '../engine/map_gen.dart';
import '../game.dart';
import '../theme.dart';
import 'reward_screen.dart';
import 'result_screen.dart';
import 'tutorial.dart';
import 'widgets.dart';

/// Ring of pips around the energy dial — filled for available, hollow for spent.
class _EnergyPips extends CustomPainter {
  _EnergyPips({required this.total, required this.spent});
  final int total;
  final int spent;

  @override
  void paint(Canvas canvas, Size size) {
    if (total <= 0) return;
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 5.5;
    for (var i = 0; i < total; i++) {
      final a = -1.5708 + (i / total) * 6.2832;
      final p = c + Offset(r * math.cos(a), r * math.sin(a));
      final filled = i >= spent;
      canvas.drawCircle(
        p,
        2.6,
        Paint()
          ..color = filled ? Ae.gold : Ae.panelHi
          ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EnergyPips old) =>
      old.total != total || old.spent != spent;
}

class _Float {
  _Float(this.id, this.target, this.text, this.kind);
  final int id;
  final int target;
  final String text;
  final String kind;
}

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key, required this.nodeId, required this.type});
  final int nodeId;
  final NodeType type;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with TickerProviderStateMixin {
  CardInst? _selected;

  /// Impact shake. Driven directly rather than through an implicit animation
  /// so a hit lands on the frame it happens, not a beat later.
  late final AnimationController _shake = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 260));

  final List<_Float> _floats = [];
  int _floatId = 0;
  bool _busy = false;
  String? _banner;
  String? _phase;
  CardInst? _ghost;

  // --- guided tutorial -------------------------------------------------
  int _tut = -1;
  final _kEnergy = GlobalKey();
  final _kHand = GlobalKey();
  final _kFoes = GlobalKey();
  final _kIntent = GlobalKey();
  final _kCombo = GlobalKey();
  final _kEnd = GlobalKey();
  final _kLog = GlobalKey();
  final _kHp = GlobalKey();

  bool get _tutActive => _tut >= 0 && _tut < kTutorial.length;

  Battle get b => Game.i.battle!;

  @override
  void initState() {
    super.initState();
    b.deferCinematics = true; // announce it before it lands
    if (!Game.i.meta.tutorialDone && widget.type == NodeType.battle) {
      _tut = 0;
      // Recorded the moment it starts, not when it finishes. If this fight ends
      // early the tutorial is over for good rather than restarting every battle.
      Game.i.meta.tutorialDone = true;
      Game.i.saveMeta();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _drain());
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void _tutNext() {
    setState(() => _tut++);
    if (!_tutActive) _tutFinish();
  }

  void _tutSkip() {
    setState(() => _tut = -1);
    _tutFinish();
  }

  void _tutFinish() {
    _tut = -1;
    Game.i.meta.tutorialDone = true;
    Game.i.saveMeta();
  }

  /// Advances the script when the player performs the action it asked for.
  void _tutDid(String action) {
    if (!_tutActive || b.ended) return;
    if (kTutorial[_tut].waitFor == action) _tutNext();
  }

  Rect? _rectFor(TutTarget t) {
    final key = switch (t) {
      TutTarget.energy => _kEnergy,
      TutTarget.hand => _kHand,
      TutTarget.foes => _kFoes,
      TutTarget.intent => _kIntent,
      TutTarget.combo => _kCombo,
      TutTarget.endTurn => _kEnd,
      TutTarget.log => _kLog,
      TutTarget.hp => _kHp,
      TutTarget.none => null,
    };
    final ctx = key?.currentContext;
    final box = ctx?.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  // ---------------------------------------------------------- feedback
  /// Wraps the whole battle in the impact offset. Off entirely when the
  /// player has asked for reduced motion, so it costs nothing.
  Widget _shaken(Widget child) {
    if (Game.i.meta.reducedMotion) return child;
    return AnimatedBuilder(
      animation: _shake,
      builder: (_, inner) {
        if (_shake.value == 0) return inner!;
        // Decaying wobble rather than a single lurch — reads as impact, not
        // as a dropped frame.
        final decay = 1 - _shake.value;
        final dx = math.sin(_shake.value * math.pi * 7) * 9 * decay;
        final dy = math.cos(_shake.value * math.pi * 5) * 5 * decay;
        return Transform.translate(offset: Offset(dx, dy), child: inner);
      },
      child: child,
    );
  }

  /// One place decides what a hit feels like, so shake and buzz can never
  /// disagree with each other or with the player's settings.
  void _kick(String kind, {int amount = 0}) {
    final m = Game.i.meta;
    final heavy = kind == 'cinematic' || kind == 'reaction' || amount >= 14;
    if (!m.reducedMotion && (heavy || amount >= 6)) {
      _shake
        ..stop()
        ..value = 0
        ..animateTo(1, curve: Curves.easeOut);
    }
    if (!m.haptics) return;
    if (kind == 'cinematic') {
      HapticFeedback.heavyImpact();
    } else if (kind == 'reaction' || amount >= 14) {
      HapticFeedback.mediumImpact();
    } else if (amount > 0) {
      HapticFeedback.selectionClick();
    }
  }

  void _drain() {
    if (!mounted) return;
    final pops = List<Popup>.from(b.popups);
    b.popups.clear();
    if (pops.isEmpty) return;
    for (final p in pops) {
      final f = _Float(_floatId++, p.targetIdx, p.text, p.kind);
      _floats.add(f);
      Audio.i.forPopup(p.kind);
      // The player taking damage is the beat worth feeling; foes taking it is
      // just information.
      if (p.kind == 'damage' && p.targetIdx == -1) {
        _kick('damage', amount: int.tryParse(p.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0);
      } else if (p.kind == 'reaction') {
        _kick('reaction');
      }
      if (p.kind == 'reaction') {
        _banner = p.text;
        Timer(const Duration(milliseconds: 1300), () {
          if (mounted) setState(() => _banner = null);
        });
      }
      Timer(const Duration(milliseconds: 950), () {
        if (!mounted) return;
        setState(() => _floats.remove(f));
      });
    }
    setState(() {});
  }

  List<_Float> _floatsFor(int idx) => _floats.where((f) => f.target == idx).toList();

  // ------------------------------------------------------------ actions
  bool _needsTarget(CardInst c) {
    if (b.foes.where((f) => f.alive).length <= 1) return false;
    return c.fx.any((f) => f.target == FxTarget.enemy);
  }

  void _tapCard(CardInst c) {
    if (_busy || b.ended) return;
    if (!b.canPlay(c)) {
      Audio.i.sfx('back', volume: .4);
      return;
    }
    Audio.i.sfx('tap', volume: .4);
    if (_needsTarget(c)) {
      setState(() => _selected = _selected == c ? null : c);
    } else {
      _play(c, b.foes.indexWhere((f) => f.alive));
    }
  }

  void _tapFoe(int idx) {
    if (!b.foes[idx].alive) return;
    // With a frame in hand a tap means "hit this". Otherwise it means
    // "let me look at you properly".
    if (_selected == null) {
      _inspectFoe(idx);
      return;
    }
    _play(_selected!, idx);
  }

  /// Full-size portrait and complete dossier for one foe.
  void _inspectFoe(int idx) {
    final f = b.foes[idx];
    final d = f.def!;
    Audio.i.sfx('tap', volume: .4);

    aeSheet(
      context,
      title: f.displayName,
      subtitle: '${d.elem.label} · ${["Normal", "Elite", "Boss"][d.tier]}',
      accent: d.elem == Elem.none ? Ae.gold : d.elem.color,
      heightFactor: .88,
      trailing: Text('${f.hp}/${f.maxHp}', style: Ae.display(20, c: Ae.blood)),
      builder: (_) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
        children: [
          // big portrait
          AspectRatio(
            aspectRatio: 1,
            child: AePanel(
              padding: EdgeInsets.zero,
              border: d.elem == Elem.none ? Ae.gold : d.elem.color,
              ornament: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Art(d.artKey(), fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 16),
          HpBar(hp: f.hp, maxHp: f.maxHp, block: f.block, width: double.infinity, height: 26),
          const SizedBox(height: 14),
          if (f.st.isNotEmpty || f.aura != Elem.none) ...[
            StatusRow(f.st, aura: f.aura, size: 14),
            const SizedBox(height: 16),
          ],
          if (d.blurb.isNotEmpty) ...[
            Text(d.blurb, style: Ae.body(16, c: Ae.goldSoft, h: 1.55)),
            const SizedBox(height: 16),
          ],
          if (d.passiveDesc != null) ...[
            AePanel(
              border: Ae.frost,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ALWAYS ACTIVE', style: Ae.label(11, c: Ae.frost)),
                  const SizedBox(height: 7),
                  Text(d.passiveDesc!, style: Ae.body(16, c: Ae.bone, h: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (f.mods.isNotEmpty)
            for (final m in f.mods)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: AePanel(
                  border: Ae.umbra,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${m.toUpperCase()} — MUTATION', style: Ae.label(11, c: Ae.umbra)),
                      const SizedBox(height: 7),
                      Text(kEnemyMods[m] ?? '', style: Ae.body(16, c: Ae.bone, h: 1.5)),
                    ],
                  ),
                ),
              ),
          Text('ITS ROTATION', style: Ae.label(12)),
          const SizedBox(height: 4),
          Text('It cycles through these in order. The badge above it always '
              'shows which one is next.', style: Ae.body(13.5, c: Ae.dim, h: 1.45)),
          const SizedBox(height: 10),
          for (var i = 0; i < d.pattern.length; i++)
            _patternRow(d.pattern[i], i == f.patternIdx % d.pattern.length),
        ],
      ),
    );
  }

  Widget _patternRow(Intent it, bool next) {
    final (glyph, colour, text) = switch (it.kind) {
      IntentKind.attack || IntentKind.attackMulti => (
          '⚔',
          Ae.blood,
          it.times > 1
              ? 'Attacks ${it.times} times for ${it.value}'
              : 'Attacks for ${it.value}',
        ),
      IntentKind.block => ('⛨', Ae.frost, 'Guards ${it.value}'),
      IntentKind.buff => (
          '▲',
          Ae.gold,
          'Gains ${it.statusAmt} ${kStatus[it.status ?? 'strength']?.name ?? 'Strength'}',
        ),
      IntentKind.debuff => (
          '▼',
          Ae.umbra,
          'Applies ${it.statusAmt} ${kStatus[it.status ?? 'weak']?.name ?? 'Weak'}',
        ),
      IntentKind.sleep => ('☾', Ae.dim, 'Does not act'),
      _ => ('✦', Ae.volt, it.note ?? 'A special move'),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 24, child: Text(glyph, style: Ae.body(16, c: colour))),
          Expanded(
            child: Text(
              text + (it.status != null && it.kind != IntentKind.buff && it.kind != IntentKind.debuff
                  ? ', plus ${it.statusAmt} ${kStatus[it.status!]?.name ?? it.status!}'
                  : ''),
              style: Ae.body(15.5, c: next ? Ae.bone : Ae.dim, w: next ? 700 : 400, h: 1.45),
            ),
          ),
          if (next)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Ae.gold),
              ),
              child: Text('NEXT', style: Ae.label(9.5, c: Ae.gold)),
            ),
        ],
      ),
    );
  }

  void _play(CardInst c, int idx) {
    if (_busy) return;
    Audio.i.sfx('play', volume: .55);
    setState(() {
      _selected = null;
      _ghost = c; // brief flourish so a played frame reads as an action
      b.play(c, idx < 0 ? 0 : idx);
    });
    Timer(const Duration(milliseconds: 420), () {
      if (mounted) setState(() => _ghost = null);
    });
    _drain();
    _tutDid('playCard');
    if (b.pendingCinematic != null) {
      _runCinematic();
      return;
    }
    _checkEnd();
  }

  /// No spectacle. A short beat so you can register that it fired, the readout
  /// picks up a highlighted line, and the damage lands on the real board.
  Future<void> _runCinematic() async {
    setState(() {
      _busy = true;
      _phase = 'CINEMATIC · ${Game.i.run!.vessel.cinematicName}';
    });
    Audio.i.sfx('cinematic', volume: .8);
    _kick('cinematic');
    await Future<void>.delayed(Duration(
        milliseconds: Game.i.meta.reducedMotion ? 220 : 550));
    if (!mounted) return;

    b.resolveCinematic();
    _drain();
    setState(() {});
    await Future<void>.delayed(Duration(
        milliseconds: Game.i.meta.reducedMotion ? 300 : 750));
    if (!mounted) return;

    setState(() {
      _busy = false;
      _phase = null;
    });
    _checkEnd();
  }

  /// The enemy round is played one foe at a time, with the acting foe lit up
  /// and a pause between beats, so you can actually read what happened.
  Future<void> _endTurn() async {
    if (_busy || b.ended) return;
    _tutDid('endTurn');
    setState(() {
      _busy = true;
      _selected = null;
      _phase = 'YOUR TURN ENDS';
    });
    Audio.i.sfx('confirm', volume: .5);

    b.endPlayerTurn();
    _drain();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() => _phase = 'THE FOES MOVE');
    await Future<void>.delayed(const Duration(milliseconds: 450));

    while (mounted && !b.ended) {
      final acted = b.stepFoes();
      if (!acted) break;
      setState(() {});
      Audio.i.sfx('tap', volume: .35);
      await Future<void>.delayed(const Duration(milliseconds: 320));
      if (!mounted) return;
      _drain();
      await Future<void>.delayed(const Duration(milliseconds: 900));
    }
    if (!mounted) return;

    if (!b.ended) {
      setState(() => _phase = 'YOUR TURN');
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      b.beginNextTurn();
      _drain();
      Audio.i.sfx('draw', volume: .5);
    }
    setState(() {
      _busy = false;
      _phase = null;
    });
    _checkEnd();
  }

  void _checkEnd() {
    if (!b.ended) return;
    if (_tutActive) setState(() => _tut = -1); // the fight is over; stop coaching
    final won = b.victory;
    Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      final g = Game.i;
      if (won) {
        Audio.i.sfx('victory', volume: .8);
        final gold = b.goldReward;
        g.endBattle();
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => RewardScreen(
            nodeId: widget.nodeId,
            gold: gold,
            relic: widget.type != NodeType.battle,
            cards: true,
            isBoss: widget.type == NodeType.boss,
            // Bosses leave a sigil that only they drop.
            bossRelicId: widget.type == NodeType.boss && b.foes.isNotEmpty
                ? bossRelicFor(b.foes.first.def!.id)
                : null,
            title: switch (widget.type) {
              NodeType.boss => 'THE ACT ENDS',
              NodeType.elite => 'THE ELITE FALLS',
              _ => 'THE FRAME HOLDS',
            },
            blurb: 'You are still here. That is not nothing.',
            art: 'site_treasure_room',
          ),
        ));
      } else {
        Audio.i.sfx('defeat', volume: .8);
        g.die();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ResultScreen(endingId: null)),
          (route) => route.isFirst,
        );
      }
    });
  }

  // ------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    if (Game.i.battle == null) return const Scaffold(body: SizedBox.shrink());
    final live = b.foes;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: _shaken(Stack(
          fit: StackFit.expand,
          children: [
            Art(_bg()),
            DecoratedBox(decoration: BoxDecoration(color: Ae.ink.withValues(alpha: .80))),
            SafeArea(
              child: Column(
                children: [
                  _topBar(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: _phase == null
                        ? const SizedBox(height: 4, width: double.infinity)
                        : Container(
                            key: ValueKey(_phase),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 4),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: Ae.blood.withValues(alpha: .22),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Ae.blood.withValues(alpha: .8), width: 1.4),
                            ),
                            child: Text(_phase!,
                                textAlign: TextAlign.center,
                                style: Ae.label(15, c: Ae.bone)),
                          ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            // Size the portraits from the space actually left
                            // over, so three foes with several conditions each
                            // can never overflow into the readout below.
                            child: LayoutBuilder(
                              builder: (context, cons) {
                                final alive = live.where((f) => f.alive).length;
                                const chrome = 132.0; // intent, name, hp bar, chips, gaps
                                var art = cons.maxHeight - chrome;
                                final cap = alive >= 3 ? 104.0 : (alive == 2 ? 118.0 : 132.0);
                                art = art.clamp(58.0, cap);
                                return Row(
                                  key: _kFoes,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    for (var i = 0; i < live.length; i++)
                                      Flexible(child: _foeWidget(i, live[i], art)),
                                  ],
                                );
                              },
                            ),
                          ),
                          _readout(),
                        ],
                      ),
                    ),
                  ),
                  _heroBar(),
                  Expanded(flex: 4, child: _handArea()),
                ],
              ),
            ),
            if (_ghost != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: TweenAnimationBuilder<double>(
                      key: ValueKey(_ghost!.uid),
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeOutCubic,
                      builder: (_, t, child) => Opacity(
                        opacity: (1 - t * t).clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: .85 + t * .5,
                          child: Transform.translate(
                              offset: Offset(0, 60 - t * 130), child: child),
                        ),
                      ),
                      child: FrameCard(card: _ghost!, width: 150, showCost: false),
                    ),
                  ),
                ),
              ),
            if (_tutActive)
              CoachOverlay(
                step: kTutorial[_tut],
                rect: _rectFor(kTutorial[_tut].target),
                index: _tut,
                total: kTutorial.length,
                onNext: _tutNext,
                onSkip: _tutSkip,
              ),
            if (_banner != null)
              Center(
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    decoration: BoxDecoration(
                      color: Ae.ink.withValues(alpha: .9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Ae.gold, width: 2),
                      boxShadow: [BoxShadow(color: Ae.gold.withValues(alpha: .4), blurRadius: 30)],
                    ),
                    child: Text(_banner!, style: Ae.display(26, c: Ae.gold)),
                  ),
                ),
              ),
          ],
        )),
      ),
    );
  }

  String _bg() {
    final r = Game.i.run!;
    const a1 = ['biome_ashfall', 'biome_drowned', 'biome_ossuary'];
    const a2 = ['biome_clockwork', 'biome_bazaar', 'biome_stormspire'];
    const a3 = ['biome_unwritten', 'biome_vault', 'biome_thefall'];
    final pool = switch (r.act) { 1 => a1, 2 => a2, _ => a3 };
    return pool[(r.totalFloors + r.seed) % pool.length];
  }

  Widget _topBar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            // Scales itself down rather than pushing the pills off a narrow
            // screen.
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(children: [
                  Text('TURN ${b.turn}', style: Ae.label(13)),
                  const SizedBox(width: 12),
                  Text(switch (widget.type) {
                    NodeType.boss => 'BOSS',
                    NodeType.elite => 'ELITE',
                    _ => 'BATTLE',
                  }, style: Ae.label(13, c: Ae.blood)),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _pileSheet('DRAW PILE', b.drawPile,
                  subtitle: 'Shuffled — order is hidden until drawn'),
              child: _pill('DRAW', b.drawPile.length, Ae.frost),
            ),
            const SizedBox(width: 7),
            GestureDetector(
              onTap: () => _pileSheet('DISCARD', b.discard,
                  subtitle: 'Reshuffled into your draw pile when it runs dry'),
              child: _pill('DISC', b.discard.length, Ae.dim),
            ),
            const SizedBox(width: 7),
            GestureDetector(
              onTap: () => _pileSheet('EXHAUSTED', b.exhausted,
                  subtitle: 'Gone for the rest of this battle'),
              child: _pill('EXH', b.exhausted.length, Ae.umbra),
            ),
          ],
        ),
      );

  Widget _pill(String k, int v, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.withValues(alpha: .16), Colors.transparent],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.withValues(alpha: .55)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(k, style: Ae.label(9.5, c: c.withValues(alpha: .85))),
          const SizedBox(width: 5),
          Text('$v', style: Ae.body(13.5, c: c, w: 800, h: 1)),
        ]),
      );

  void _pileSheet(String title, List<CardInst> pile, {String? subtitle}) {
    Audio.i.sfx('draw', volume: .4);
    aeSheet(
      context,
      title: title,
      subtitle: subtitle,
      heightFactor: .72,
      trailing: Text('${pile.length}', style: Ae.display(24, c: Ae.gold)),
      builder: (_) => pile.isEmpty
          ? Center(child: Text('Empty.', style: Ae.body(16, c: Ae.dim)))
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 11,
                crossAxisSpacing: 11,
                childAspectRatio: 1 / 1.52,
              ),
              itemCount: pile.length,
              itemBuilder: (_, i) => FrameCard(card: pile[i], width: 108),
            ),
    );
  }

  /// The other half of the readout's promise. The panel answers "what is about
  /// to happen to me"; this answers "what am I about to do", on the foe it
  /// would happen to, before committing to it.
  Widget _forecastOverlay(Combatant f, double art) {
    final c = _selected;
    if (c == null) return const SizedBox.shrink();
    final n = b.previewDamage(c, f);
    if (n == null) return const SizedBox.shrink();
    final react = b.previewReaction(c, f);
    final lethal = n >= f.hp;
    return IgnorePointer(
      child: Container(
        color: Ae.ink.withValues(alpha: .34),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: Ae.ink.withValues(alpha: .88),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: lethal ? Ae.good : Ae.blood, width: 1.6),
            boxShadow: [
              BoxShadow(
                  color: (lethal ? Ae.good : Ae.blood).withValues(alpha: .5),
                  blurRadius: 12),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(react != null ? '−$n+' : '−$n',
                  style: Ae.display(art > 96 ? 25 : 21,
                      c: lethal ? Ae.good : Ae.bone)),
              if (lethal)
                Text('LETHAL', style: Ae.label(9.5, c: Ae.good))
              else if (react != null)
                Text(kReactions[react]!.name,
                    style: Ae.label(9, c: kReactions[react]!.color)),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------- foes
  Widget _foeWidget(int idx, Combatant f, double art) {
    if (!f.alive) {
      return const SizedBox(width: 8);
    }
    final targeting = _selected != null;
    final acting = b.actingFoe == idx;
    // While one foe is acting, the others recede — the eye goes where the
    // damage is coming from.
    final recede = b.actingFoe >= 0 && !acting;
    final intent = f.intent;
    return GestureDetector(
      onTap: () => _tapFoe(idx),
      child: AnimatedOpacity(
        opacity: recede ? .42 : 1,
        duration: const Duration(milliseconds: 240),
        child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // The column is laid out at its natural design size and then scaled
          // as a single unit to whatever cell it was given. Nothing inside can
          // clip, wrap oddly or slide under the readout — on any screen.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: art + 16,
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (intent != null)
                Container(
                    key: idx == 0 ? _kIntent : null,
                    child: _intentChip(f, intent, art + 16)),
              const SizedBox(height: 4),
              AnimatedScale(
                scale: acting ? 1.10 : 1.0,
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: acting
                          ? Ae.blood
                          : (targeting ? Ae.gold : Colors.transparent),
                      width: acting || targeting ? 2.6 : 0,
                    ),
                    boxShadow: acting
                        ? [BoxShadow(color: Ae.blood.withValues(alpha: .65), blurRadius: 26)]
                        : targeting
                            ? [BoxShadow(color: Ae.gold.withValues(alpha: .45), blurRadius: 18)]
                            : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: art,
                          height: art,
                          child: Art(f.def!.artKey()),
                        ),
                        // What the held frame would take off this foe, right
                        // now, after its Guard and both sides' conditions.
                        if (_selected != null)
                          Positioned.fill(child: _forecastOverlay(f, art)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(f.displayName,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Ae.body(13, w: 700, c: Ae.bone, h: 1.15)),
                  ),
                  const SizedBox(width: 4),
                  // affordance for "tap me to inspect"
                  Icon(Icons.zoom_in,
                      size: 14, color: Ae.dim.withValues(alpha: .75)),
                ],
              ),
              const SizedBox(height: 4),
              HpBar(hp: f.hp, maxHp: f.maxHp, block: f.block, width: art - 6, height: 18),
              const SizedBox(height: 5),
              // One fixed-height rail. Every condition stays visible and
              // tappable — swipe sideways if a foe is carrying a lot.
              SizedBox(
                width: art + 16,
                height: 22,
                child: StatusRow(f.st, aura: f.aura, size: 11, compact: true),
              ),
            ],
              ),
            ),
          ),
          for (var i = 0; i < _floatsFor(idx).length; i++)
            Positioned(top: 26.0 + i * 24, child: _floatText(_floatsFor(idx)[i])),
        ],
        ),
      ),
    );
  }

  /// THE READOUT — the instrument panel of the fight.
  ///
  /// Left half answers the only question that matters before you commit:
  /// *if I end my turn right now, how much do I actually take?* Right half is
  /// the resolution feed. Tapping it opens the full log.
  Widget _readout() {
    final infos = b.intentInfos();
    final incoming = b.incomingTotal;
    final through = b.incomingAfterGuard;
    final stopped = incoming - through;
    final lethal = through >= b.hero.hp && through > 0;
    final lines = b.log.length <= 2 ? b.log : b.log.sublist(b.log.length - 2);
    final accent = lethal ? Ae.blood : (through == 0 ? Ae.good : Ae.goldSoft);

    return GestureDetector(
      onTap: _openFullLog,
      child: Container(
        key: _kLog,
        margin: const EdgeInsets.only(top: 6),
        child: AePanel(
          padding: const EdgeInsets.fromLTRB(11, 8, 11, 8),
          border: accent,
          glow: lethal ? Ae.blood : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- header: the bottom line --------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(lethal ? 'LETHAL IF YOU END NOW' : 'IF YOU END NOW',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Ae.label(9.5, c: accent)),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      incoming == 0
                          ? 'nothing incoming'
                          : (stopped > 0 ? '$incoming raw · ⛨$stopped stopped' : 'no guard'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: Ae.body(10.5, c: Ae.dim, w: 600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('−$through', style: Ae.display(20, c: accent)),
                      const SizedBox(width: 3),
                      Text('HP', style: Ae.label(9, c: Ae.dim)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Container(height: 1, color: Ae.panelHi.withValues(alpha: .8)),
              const SizedBox(height: 5),

              // ---- one row per foe ----------------------------------
              for (final i in infos) _intentRow(i),

              if (lines.isNotEmpty) ...[
                const SizedBox(height: 5),
                Container(height: 1, color: Ae.panelHi.withValues(alpha: .5)),
                const SizedBox(height: 4),
                for (final l in lines) _logRow(l, trailing: l == lines.last),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// The full record, newest first, grouped under the round it happened in.
  Widget _recordList() {
    final rows = <Widget>[];
    var lastTurn = -1;

    for (var i = b.log.length - 1; i >= 0; i--) {
      final l = b.log[i];
      if (l.turn != lastTurn) {
        lastTurn = l.turn;
        rows.add(Padding(
          padding: EdgeInsets.only(top: rows.isEmpty ? 0 : 16, bottom: 8),
          child: Row(children: [
            Text(l.turn == 0 ? 'OPENING' : 'TURN ${l.turn}',
                style: Ae.label(11, c: Ae.gold)),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Ae.gold.withValues(alpha: .45),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ]),
        ));
      }
      rows.add(Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: _logRow(l, size: 15),
      ));
    }

    if (rows.isEmpty) {
      return Center(child: Text('Nothing has happened yet.',
          style: Ae.body(16, c: Ae.dim)));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      children: rows,
    );
  }

  /// Icon and colour for a record entry, by what kind of thing happened.
  static (String, Color) _logStyle(String kind) => switch (kind) {
        'card' => ('◈', Ae.goldSoft),
        'foe' => ('⚔', Ae.blood),
        'tick' => ('◦', Color(0xFF9C7FB8)),
        'reaction' => ('⚡', Ae.gold),
        'cinematic' => ('◆', Ae.lumen),
        'death' => ('✕', Ae.blood),
        _ => ('·', Ae.dim),
      };

  Widget _logRow(LogLine l, {bool trailing = false, double size = 11.5}) {
    final (glyph, colour) = _logStyle(l.kind);
    final loud = l.kind == 'reaction' || l.kind == 'cinematic' || l.kind == 'death';
    return Padding(
      padding: const EdgeInsets.only(bottom: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 15,
            child: Text(glyph,
                style: Ae.body(size * .95, c: colour, w: 800, h: 1.2)),
          ),
          Expanded(
            child: Text(
              l.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Ae.body(size,
                  c: loud ? colour : Ae.dim, w: loud ? 800 : 500, h: 1.3),
            ),
          ),
          if (trailing)
            Icon(Icons.unfold_more, size: 14, color: Ae.dim.withValues(alpha: .55)),
        ],
      ),
    );
  }

  /// One foe, one line: who, what, how much, and what it leaves behind.
  Widget _intentRow(FoeIntentInfo i) {
    final (glyph, colour, action) = switch (i.kind) {
      IntentKind.attack || IntentKind.attackMulti => (
          '⚔',
          Ae.blood,
          i.times > 1 ? '${i.perHit} ×${i.times} = ${i.total}' : '${i.total}',
        ),
      IntentKind.block => ('⛨', Ae.frost, 'guards ${i.guard}'),
      IntentKind.buff => ('▲', Ae.gold, i.buff ?? 'empowers'),
      IntentKind.debuff => ('▼', Ae.umbra, i.rider ?? 'weakens you'),
      IntentKind.sleep => ('☾', Ae.dim, i.note ?? 'idle'),
      _ => (
          '✦',
          Ae.volt,
          i.total > 0 ? '${i.note ?? "special"} · ${i.total}' : (i.note ?? 'special'),
        ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 14,
            child: Text(glyph, style: Ae.body(11.5, c: colour, h: 1)),
          ),
          Expanded(
            flex: 5,
            child: Text(i.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Ae.body(11.5, c: Ae.bone, w: 600, h: 1.25)),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 4,
            child: Text(action,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: Ae.body(11.5, c: colour, w: 800, h: 1.2)),
          ),
          if (i.rider != null && i.kind != IntentKind.debuff) ...[
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Ae.umbra.withValues(alpha: .7)),
              ),
              child: Text(i.rider!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Ae.body(9.5, c: Ae.umbra, w: 700, h: 1.2)),
            ),
          ],
        ],
      ),
    );
  }

  void _openFullLog() {
    Audio.i.sfx('tap', volume: .35);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * .72,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1F2E), Color(0xFF080B12)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: Ae.gold, width: 1.6)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 46, height: 4, color: Ae.panelHi),
            const SizedBox(height: 14),
            Text('COMBAT RECORD', style: Ae.display(20)),
            const SizedBox(height: 6),
            const AeRule(width: 150),
            const SizedBox(height: 8),
            Expanded(child: _recordList()),
          ],
        ),
      ),
    );
  }

  Widget _intentChip(Combatant f, Intent it, double maxW) {
    final str = f.s('strength');
    String text;
    Color c;
    switch (it.kind) {
      case IntentKind.attack:
      case IntentKind.attackMulti:
        final v = it.value + str;
        text = it.times > 1 ? '⚔ $v ×${it.times}' : '⚔ $v';
        c = Ae.blood;
      case IntentKind.block:
        text = '⛨ ${it.value}';
        c = Ae.frost;
      case IntentKind.buff:
        text = '▲ ${it.status ?? "power"}';
        c = Ae.gold;
      case IntentKind.debuff:
        text = '▼ ${it.status ?? "curse"}';
        c = Ae.umbra;
      case IntentKind.sleep:
        text = '☾ asleep';
        c = Ae.dim;
      default:
        text = '✦ ${it.note ?? "special"}';
        c = Ae.volt;
    }
    return Container(
      constraints: BoxConstraints(maxWidth: maxW),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.withValues(alpha: .30), const Color(0xE60A0D14)],
        ),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: c.withValues(alpha: .9), width: 1.2),
        boxShadow: [
          BoxShadow(color: c.withValues(alpha: .22), blurRadius: 10),
          const BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Text(text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Ae.body(12.5, c: Ae.bone, w: 800, h: 1.15)),
    );
  }

  /// Floating combat text. Sits on its own dark plate so a number is never
  /// lost against bright artwork, and eases out rather than sliding linearly.
  Widget _floatText(_Float f) {
    final c = switch (f.kind) {
      'damage' => const Color(0xFFFF7A6B),
      'heal' => Ae.good,
      'block' => Ae.frost,
      'reaction' => Ae.gold,
      'cinematic' => Ae.gold,
      _ => Ae.goldSoft,
    };
    final big = f.kind == 'damage';
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 950),
      curve: Curves.easeOutCubic,
      builder: (_, t, __) {
        final pop = t < .18 ? 1 + (t / .18) * .35 : 1.35 - ((t - .18) / .82) * .35;
        return Opacity(
          opacity: (1 - t * t).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -42 * t),
            child: Transform.scale(
              scale: pop,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Ae.ink.withValues(alpha: .72),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: c.withValues(alpha: .55), width: 1),
                ),
                child: Text(
                  f.text,
                  style: Ae.body(big ? 19 : 14, c: c, w: 900, h: 1),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------- hero
  Widget _heroBar() {
    final h = b.hero;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Ae.ink.withValues(alpha: .62),
            Ae.ink2.withValues(alpha: .95),
          ],
        ),
        border: Border(
          top: BorderSide(color: Ae.gold.withValues(alpha: .28)),
          bottom: BorderSide(color: Ae.gold.withValues(alpha: .18)),
        ),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Game.i.run!.vessel.elem.color, width: 1.6),
                    ),
                    child: ClipOval(child: Art(Game.i.run!.vessel.crest)),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    key: _kHp,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HpBar(hp: h.hp, maxHp: h.maxHp, block: h.block, width: 148, height: 20),
                    ],
                  ),
                  const Spacer(),
                  _energyDial(),
                ],
              ),
              for (var i = 0; i < _floatsFor(-1).length; i++)
                Positioned(left: 60, top: -6.0 - i * 20, child: _floatText(_floatsFor(-1)[i])),
            ],
          ),
          if (h.st.isNotEmpty) ...[
            const SizedBox(height: 6),
            StatusRow(h.st, aura: h.aura, size: 12.5),
          ],
          const SizedBox(height: 6),
          // The belt shares this line with the meter: the meter takes whatever
          // is left, so a fourth slot can never push the row off the screen.
          Row(
            children: [
              _aidBar(),
              Expanded(child: _comboMeter()),
              const SizedBox(width: 8),
              _potionBelt(),
            ],
          ),
        ],
      ),
    );
  }

  /// Whoever walks with you, and whether they still have their one action
  /// left. Empty when you travel alone, so it costs nothing on screen.
  Widget _aidBar() {
    final ids = Game.i.run!.companions;
    if (ids.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final id in ids)
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: _aidCrest(id),
          ),
      ],
    );
  }

  Widget _aidCrest(String id) {
    final c = companionById(id);
    final ready = b.aidAvailable(id);
    return GestureDetector(
      onTap: ready ? () => _openAid(id) : null,
      child: Opacity(
        opacity: ready ? 1 : .34,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ready ? Ae.gold : Ae.panelHi, width: 1.6),
            boxShadow: ready
                ? [BoxShadow(color: Ae.gold.withValues(alpha: .40), blurRadius: 8)]
                : null,
          ),
          child: ClipOval(child: Art(c.art)),
        ),
      ),
    );
  }

  Future<void> _openAid(String id) async {
    if (_busy) return;
    final c = companionById(id);
    final aid = aidFor(id);
    if (aid == null) return;
    var call = false;
    await aeSheet(
      context,
      title: aid.name,
      subtitle: c.name,
      accent: Ae.gold,
      heightFactor: .56,
      builder: (sheetCtx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Prose(aid.line, size: 17),
          const SizedBox(height: 14),
          Text(aid.desc, style: Ae.body(18, h: 1.5)),
          const SizedBox(height: 8),
          Text('ONCE PER BATTLE · COSTS NO AETHER', style: Ae.label(11, c: Ae.dim)),
          const SizedBox(height: 20),
          AeButton(
            label: 'CALL ON THEM',
            big: true,
            onTap: () {
              call = true;
              Navigator.of(sheetCtx).pop();
            },
          ),
          const SizedBox(height: 10),
          AeButton(
            label: 'NOT YET',
            color: Ae.dim,
            onTap: () => Navigator.of(sheetCtx).pop(),
          ),
        ],
      ),
    );
    if (!call || !mounted) return;
    Audio.i.sfx('cinematic', volume: .6);
    setState(() => b.useAid(id));
    _drain();
    _checkEnd();
  }

  /// The draught belt. Always shows every slot, including the empty ones, so
  /// the player can see at a glance that there is somewhere to put one.
  Widget _potionBelt() {
    final run = Game.i.run!;
    final slots = run.potionSlots;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < slots; i++)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: i < run.potions.length
                ? _potionSlot(potionDef(run.potions[i]))
                : _emptySlot(),
          ),
      ],
    );
  }

  Widget _emptySlot() => Container(
        width: 30,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Ae.panelHi.withValues(alpha: .55)),
          color: Ae.ink.withValues(alpha: .35),
        ),
      );

  Widget _potionSlot(PotionDef p) {
    final c = p.elem == Elem.none ? Ae.gold : p.elem.color;
    return GestureDetector(
      onTap: () => _openPotion(p),
      child: Container(
        width: 30,
        height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: c.withValues(alpha: .9), width: 1.3),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [c.withValues(alpha: .40), c.withValues(alpha: .12)],
          ),
          boxShadow: [BoxShadow(color: c.withValues(alpha: .35), blurRadius: 7)],
        ),
        child: Center(
          child: Text(p.elem == Elem.none ? '◈' : p.elem.glyph,
              style: TextStyle(fontSize: 15, color: c, height: 1)),
        ),
      ),
    );
  }

  Future<void> _openPotion(PotionDef p) async {
    if (_busy) return;
    final c = p.elem == Elem.none ? Ae.gold : p.elem.color;
    var drink = false;
    await aeSheet(
      context,
      title: p.name,
      subtitle: p.rarity.label,
      accent: c,
      heightFactor: .52,
      builder: (sheetCtx) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(p.desc, style: Ae.body(18, h: 1.5)),
          const SizedBox(height: 24),
          AeButton(
            label: 'DRINK IT',
            color: c,
            big: true,
            onTap: () {
              drink = true;
              Navigator.of(sheetCtx).pop();
            },
          ),
          const SizedBox(height: 10),
          AeButton(
            label: 'NOT YET',
            color: Ae.dim,
            onTap: () => Navigator.of(sheetCtx).pop(),
          ),
        ],
      ),
    );
    if (!drink || !mounted) return;
    Audio.i.sfx('relic', volume: .7);
    setState(() => b.usePotion(p.id));
    Game.i.saveRun();
    _drain();
    _checkEnd();
  }

  /// Energy, as a machined dial: pip ring for the total, big numeral for what
  /// is left, and it only glows while you still have something to spend.
  Widget _energyDial() {
    final spent = b.baseEnergy - b.energy;
    return SizedBox(
      key: _kEnergy,
      width: 58,
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF221A0C), Color(0xFF0A0C13)],
                radius: .9,
              ),
              border: Border.all(
                color: b.energy > 0 ? Ae.gold : Ae.panelHi,
                width: 2,
              ),
              boxShadow: b.energy > 0
                  ? [BoxShadow(color: Ae.gold.withValues(alpha: .26), blurRadius: 16)]
                  : null,
            ),
          ),
          CustomPaint(
            size: const Size(58, 58),
            painter: _EnergyPips(total: b.baseEnergy, spent: spent),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${b.energy}',
                  style: Ae.display(22, c: b.energy > 0 ? Ae.gold : Ae.dim)),
              Text('OF ${b.baseEnergy}', style: Ae.label(7.5, c: Ae.dim)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _comboMeter() {
    final counts = <Elem, int>{};
    for (final e in b.elemsThisTurn) {
      counts[e] = (counts[e] ?? 0) + 1;
    }
    // Always visible, so players learn the mechanic exists before they use it.
    final best = counts.isEmpty
        ? MapEntry(Game.i.run!.vessel.elem, 0)
        : counts.entries.reduce((a, c) => a.value >= c.value ? a : c);
    final n = best.value.clamp(0, 3);
    return Row(
      key: _kCombo,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text('${best.key.glyph} CINEMATIC ',
              overflow: TextOverflow.ellipsis,
              style: Ae.label(12, c: best.key.color)),
        ),
        for (var i = 0; i < 3; i++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 20,
            height: 6,
            decoration: BoxDecoration(
              color: i < n ? best.key.color : Ae.panelHi,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }

  // ------------------------------------------------------------- hand
  Widget _handArea() {
    return Column(
      children: [
        if (_selected != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('CHOOSE A TARGET', style: Ae.label(14, c: Ae.gold)),
          ),
        Expanded(
          child: b.hand.isEmpty
              ? Center(child: Text('No frames in hand', style: Ae.body(15, c: Ae.dim)))
              : ListView.separated(
                  key: _kHand,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(14, 20, 14, 6),
                  itemCount: b.hand.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 9),
                  itemBuilder: (_, i) {
                    final c = b.hand[i];
                    return FrameCard(
                      card: c,
                      width: 140,
                      playable: b.canPlay(c),
                      selected: _selected == c,
                      onTap: () => _tapCard(c),
                    );
                  },
                ),
        ),
        Padding(
          key: _kEnd,
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
          child: AeButton(
            label: _busy ? (_phase ?? 'Wait…') : 'End Turn',
            enabled: !_busy && !b.ended,
            color: Ae.blood,
            onTap: _endTurn,
          ),
        ),
      ],
    );
  }
}
