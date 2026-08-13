import 'package:flutter/material.dart';

import '../audio.dart';
import '../data/ascension.dart';
import '../data/vessels.dart';
import '../game.dart';
import '../theme.dart';
import 'codex.dart';
import 'how_to_play.dart';
import 'map_screen.dart';
import 'run_summary.dart';
import 'trailer.dart';
import 'vessel_select.dart';
import 'widgets.dart';

class HubScreen extends StatefulWidget {
  const HubScreen({super.key});

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> {
  @override
  void initState() {
    super.initState();
    Audio.i.music('hub');
    // Without this the Sanctum keeps whatever it was built with. Dying pops
    // straight back here, and a screen that is not listening still offers to
    // continue a run that no longer exists — you had to Abandon the corpse
    // before the game would let you start again.
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
    final g = Game.i;
    final m = g.meta;
    return Scaffold(
      body: AeBackdrop(
        image: 'brand_hub_bg',
        dark: .60,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 18),
              Text('AEONFALL', style: Ae.display(38)),
              const SizedBox(height: 6),
              Text('THE SANCTUM BETWEEN FALLS', style: Ae.label(13, c: Ae.goldSoft)),
              const SizedBox(height: 16),
              _stats(m),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(26, 12, 26, 4),
                  child: Column(
                    children: [
                    if (g.hasRun) ...[
                      AeButton(
                        label: 'Continue Run',
                        big: true,
                        sub: '${g.run!.vessel.title} · Act ${g.run!.act} · '
                            '${g.run!.hp}/${g.run!.maxHp} HP',
                        onTap: () {
                          Audio.i.sfx('confirm');
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const MapScreen()));
                        },
                      ),
                      const SizedBox(height: 12),
                      AeButton(
                        label: 'Abandon Run',
                        color: Ae.blood,
                        onTap: () => _confirmAbandon(context),
                      ),
                    ] else
                      AeButton(
                        label: 'Begin a New Run',
                        big: true,
                        sub: 'Choose a Vessel and fall again',
                        onTap: () {
                          Audio.i.sfx('confirm');
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const VesselSelectScreen()));
                        },
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AeButton(
                            label: 'Trailer',
                            color: Ae.volt,
                            onTap: () {
                              Audio.i.sfx('tap');
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => const TrailerScreen()));
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AeButton(
                            label: 'Codex',
                            color: Ae.frost,
                            onTap: () {
                              Audio.i.sfx('tap');
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const CodexScreen()));
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AeButton(
                      label: 'How to Play',
                      sub: 'Rules, elements and the story in plain language',
                      color: Ae.good,
                      onTap: () {
                        Audio.i.sfx('tap');
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const HowToPlayScreen()));
                      },
                    ),
                    const SizedBox(height: 12),
                    AeButton(
                      label: 'The Sanctum  ·  ${m.shards} Shards',
                      color: Ae.lumen,
                      onTap: () => _openSanctum(context),
                    ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _settings(m),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stats(m) => Wrap(
        spacing: 10,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _pill('RUNS', '${m.runs}'),
          _pill('FINISHED', '${m.wins}'),
          _pill('ENDINGS', '${m.endings.length}/12'),
          GestureDetector(
            onTap: () => _showAscensions(m.ascension),
            child: _pill('ASCENSION', '${m.ascension} ›'),
          ),
        ],
      );

