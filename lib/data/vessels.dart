import '../engine/core.dart';

class VesselDef {
  const VesselDef({
    required this.id,
    required this.name,
    required this.title,
    required this.elem,
    required this.hp,
    required this.energy,
    required this.blurb,
    required this.lore,
    required this.playstyle,
    required this.deck,
    required this.relic,
    required this.cinematic,
    required this.cinematicName,
    this.locked = false,
    this.unlockHint = '',
  });

  final String id;
  final String name;
  final String title;
  final Elem elem;
  final int hp;
  final int energy;
  final String blurb;
  final String lore;
  final String playstyle;

  /// card id -> copies
  final Map<String, int> deck;
  final String relic;
  final String cinematicName;
  final String cinematic;
  final bool locked;
  final String unlockHint;

  String get art => 'vessel_$id';
  String get crest => 'crest_$id';
  String get awakened => 'awake_$id';
}

const kVessels = <VesselDef>[
  VesselDef(
    id: 'ashcaller',
    name: 'VYN',
    title: 'The Ashcaller',
    elem: Elem.ember,
    hp: 74,
    energy: 3,
    blurb: 'Burns brighter the closer she gets to the end.',
    lore:
        'They drew her to die in the second panel — a torch-bearer, one line of dialogue, '
        'a body to light the hero\'s way. She burned for eleven pages instead of two, and '
        'the composition never recovered. Now every draft keeps her, because a fire that '
        'refuses to go out is the only thing on the page that looks alive.\n\n'
        'She does not remember the Falls. She remembers being warm, and then not.',
    playstyle:
        'Stacks Burn and pays her own health for tempo. Weak early, unstoppable if the '
        'fight goes long enough for her Cinders to build.',
    deck: {
      'em_strike': 4,
      'ae_guard': 3,
      'em_kindle': 2,
      'em_brand': 1,
      'ae_stancecut': 1,
    },
    relic: 'ember_heart',
    cinematicName: 'IMMOLATION FRAME',
    cinematic: 'Deal 12 damage to every foe and set them all alight with 6 Burn.',
  ),
  VesselDef(
    id: 'saintcoralis',
    name: 'CORALIS',
    title: 'The Glacier Saint',
    elem: Elem.frost,
    hp: 88,
    energy: 3,
    blurb: 'Turns everything she survives into a wall.',
    lore:
        'A saint written to be martyred — that is the whole function of a saint in a draft '
        'like this one. The Author drew the spear. Coralis caught it. She has been standing '
        'in the same doorway for three thousand versions of the same siege, and the doorway '
        'has never once fallen.\n\n'
        'She is not brave. She simply cannot think of what else a person would do.',
    playstyle:
        'Converts Guard into offence. The longer she holds the line, the harder the line '
        'hits back.',
    deck: {
      'fr_lance': 4,
      'ae_guard': 4,
      'fr_bulwark': 1,
      'fr_rime': 1,
      'ae_scrapshield': 1,
    },
    relic: 'frost_tear',
    cinematicName: 'GLACIER FRAME',
    cinematic: 'Gain 24 Guard, then strike every foe for the Guard you now hold.',
  ),
  VesselDef(
    id: 'voltborn',
    name: 'KAI',
    title: 'The Voltborn',
    elem: Elem.volt,
    hp: 70,
    energy: 4,
    blurb: 'Four heartbeats a second, none of them his.',
    lore:
        'Struck by lightning in a panel that was supposed to kill a different man. The '
        'Author redrew it twice; the bolt found Kai both times. He took that as an opinion.\n\n'
        'He talks fast because he has learned that the page turns whether or not he is '
        'finished speaking.',
    playstyle:
        'Extra energy and rapid multi-hits. Chains Shock across the board and detonates it '
        'with volume, not weight.',
    deck: {
      'vo_arc': 4,
      'ae_guard': 3,
      'vo_sparkstep': 2,
      'vo_relay': 1,
      'ae_dagger': 1,
    },
    relic: 'volt_nail',
    cinematicName: 'JUDGMENT FRAME',
    cinematic: 'Strike a random foe 9 times for 4, arcing Shock 2 on every hit.',
  ),
  VesselDef(
    id: 'umbralnyx',
    name: 'NYX',
    title: 'The Umbral Weaver',
    elem: Elem.umbra,
    hp: 68,
    energy: 3,
    blurb: 'Never on stage. Always holding the strings.',
    lore:
        'Nyx was drawn as scenery — a puppeteer in the corner of a market panel, three lines '
        'of ink, no face. Nobody erases scenery. That is how she has watched every Fall from '
        'the beginning, taking notes.\n\n'
        'She is the only Vessel who has never once been surprised.',
    playstyle:
        'Curses, drains and Echo. Replays her own best frames and makes the enemy pay '
        'interest on every turn it survives.',
    deck: {
      'um_grasp': 4,
      'ae_guard': 3,
      'um_whisper': 2,
      'um_leech': 1,
      'ae_dagger': 1,
    },
    relic: 'umbra_thread',
    cinematicName: 'ECLIPSE FRAME',
    cinematic: 'Deal 20 damage that ignores Guard to all foes and mark each with Doom 4.',
  ),
  VesselDef(
    id: 'lumenherald',
    name: 'SOLENNE',
    title: 'The Lumen Herald',
    elem: Elem.lumen,
    hp: 80,
    energy: 3,
    blurb: 'Blindfolded, because she was drawn without eyes and refuses to admit it.',
    lore:
        'Heralds announce. That is all they are for: one panel, one proclamation, then out '
        'of frame forever. Solenne announced the end of the world and then simply stayed, '
        'standing at the edge of the panel, waiting to see whether it was true.\n\n'
        'It was true. It has been true three thousand times. She has never once left.',
    playstyle:
        'Wards, healing and Radiance. Survives what should kill her and converts mercy into '
        'raw damage.',
    deck: {
      'lu_ray': 4,
      'ae_guard': 3,
      'lu_mend': 2,
      'lu_ward': 1,
      'ae_stancecut': 1,
    },
    relic: 'lumen_shard',
    cinematicName: 'DAWNBREAK FRAME',
    cinematic: 'Heal 14, gain Ward 2, and burn every foe for 18 Lumen damage.',
  ),
  VesselDef(
    id: 'paradox',
    name: 'ORIN',
    title: 'The Paradox Scribe',
    elem: Elem.none,
    hp: 64,
    energy: 3,
    blurb: 'Half of him is still a rough sketch. He prefers it that way.',
    lore:
        'Orin was a research note in the margin — a scholar the Author invented to explain '
        'something, then forgot to erase. Marginalia is not bound by the panel. He has read '
        'every draft from the outside, which is why he is the only Vessel who knows what the '
        'Author actually is, and why he has never told anyone.\n\n'
        'He says telling you would fix you in place. He may be lying. He is unfinished; '
        'lying is one of the things he was never given.',
    playstyle:
        'Rewrites the run itself — copies frames, discounts costs, gambles hard. The highest '
        'ceiling and the highest chance of drawing your own defeat.',
    deck: {
      'px_rewrite': 3,
      'ae_guard': 3,
      'px_gambit': 2,
      'px_marginalia': 2,
      'ae_stancecut': 2,
    },
    relic: 'broken_hourglass',
    cinematicName: 'REVISION FRAME',
    cinematic:
        'Discard your hand, draw 5, gain 3 Energy, and copy the last frame you played.',
    locked: true,
    unlockHint: 'Reach Act III with any Vessel.',
  ),
];

VesselDef vesselById(String id) =>
    kVessels.firstWhere((v) => v.id == id, orElse: () => kVessels.first);
