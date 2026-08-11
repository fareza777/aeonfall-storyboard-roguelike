import 'package:flutter/material.dart';

import '../audio.dart';
import '../data/chronicles.dart';
import '../data/narrative_model.dart';
import '../data/story_digest.dart';
import '../engine/map_gen.dart';
import '../engine/run_state.dart';
import '../game.dart';
import '../main.dart';
import '../theme.dart';
import 'battle_screen.dart';
import 'event_screen.dart';
import 'reward_screen.dart';
import 'rest_screen.dart';
import 'run_hud.dart';
import 'shop_screen.dart';
import 'story_sheet.dart';
import 'widgets.dart';

const _layerH = 96.0;
const _cols = 4;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with RouteAware {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    Audio.i.music('map');
    Game.i.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeIntro());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) routeObserver.subscribe(this, route);
  }

  /// Fired when a screen stacked on top of the map is dismissed. Battle rewards
  /// arrive via pushReplacement, which completes the original push future far
  /// too early, so this is the only dependable "we are visible again" signal.
  @override
  void didPopNext() {
    if (!mounted) return;
    setState(() {});
    Audio.i.music('map');
    _maybeIntro();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    Game.i.removeListener(_refresh);
    _scroll.dispose();
    super.dispose();
  }

  void _maybeIntro() {
    final r = Game.i.run!;
    final key = 'intro_act${r.act}';
    if (r.flag(key)) return;
    r.setFlag(key);
    Game.i.saveRun();
    final c = chronicleById(r.chronicleId);
    final text = switch (r.act) { 1 => c.actOne, 2 => c.actTwo, _ => c.actThree };
    if (r.act == 1) {
      Audio.i.voice('chron_${c.id}');
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ActIntro(
        chronicle: c,
        act: r.act,
        text: text,
        onClose: () {
          Audio.i.stopVoice();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _tap(MapNode n) {
    final g = Game.i;
    final map = g.run!.map!;
    if (!map.available.contains(n.id)) return;
    Audio.i.sfx('confirm');
    g.enterNode(n.id);

    switch (n.type) {
      case NodeType.battle:
      case NodeType.elite:
      case NodeType.boss:
        g.beginBattle(n.type);
        _push(BattleScreen(nodeId: n.id, type: n.type));
      case NodeType.event:
      case NodeType.beat:
      case NodeType.mystery:
        _push(EventScreen(nodeId: n.id, mystery: n.type == NodeType.mystery));
      case NodeType.shop:
        _push(ShopScreen(nodeId: n.id));
      case NodeType.rest:
        _push(RestScreen(nodeId: n.id));
      case NodeType.treasure:
        _push(RewardScreen(
          nodeId: n.id,
          gold: 40 + g.run!.act * 25,
          relic: true,
          title: 'A CACHE',
          blurb: 'Somebody left this here for somebody. It may as well be you.',
          art: 'site_treasure_room',
        ));
    }
  }

  void _push(Widget w) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));
  }

  @override
  Widget build(BuildContext context) {
    final g = Game.i;
    if (g.run == null) {
      return const Scaffold(body: Center(child: Text('No run')));
    }
    final r = g.run!;
    final map = r.map!;
    final chron = chronicleById(r.chronicleId);
    final biome = _biomeFor(r.act);
    final w = MediaQuery.of(context).size.width;
    final colW = w / _cols;
    final totalH = map.layers * _layerH + 120;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Art(biome),
            DecoratedBox(
              decoration: BoxDecoration(color: Ae.ink.withValues(alpha: .74)),
            ),
            Column(
              children: [
                RunHud(onBack: () => Navigator.of(context).popUntil((r2) => r2.isFirst)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(chron.title, style: Ae.display(19)),
                            Text('ACT ${r.act} · ${_actName(r.act)}',
                                style: Ae.label(12, c: Ae.goldSoft)),
                          ],
                        ),
                      ),
                      if (r.companions.isNotEmpty)
                        Row(
                          children: [
                            for (final c in r.companions)
                              Container(
                                width: 36,
                                height: 36,
                                margin: const EdgeInsets.only(left: 5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Ae.gold, width: 1.4),
                                ),
                                child: ClipOval(child: Art('comp_$c')),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
                _objectivePanel(r),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scroll,
                    reverse: true,
                    child: SizedBox(
                      height: totalH,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _EdgePainter(map, colW, _layerH, totalH),
                            ),
                          ),
                          for (final n in map.nodes)
                            Positioned(
                              left: n.col * colW + colW / 2 - 33,
                              bottom: 60 + n.layer * _layerH,
                              child: _NodeChip(
                                node: n,
                                available: map.available.contains(n.id),
                                current: map.currentId == n.id,
                                onTap: () => _tap(n),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Shown in full once per Act, then folded away to a single slim line so it
  /// stops covering the map. Tapping either form opens the full recap.
  Widget _objectivePanel(RunState r) {
    final collapsed = r.flag('objective_seen_${r.act}');

    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 4),
        child: GestureDetector(
          onTap: () => showStorySoFar(context, r),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Ae.ink.withValues(alpha: .72),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: Ae.panelHi),
            ),
            child: Row(
              children: [
                const Icon(Icons.flag_outlined, color: Ae.gold, size: 17),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    StoryDigest.objective(r),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Ae.body(13.5, c: Ae.dim),
                  ),
                ),
                Text('STORY', style: Ae.label(11, c: Ae.frost)),
                const Icon(Icons.chevron_right, color: Ae.frost, size: 17),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 6),
      child: AePanel(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        fill: const Color(0xE60E1018),
        border: Ae.gold,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_outlined, color: Ae.gold, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text('WHAT TO DO NOW', style: Ae.label(11))),
                GestureDetector(
                  onTap: () {
                    Audio.i.sfx('tap', volume: .4);
                    r.setFlag('objective_seen_${r.act}');
                    Game.i.saveRun();
                    setState(() {});
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, color: Ae.dim, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(StoryDigest.objective(r), style: Ae.body(15.5, c: Ae.bone, w: 600)),
            const SizedBox(height: 4),
            Text(StoryDigest.stake(r), style: Ae.body(13.5, c: Ae.dim)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => showStorySoFar(context, r),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Ae.frost.withValues(alpha: .8)),
                      ),
                      child: Text('READ THE STORY SO FAR',
                          style: Ae.label(12, c: Ae.frost)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _actName(int act) => switch (act) {
        1 => 'THE ROAD OUT',
        2 => 'THE MACHINERY',
        _ => 'THE UNWRITTEN',
      };

  String _biomeFor(int act) {
    final r = Game.i.run!;
    const a1 = ['biome_ashfall', 'biome_drowned', 'biome_ossuary', 'biome_emberreach', 'biome_gloamwood'];
    const a2 = ['biome_clockwork', 'biome_bazaar', 'biome_stormspire', 'biome_brasslung', 'biome_saltcourt'];
    const a3 = ['biome_unwritten', 'biome_vault', 'biome_thefall', 'biome_nullshore', 'biome_crownfall'];
    final pool = switch (act) { 1 => a1, 2 => a2, _ => a3 };
    return pool[(r.seed + act) % pool.length];
  }
}

class _NodeChip extends StatelessWidget {
  const _NodeChip({
    required this.node,
    required this.available,
    required this.current,
    required this.onTap,
  });

  final MapNode node;
  final bool available;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = node.visited;
    final c = switch (node.type) {
      NodeType.elite => Ae.blood,
      NodeType.boss => Ae.ember,
      NodeType.rest => Ae.good,
      NodeType.shop => Ae.gold,
      NodeType.treasure => Ae.lumen,
      NodeType.event || NodeType.beat => Ae.volt,
      NodeType.mystery => Ae.umbra,
      _ => Ae.frost,
    };
    final active = available && !done;

    return GestureDetector(
      onTap: active ? onTap : null,
      child: Opacity(
        opacity: done ? .34 : (active ? 1 : .52),
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Ae.ink2,
                border: Border.all(
                    color: active ? c : (current ? Ae.bone : Ae.panelHi),
                    width: active ? 2.6 : 1.6),
                boxShadow: active
                    ? [BoxShadow(color: c.withValues(alpha: .55), blurRadius: 18)]
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: ClipOval(child: Art(node.type.icon)),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Ae.ink.withValues(alpha: .8),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(node.type.label,
                  style: Ae.label(10, c: active ? c : Ae.dim)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EdgePainter extends CustomPainter {
  _EdgePainter(this.map, this.colW, this.layerH, this.totalH);
  final StoryMap map;
  final double colW;
  final double layerH;
  final double totalH;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Ae.panelHi
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    final pOn = Paint()
      ..color = Ae.gold.withValues(alpha: .75)
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke;

    Offset pos(MapNode n) =>
        Offset(n.col * colW + colW / 2, totalH - (60 + n.layer * layerH) - 31);

    for (final n in map.nodes) {
      for (final id in n.next) {
        final m = map.byId(id);
        final a = pos(n);
        final b = pos(m);
        final path = Path()
          ..moveTo(a.dx, a.dy)
          ..cubicTo(a.dx, a.dy - layerH * .45, b.dx, b.dy + layerH * .45, b.dx, b.dy);
        canvas.drawPath(path, n.visited && map.available.contains(id) ? pOn : p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EdgePainter old) => true;
}

class _ActIntro extends StatelessWidget {
  const _ActIntro({
    required this.chronicle,
    required this.act,
    required this.text,
    required this.onClose,
  });

  final Chronicle chronicle;
  final int act;
  final String text;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(18),
        child: Container(
          decoration: BoxDecoration(
            color: Ae.ink2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Ae.gold, width: 1.6),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 170, width: double.infinity, child: Art(chronicle.art)),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ACT $act', style: Ae.label(13)),
                        const SizedBox(height: 6),
                        Text(chronicle.title, style: Ae.display(26)),
                        const SizedBox(height: 4),
                        Text(chronicle.subtitle, style: Ae.body(14, c: Ae.dim)),
                        const SizedBox(height: 16),
                        if (act == 1) ...[
                          Prose(chronicle.premise, size: 16),
                          const SizedBox(height: 14),
                        ],
                        Prose(text, size: 17),
                        const SizedBox(height: 20),
                        AeButton(label: 'Begin', big: true, onTap: onClose),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
