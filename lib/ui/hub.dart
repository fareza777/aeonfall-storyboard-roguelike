import 'package:flutter/material.dart';

import '../audio.dart';
import '../data/ascension.dart';
import '../data/vessels.dart';
import '../game.dart';
import '../theme.dart';
import 'codex.dart';
import 'how_to_play.dart';
import 'map_screen.dart';
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
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
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
              const SizedBox(height: 14),
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

  Widget _settings(m) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _toggle('MUSIC', m.music, () {
            setState(() => m.music = !m.music);
            Audio.i.setMusic(m.music);
            if (m.music) Audio.i.music('hub');
            Game.i.saveMeta();
          }),
          const SizedBox(width: 12),
          _toggle('SOUND', m.sfx, () {
            setState(() => m.sfx = !m.sfx);
            Audio.i.sfxOn = m.sfx;
            Audio.i.sfx('tap');
            Game.i.saveMeta();
          }),
        ],
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
