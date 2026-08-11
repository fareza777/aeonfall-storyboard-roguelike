import 'package:flutter/material.dart';

import '../audio.dart';
import '../data/relics.dart';
import '../engine/core.dart';
import '../engine/run_state.dart';
import '../game.dart';
import '../theme.dart';
import 'widgets.dart';

/// Persistent run status strip shown on every out-of-battle screen.
///
/// Listens to the game directly: it used to be a `const` widget, which meant
/// Aeon and HP never refreshed while you were spending in a shop.
class RunHud extends StatefulWidget {
  const RunHud({super.key, this.onBack});
  final VoidCallback? onBack;

  @override
  State<RunHud> createState() => _RunHudState();
}

class _RunHudState extends State<RunHud> {
  @override
  void initState() {
    super.initState();
    Game.i.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    Game.i.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = Game.i.run!;
    final curses = r.deck.where((c) => c.def.type == CardType.curse).length;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      decoration: BoxDecoration(
        color: Ae.ink.withValues(alpha: .92),
        border: const Border(bottom: BorderSide(color: Ae.panelHi)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                if (widget.onBack != null)
                  GestureDetector(
                    onTap: widget.onBack,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.arrow_back, color: Ae.goldSoft, size: 24),
                    ),
                  ),
                HpBar(hp: r.hp, maxHp: r.maxHp, width: 128, height: 21),
                const SizedBox(width: 14),
                Text('◈ ${r.gold}', style: Ae.body(16, c: Ae.gold, w: 800)),
                const Spacer(),
                Text('ACT ${r.act}', style: Ae.label(14)),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => showDeck(context, r),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: curses > 0 ? Ae.umbra : Ae.panelHi),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('DECK ${r.deck.length}', style: Ae.label(12, c: Ae.bone)),
                      if (curses > 0) ...[
                        const SizedBox(width: 6),
                        Text('✡$curses', style: Ae.label(12, c: Ae.umbra)),
                      ],
                    ]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            SizedBox(
              height: 34,
              child: Row(
                children: [
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: r.relics.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, i) {
                        final rel = relicDef(r.relics[i]);
                        return GestureDetector(
                          onTap: () => _relicInfo(context, rel),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7),
                              border: Border.all(
                                  color: rel.rarity.color.withValues(alpha: .8), width: 1.3),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Art(rel.artKey()),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (r.pages.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                      decoration: BoxDecoration(
                        color: Ae.gold.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Ae.gold, width: 1.2),
                      ),
                      child: Text('PAGES ${r.pages.length}/9',
                          style: Ae.label(12, c: Ae.gold)),
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

  void _relicInfo(BuildContext context, RelicDef rel) {
    Audio.i.sfx('tap');
    aeDialog(
      context,
      accent: rel.rarity.color,
      kicker: '${rel.rarity.label} SIGIL',
      title: rel.name,
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: rel.rarity.color.withValues(alpha: .6)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Art(rel.artKey()),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(rel.desc, style: Ae.body(16.5, c: Ae.bone, h: 1.55)),
          ),
        ],
      ),
    );
  }
}

void showDeck(BuildContext context, RunState r, {String title = 'YOUR DECK'}) {
  Audio.i.sfx('draw');
  // Curses and statuses sort to the front so dead weight is impossible to miss.
  int rank(CardInst c) => switch (c.def.type) {
        CardType.curse => 0,
        CardType.status => 1,
        _ => 2,
      };
  final sorted = [...r.deck]..sort((a, b) {
      final t = rank(a).compareTo(rank(b));
      if (t != 0) return t;
      final u = a.def.type.index.compareTo(b.def.type.index);
      return u != 0 ? u : a.def.name.compareTo(b.def.name);
    });
  final junk = sorted.where((c) => rank(c) < 2).length;
  aeSheet(
    context,
    title: title,
    subtitle: '${sorted.length} frames carried',
    heightFactor: .82,
    trailing: Text('${r.deck.length}', style: Ae.display(24, c: Ae.gold)),
    builder: (_) => Column(
      children: [
        if (junk > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
            child: AePanel(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
              border: Ae.umbra,
              child: Row(children: [
                const Text('✡', style: TextStyle(fontSize: 19, color: Ae.umbra)),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    '$junk unplayable card${junk == 1 ? "" : "s"} clogging this deck, '
                    'shown first. Burn them at a Market.',
                    style: Ae.body(14.5, c: Ae.umbra, w: 600, h: 1.4),
                  ),
                ),
              ]),
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 11,
              crossAxisSpacing: 11,
              childAspectRatio: 1 / 1.52,
            ),
            itemCount: sorted.length,
            itemBuilder: (_, i) => FrameCard(card: sorted[i], width: 110),
          ),
        ),
      ],
    ),
  );
}
