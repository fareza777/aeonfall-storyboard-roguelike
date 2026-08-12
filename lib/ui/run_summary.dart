import 'package:flutter/material.dart';

import '../audio.dart';
import '../data/vessels.dart';
import '../engine/run_state.dart';
import '../game.dart';
import '../theme.dart';
import 'widgets.dart';

/// What the run actually was, in numbers, at the end of it.
///
/// Every figure here is counted while the run happens rather than
/// reconstructed afterwards, so it is a record and not an estimate.
class RunSummary extends StatelessWidget {
  const RunSummary({super.key, required this.run, this.won = false});

  final RunState run;
  final bool won;

  @override
  Widget build(BuildContext context) {
    final r = run;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('THE RECORD', style: Ae.label(14)),
        const SizedBox(height: 10),
        AePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (r.hpTrail.length > 1) ...[
                Text('HOW CLOSE IT GOT', style: Ae.label(11.5, c: Ae.dim)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 62,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _PulsePainter(r.hpTrail, r.maxHp),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('floor 1', style: Ae.label(10, c: Ae.dim)),
                    Text('lowest ${r.hpTrail.reduce((a, b) => a < b ? a : b)} HP',
                        style: Ae.label(10, c: Ae.blood)),
                    Text('floor ${r.hpTrail.length}', style: Ae.label(10, c: Ae.dim)),
                  ],
                ),
                const SizedBox(height: 14),
                const AeRule(),
                const SizedBox(height: 12),
              ],
              Wrap(
                spacing: 22,
                runSpacing: 14,
                children: [
                  _stat('FLOORS', '${r.totalFloors}'),
                  _stat('TURNS', '${r.turnsTaken}'),
                  _stat('FELLED', '${r.foesFelled}'),
                  if (r.elitesFelled > 0) _stat('ELITES', '${r.elitesFelled}'),
                  if (r.bossesFelled > 0) _stat('BOSSES', '${r.bossesFelled}'),
                  _stat('DEALT', '${r.damageDealt}'),
                  _stat('TAKEN', '${r.damageTaken}'),
                  if (r.cinematics > 0) _stat('CINEMATICS', '${r.cinematics}'),
                  if (r.reactions > 0) _stat('REACTIONS', '${r.reactions}'),
                  if (r.draughtsDrunk > 0) _stat('DRAUGHTS', '${r.draughtsDrunk}'),
                  if (r.aidsCalled > 0) _stat('AIDS', '${r.aidsCalled}'),
                  _stat('DECK', '${r.deck.length}'),
                  _stat('SIGILS', '${r.relics.length}'),
                  _stat('PAGES', '${r.pages.length}/9'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stat(String k, String v) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(v, style: Ae.display(20, c: Ae.gold)),
          Text(k, style: Ae.label(10.5, c: Ae.dim)),
        ],
      );
}

/// The HP reading taken on each floor, drawn as one line. A run that was
/// never in danger and a run that survived on fumes look nothing alike.
class _PulsePainter extends CustomPainter {
  _PulsePainter(this.trail, this.maxHp);
  final List<int> trail;
  final int maxHp;

  @override
  void paint(Canvas canvas, Size size) {
    if (trail.length < 2 || maxHp <= 0) return;
    final dx = size.width / (trail.length - 1);
    double y(int hp) => size.height - (hp.clamp(0, maxHp) / maxHp) * size.height;

    // A quarter-health line, so "how close it got" is readable at a glance.
    final danger = Paint()
      ..color = Ae.blood.withValues(alpha: .35)
      ..strokeWidth = 1;
    final dangerY = y((maxHp * .25).round());
    for (var x = 0.0; x < size.width; x += 7) {
      canvas.drawLine(Offset(x, dangerY), Offset(x + 3.5, dangerY), danger);
    }

    final path = Path()..moveTo(0, y(trail.first));
    for (var i = 1; i < trail.length; i++) {
      path.lineTo(i * dx, y(trail[i]));
    }

    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Ae.gold.withValues(alpha: .28), Ae.gold.withValues(alpha: .02)],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = Ae.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );

    // Mark the worst moment.
    var lowIdx = 0;
    for (var i = 1; i < trail.length; i++) {
      if (trail[i] < trail[lowIdx]) lowIdx = i;
    }
    canvas.drawCircle(
      Offset(lowIdx * dx, y(trail[lowIdx])),
      3.4,
      Paint()..color = Ae.blood,
    );
  }

  @override
  bool shouldRepaint(_PulsePainter old) => old.trail != trail;
}

// ═══════════════════════════════════════════════════════════════ history
void showRunHistory(BuildContext context) {
  Audio.i.sfx('draw');
  final m = Game.i.meta;
  final h = m.history;

  aeSheet(
    context,
    title: 'THE DRAFTS',
    subtitle: h.isEmpty
        ? 'No run has finished yet.'
        : '${h.length} recorded · ${h.where((x) => x['won'] == true).length} finished',
    heightFactor: .86,
    builder: (_) => ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        // Per-Vessel record first — the thing a returning player wants.
        AePanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('BY VESSEL', style: Ae.label(12, c: Ae.dim)),
              const SizedBox(height: 10),
              for (final v in kVessels)
                if (m.runsWith(v.id) > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 26,
                          height: 26,
                          child: ClipOval(child: Art(v.crest)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(v.name, style: Ae.body(15.5))),
                        Text('${m.winsWith(v.id)} / ${m.runsWith(v.id)}',
                            style: Ae.body(15.5, c: Ae.gold, w: 800)),
                      ],
                    ),
                  ),
              if (kVessels.every((v) => m.runsWith(v.id) == 0))
                Text('Nothing yet.', style: Ae.body(15, c: Ae.dim)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (h.isNotEmpty) Text('EVERY DRAFT', style: Ae.label(12, c: Ae.dim)),
        const SizedBox(height: 8),
        for (var i = 0; i < h.length; i++) _historyRow(h[i], h.length - i),
      ],
    ),
  );
}

Widget _historyRow(Map<String, dynamic> e, int number) {
  final won = e['won'] == true;
  final rec = (e['record'] as Map?) ?? const {};
  final v = vesselById(e['vessel'] as String? ?? 'ashcaller');
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: AePanel(
      border: won ? Ae.gold : Ae.panelHi,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 34, height: 34, child: ClipOval(child: Art(v.crest))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('DRAFT $number · ${v.name.toUpperCase()}',
                          style: Ae.label(12.5, c: won ? Ae.gold : Ae.bone)),
                    ),
                    if ((e['asc'] as int? ?? 0) > 0)
                      Text('A${e['asc']}', style: Ae.label(11, c: Ae.dim)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  won
                      ? 'Finished · act ${e['act']} · ${e['floors']} floors'
                      : 'Fell in act ${e['act']} · ${e['floors']} floors',
                  style: Ae.body(14, c: won ? Ae.good : Ae.dim),
                ),
                const SizedBox(height: 3),
                Text(
                  '${rec['foes'] ?? 0} felled · ${rec['dealt'] ?? 0} dealt · '
                  '${rec['taken'] ?? 0} taken · ${e['pages'] ?? 0}/9 pages',
                  style: Ae.body(13, c: Ae.dim),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
