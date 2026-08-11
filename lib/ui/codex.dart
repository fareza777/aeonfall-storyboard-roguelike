import 'package:flutter/material.dart';

import '../data/chronicles.dart';
import '../data/companions.dart';
import '../data/enemies.dart';
import '../data/endings.dart';
import '../engine/core.dart';
import '../game.dart';
import '../theme.dart';
import 'widgets.dart';

class CodexScreen extends StatelessWidget {
  const CodexScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 5,
        child: Scaffold(
          body: Column(
            children: [
              AeBar('The Codex', onBack: () => Navigator.pop(context)),
              Container(
                color: Ae.ink2,
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: Ae.gold,
                  labelColor: Ae.bone,
                  unselectedLabelColor: Ae.dim,
                  labelStyle: Ae.label(14, c: Ae.bone),
                  unselectedLabelStyle: Ae.label(14, c: Ae.dim),
                  tabs: const [
                    Tab(text: 'LORE'),
                    Tab(text: 'ELEMENTS'),
                    Tab(text: 'STATUS'),
                    Tab(text: 'BESTIARY'),
                    Tab(text: 'ENDINGS'),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    _LoreTab(),
                    _ElementsTab(),
                    _StatusTab(),
                    _BestiaryTab(),
                    _EndingsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _LoreTab extends StatelessWidget {
  const _LoreTab();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Heading('AEVUM', sub: 'The world that was drawn'),
          const SizedBox(height: 14),
          const Prose(
            'Aevum was not created. It was **drawn** — panel by panel, life by life. '
            'Every person in it is a frame in an endless storyboard.\n\n'
            'When a story grows too tangled to finish, its Author does what every artist '
            'does: crumples the page and starts again. That erasure is a **Fall**. There '
            'have been more than three thousand.\n\n'
            'Nobody remembers, because memory is drawn too.\n\n'
            'A **Vessel** is a character drawn too well to erase — load-bearing, so removing '
            'them would collapse the whole composition. So the Author keeps them, wipes '
            'them, and uses them again in the next draft.\n\n'
            'Erasure is imperfect. Each Fall, a little more sticks.',
            size: 17,
          ),
          const SizedBox(height: 26),
          const Heading('CHRONICLES', sub: 'Each run is a different draft'),
          const SizedBox(height: 12),
          for (final c in kChronicles) ...[
            AePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.title, style: Ae.display(19)),
                  const SizedBox(height: 3),
                  Text(c.subtitle, style: Ae.body(14, c: Ae.dim)),
                  const SizedBox(height: 10),
                  Text(c.premise, style: Ae.body(15, c: Ae.bone, h: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 20),
          const Heading('COMPANIONS', sub: 'One of them was given an instruction'),
          const SizedBox(height: 12),
          for (final c in kCompanions) ...[
            AePanel(
              child: Row(children: [
                SizedBox(
                  width: 58,
                  height: 58,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(8), child: Art(c.art)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${c.name} · ${c.title}', style: Ae.label(15, c: Ae.bone)),
                      const SizedBox(height: 5),
                      Text('${c.perk} — ${c.perkDesc}', style: Ae.body(14, c: Ae.dim)),
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 9),
          ],
        ],
      );
}

class _ElementsTab extends StatelessWidget {
  const _ElementsTab();

  @override
  Widget build(BuildContext context) {
    final pairs = <List<Elem>>[];
    const elems = [Elem.ember, Elem.frost, Elem.volt, Elem.umbra, Elem.lumen];
    for (var i = 0; i < elems.length; i++) {
      for (var j = i + 1; j < elems.length; j++) {
        pairs.add([elems[i], elems[j]]);
      }
    }
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Heading('AURAS & REACTIONS', sub: 'The heart of the fight'),
        const SizedBox(height: 12),
        const Prose(
          'Every foe wears its own element as an **aura**. Strike that aura with a '
          '*different* element and the two react — usually catastrophically. The aura is '
          'consumed, and reasserts itself two turns later, so Reactions are a rhythm you '
          'can build a deck around.\n\n'
          'Your own elemental attacks also paint an aura on anything that had none.\n\n'
          'Play three frames of one element in a single turn to fire your Vessel\'s '
          '**Cinematic**.',
          size: 16,
        ),
        const SizedBox(height: 20),
        for (final p in pairs)
          Builder(builder: (_) {
            final id = reactionFor(p[0], p[1]);
            if (id == null) return const SizedBox.shrink();
            final r = kReactions[id]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AePanel(
                border: r.color.withValues(alpha: .7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('${p[0].glyph} ${p[0].label}',
                          style: Ae.body(15, c: p[0].color, w: 800)),
                      Text('  +  ', style: Ae.body(15, c: Ae.dim)),
                      Text('${p[1].glyph} ${p[1].label}',
                          style: Ae.body(15, c: p[1].color, w: 800)),
                    ]),
                    const SizedBox(height: 8),
                    Text(r.name, style: Ae.display(18, c: r.color)),
                    const SizedBox(height: 4),
                    Text(r.blurb, style: Ae.body(15, c: Ae.bone)),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _StatusTab extends StatelessWidget {
  const _StatusTab();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Heading('CONDITIONS', sub: 'What sticks to you and to them'),
          const SizedBox(height: 14),
          for (final s in kStatus.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: AePanel(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.glyph, style: TextStyle(fontSize: 20, color: s.color)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${s.name}${s.debuff ? "  ·  debuff" : ""}',
                              style: Ae.label(15, c: s.color)),
                          const SizedBox(height: 4),
                          Text(s.desc, style: Ae.body(15, c: Ae.bone)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
}

class _BestiaryTab extends StatelessWidget {
  const _BestiaryTab();

  @override
  Widget build(BuildContext context) {
    final seen = Game.i.meta.codexEnemies;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Heading('BESTIARY',
            sub: '${seen.length} of ${kAllEnemies.length} encountered'),
        const SizedBox(height: 14),
        for (final e in kAllEnemies)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: AePanel(
              border: seen.contains(e.id) ? e.elem.color.withValues(alpha: .6) : Ae.panelHi,
              child: Row(children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: seen.contains(e.id)
                        ? Art(e.artKey())
                        : Container(
                            color: Ae.ink,
                            child: const Center(
                                child: Text('?',
                                    style: TextStyle(fontSize: 24, color: Ae.panelHi)))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: seen.contains(e.id)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.name.toUpperCase(), style: Ae.label(14, c: Ae.bone)),
                            Text(
                                '${e.elem.label} · ${e.hp}–${e.hpMax} HP · '
                                '${["normal", "elite", "boss"][e.tier]}',
                                style: Ae.body(13, c: Ae.dim)),
                            if (e.blurb.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(e.blurb, style: Ae.body(14, c: Ae.goldSoft, h: 1.4)),
                            ],
                            if (e.passiveDesc != null) ...[
                              const SizedBox(height: 5),
                              Text(e.passiveDesc!, style: Ae.body(13, c: Ae.frost)),
                            ],
                          ],
                        )
                      : Text('Not yet encountered', style: Ae.body(15, c: Ae.dim)),
                ),
              ]),
            ),
          ),
      ],
    );
  }
}

class _EndingsTab extends StatelessWidget {
  const _EndingsTab();

  @override
  Widget build(BuildContext context) {
    final found = Game.i.meta.endings;
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Heading('ENDINGS', sub: '${found.length} of ${kEndings.length} reached'),
        const SizedBox(height: 14),
        for (final e in kEndings)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AePanel(
              border: found.contains(e.id) ? Ae.gold : Ae.panelHi,
              child: found.contains(e.id)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 120,
                          width: double.infinity,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(8), child: Art(e.art)),
                        ),
                        const SizedBox(height: 10),
                        Text(e.title, style: Ae.display(19)),
                        const SizedBox(height: 4),
                        Text(e.epitaph, style: Ae.body(15, c: Ae.goldSoft)),
                      ],
                    )
                  : Row(children: [
                      const Icon(Icons.lock_outline, color: Ae.panelHi, size: 26),
                      const SizedBox(width: 12),
                      Text('Undiscovered', style: Ae.body(16, c: Ae.dim)),
                    ]),
            ),
          ),
      ],
    );
  }
}