  /// The twenty rules, with the ones currently in force marked. A player at a
  /// high Ascension is playing a different game and has to be able to read
  /// exactly how before they set out.
  void _showAscensions(int level) {
    Audio.i.sfx('tap');
    aeSheet(
      context,
      title: 'ASCENSION $level',
      subtitle: level == 0
          ? 'No rules changed yet. Finish a run to raise it.'
          : '$level of 20 rules in force',
      heightFactor: .84,
      builder: (_) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        itemCount: kAscensions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final t = kAscensions[i];
          final on = t.level <= level;
          return AePanel(
            border: on ? Ae.gold : Ae.panelHi,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 30,
                  child: Text('${t.level}',
                      style: Ae.display(19, c: on ? Ae.gold : Ae.dim)),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.title.toUpperCase(),
                          style: Ae.label(13.5, c: on ? Ae.bone : Ae.dim)),
                      const SizedBox(height: 4),
                      Text(t.desc,
                          style: Ae.body(15, c: on ? Ae.bone : Ae.dim, h: 1.45)),
                    ],
                  ),
                ),
                if (on)
                  const Padding(
                    padding: EdgeInsets.only(left: 8, top: 2),
                    child: Text('●', style: TextStyle(color: Ae.gold, fontSize: 12)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _pill(String k, String v) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Ae.ink2.withValues(alpha: .8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Ae.panelHi),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('$k ', style: Ae.body(12, c: Ae.dim, w: 700)),
          Text(v, style: Ae.body(15, c: Ae.gold, w: 800)),
        ]),
      );

  Widget _settings(m) => Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 10,
        children: [
          _toggle('MUSIC', m.music, () {
            setState(() => m.music = !m.music);
            Audio.i.setMusic(m.music);
            if (m.music) Audio.i.music('hub');
            Game.i.saveMeta();
          }),
          _toggle('SOUND', m.sfx, () {
            setState(() => m.sfx = !m.sfx);
            Audio.i.sfxOn = m.sfx;
            Audio.i.sfx('tap');
            Game.i.saveMeta();
          }),
          GestureDetector(
            onTap: () => showRunHistory(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: Ae.ink2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Ae.panelHi, width: 1.4),
              ),
              child: Text('THE DRAFTS', style: Ae.label(13, c: Ae.bone)),
            ),
          ),
          GestureDetector(
            onTap: _openAccess,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: Ae.ink2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Ae.panelHi, width: 1.4),
              ),
              child: Text('READABILITY', style: Ae.label(13, c: Ae.bone)),
            ),
          ),
        ],
      );

  /// Text size, colour-blind element shapes, motion and haptics. Every one of
  /// these is somebody's reason for being able to play at all.
  void _openAccess() {
    Audio.i.sfx('tap');
    final m = Game.i.meta;
    aeSheet(
      context,
      title: 'READABILITY',
      subtitle: 'Applies everywhere, immediately',
      heightFactor: .70,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (_, setSheet) {
          void save(VoidCallback f) {
            setSheet(f);
            setState(f);
            Game.i.saveMeta();
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 26),
            children: [
              Text('TEXT SIZE', style: Ae.label(12, c: Ae.dim)),
              const SizedBox(height: 6),
              Row(
                children: [
                  for (final s in const [0.9, 1.0, 1.15, 1.3])
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => save(() => m.textScale = s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: m.textScale == s
                                  ? Ae.gold.withValues(alpha: .18)
                                  : Ae.ink2,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: m.textScale == s ? Ae.gold : Ae.panelHi,
                                  width: 1.4),
                            ),
                            child: Text(
                              switch (s) {
                                0.9 => 'SMALL',
                                1.0 => 'NORMAL',
                                1.15 => 'LARGE',
                                _ => 'LARGEST',
                              },
                              style: Ae.label(11.5,
                                  c: m.textScale == s ? Ae.bone : Ae.dim),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text('The quick brown fox jumps over the lazy dog.',
                  style: Ae.body(16 * m.textScale, h: 1.5)),
              const SizedBox(height: 20),
              const AeRule(),
              const SizedBox(height: 16),
              _accessRow(
                'ELEMENT NAMES',
                'Spell out the element in words wherever colour alone carries it.',
                m.colourblind,
                () => save(() => m.colourblind = !m.colourblind),
              ),
              _accessRow(
                'REDUCED MOTION',
                'Cut screen shake and flourishes. The fight plays faster.',
                m.reducedMotion,
                () => save(() => m.reducedMotion = !m.reducedMotion),
              ),
              _accessRow(
                'HAPTICS',
                'A short buzz on heavy damage, Reactions and Cinematics.',
                m.haptics,
                () => save(() => m.haptics = !m.haptics),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _accessRow(String title, String desc, bool on, VoidCallback tap) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: tap,
          child: AePanel(
            border: on ? Ae.gold : Ae.panelHi,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Ae.label(13, c: on ? Ae.bone : Ae.dim)),
                      const SizedBox(height: 3),
                      Text(desc, style: Ae.body(14, c: Ae.dim, h: 1.35)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(on ? 'ON' : 'OFF',
                    style: Ae.label(13, c: on ? Ae.gold : Ae.dim)),
              ],
            ),
          ),
        ),
      );

  Widget _toggle(String label, bool on, VoidCallback tap) => GestureDetector(
        onTap: tap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: on ? Ae.gold.withValues(alpha: .16) : Ae.ink2,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: on ? Ae.gold : Ae.panelHi, width: 1.4),
          ),
          child: Text('$label  ${on ? "ON" : "OFF"}',
              style: Ae.label(13, c: on ? Ae.bone : Ae.dim)),
        ),
      );

  void _confirmAbandon(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Ae.panel,
        title: Text('Abandon this draft?', style: Ae.display(20)),
        content: Text(
            'The run ends here and its Aeon Shards are lost. The Sanctum keeps what you '
            'have already earned.',
            style: Ae.body(16, c: Ae.dim)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Keep going', style: Ae.body(16, c: Ae.gold))),
          TextButton(
            onPressed: () {
              Game.i.abandonRun();
              Navigator.pop(context);
              setState(() {});
            },
            child: Text('Abandon', style: Ae.body(16, c: Ae.blood, w: 700)),
          ),
        ],
      ),
    );
  }

  void _openSanctum(BuildContext context) {
    Audio.i.sfx('tap');
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _SanctumSheet(),
    ).then((_) => setState(() {}));
  }
}

class _Upgrade {
  const _Upgrade(this.id, this.name, this.desc, this.cost);
  final String id;
  final String name;
  final String desc;
  final int cost;
}

const _upgrades = <_Upgrade>[
  _Upgrade('vigor', 'Vigour of the Reused', 'Begin every run with +10 max HP.', 220),
  _Upgrade('purse', 'Deeper Purse', 'Begin every run with +60 Aeon.', 180),
  _Upgrade('sigil', 'Inherited Sigil', 'Begin every run with an extra sigil.', 320),
  _Upgrade('archive', 'The Archive', 'Frame rewards always offer one extra choice.', 280),
];

const _vesselUnlocks = <String, int>{
  'umbralnyx': 400,
  'lumenherald': 480,
};

class _SanctumSheet extends StatefulWidget {
  const _SanctumSheet();

  @override
  State<_SanctumSheet> createState() => _SanctumSheetState();
}

class _SanctumSheetState extends State<_SanctumSheet> {
  @override
  Widget build(BuildContext context) {
    final m = Game.i.meta;
    return Container(
      height: MediaQuery.of(context).size.height * .82,
      decoration: const BoxDecoration(
        color: Ae.ink2,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: Ae.gold, width: 2)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 46, height: 4, color: Ae.panelHi),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Expanded(child: Heading('THE SANCTUM', sub: 'What survives the Fall', size: 24)),
                Text('${m.shards}', style: Ae.display(26, c: Ae.gold)),
                Text('  SHARDS', style: Ae.label(12)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              children: [
                Text('PERMANENT BOONS', style: Ae.label(14)),
                const SizedBox(height: 10),
                for (final u in _upgrades) _row(m, u.id, u.name, u.desc, u.cost,
                    owned: m.upgrades.contains(u.id), onBuy: () => m.upgrades.add(u.id)),
                const SizedBox(height: 22),
                Text('VESSELS', style: Ae.label(14)),
                const SizedBox(height: 10),
                for (final e in _vesselUnlocks.entries)
                  _row(
                    m,
                    e.key,
                    vesselById(e.key).title,
                    vesselById(e.key).blurb,
                    e.value,
                    owned: m.vessels.contains(e.key),
                    onBuy: () => m.vessels.add(e.key),
                  ),
                if (!m.vessels.contains('paradox'))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: AePanel(
                      child: Text(
                        'THE PARADOX SCRIBE  ·  locked\nReach Act III with any Vessel to '
                        'unlock him.',
                        style: Ae.body(15, c: Ae.dim),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(m, String id, String name, String desc, int cost,
      {required bool owned, required VoidCallback onBuy}) {
    final afford = m.shards >= cost;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AePanel(
        border: owned ? Ae.good : Ae.panelHi,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name.toUpperCase(), style: Ae.label(15, c: owned ? Ae.good : Ae.bone)),
                  const SizedBox(height: 5),
                  Text(desc, style: Ae.body(15, c: Ae.dim)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (owned)
              Text('OWNED', style: Ae.label(13, c: Ae.good))
            else
              GestureDetector(
                onTap: afford
                    ? () {
                        Audio.i.sfx('relic');
                        m.shards -= cost;
                        onBuy();
                        Game.i.saveMeta();
                        setState(() {});
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: afford ? Ae.gold.withValues(alpha: .18) : Ae.panel,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: afford ? Ae.gold : Ae.panelHi, width: 1.4),
                  ),
                  child: Text('$cost',
                      style: Ae.body(16, w: 800, c: afford ? Ae.gold : Ae.dim)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
