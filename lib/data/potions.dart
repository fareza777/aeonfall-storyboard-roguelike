import '../engine/core.dart';

/// Draughts — the consumable pillar the game shipped without.
///
/// A run carries three at a time. They exist to give the player an out when
/// the forecast says LETHAL and the hand does not answer it, which is the one
/// position where the combat had nothing to offer but a shrug.
///
/// Every effect is expressed with the ordinary [Fx] vocabulary, so the battle
/// engine resolves a draught through exactly the same path as a frame. None of
/// them need a target — they hit all foes or the bearer — so drinking one is
/// always a single tap.
class PotionDef {
  const PotionDef({
    required this.id,
    required this.name,
    required this.desc,
    required this.rarity,
    required this.fx,
    this.elem = Elem.none,
    this.outOfBattle = false,
    this.art,
  });

  final String id;
  final String name;
  final String desc;
  final Rarity rarity;
  final List<Fx> fx;
  final Elem elem;

  /// Can also be drunk on the map, not only mid-fight.
  final bool outOfBattle;
  final String? art;

  String artKey() => art ?? 'potion_$id';
}

const _c = Rarity.common;
const _u = Rarity.uncommon;
const _r = Rarity.rare;

const kPotions = <PotionDef>[
  // ------------------------------------------------------------- common
  PotionDef(
    id: 'ashflask',
    name: 'Ash Flask',
    desc: 'Deal 10 damage to every foe and set Burn 4 on all of them.',
    rarity: _c,
    elem: Elem.ember,
    fx: [
      Fx(FxKind.damageAll, value: 10, target: FxTarget.allEnemies),
      Fx(FxKind.statusAll, value: 4, arg: 'burn', target: FxTarget.allEnemies),
    ],
  ),
  PotionDef(
    id: 'stillwater',
    name: 'Stillwater',
    desc: 'Gain 20 Guard immediately.',
    rarity: _c,
    elem: Elem.frost,
    fx: [Fx(FxKind.block, value: 20, target: FxTarget.self)],
  ),
  PotionDef(
    id: 'torndraft',
    name: 'Torn Draft',
    desc: 'Draw 3 frames.',
    rarity: _c,
    fx: [Fx(FxKind.draw, value: 3, target: FxTarget.self)],
  ),
  PotionDef(
    id: 'quickink',
    name: 'Quick Ink',
    desc: 'Gain 2 Aether this turn.',
    rarity: _c,
    fx: [Fx(FxKind.energy, value: 2, target: FxTarget.self)],
  ),
  PotionDef(
    id: 'saltbind',
    name: 'Salt Bind',
    desc: 'Apply Weak 3 to every foe.',
    rarity: _c,
    fx: [Fx(FxKind.statusAll, value: 3, arg: 'weak', target: FxTarget.allEnemies)],
  ),
  PotionDef(
    id: 'thawing',
    name: 'Thawing Draught',
    desc: 'Remove every condition on you.',
    rarity: _c,
    fx: [Fx(FxKind.cleanse, target: FxTarget.self)],
  ),
  PotionDef(
    id: 'smallmercy',
    name: 'Small Mercy',
    desc: 'Heal 25. Can be drunk on the road.',
    rarity: _c,
    elem: Elem.lumen,
    outOfBattle: true,
    fx: [Fx(FxKind.heal, value: 25, target: FxTarget.self)],
  ),
  PotionDef(
    id: 'chalkdust',
    name: 'Chalk Dust',
    desc: 'Apply Vulnerable 3 to every foe.',
    rarity: _c,
    fx: [Fx(FxKind.statusAll, value: 3, arg: 'vulnerable', target: FxTarget.allEnemies)],
  ),

  // ----------------------------------------------------------- uncommon
  PotionDef(
    id: 'whetstone',
    name: 'Whetstone Oil',
    desc: 'Gain Strength 3 for the rest of the fight.',
    rarity: _u,
    fx: [Fx(FxKind.selfStatus, value: 3, arg: 'strength', target: FxTarget.self)],
  ),
  PotionDef(
    id: 'lanternoil',
    name: 'Lantern Oil',
    desc: 'Gain Radiance 3 — healing and Lumen hit half again as hard.',
    rarity: _u,
    elem: Elem.lumen,
    fx: [Fx(FxKind.selfStatus, value: 3, arg: 'radiance', target: FxTarget.self)],
  ),
  PotionDef(
    id: 'gravewater',
    name: 'Gravewater',
    desc: 'Apply Poison 6 to every foe.',
    rarity: _u,
    elem: Elem.umbra,
    fx: [Fx(FxKind.statusAll, value: 6, arg: 'poison', target: FxTarget.allEnemies)],
  ),
  PotionDef(
    id: 'stormbottle',
    name: 'Storm in a Bottle',
    desc: 'Deal 14 damage to every foe and Shock 2 all of them.',
    rarity: _u,
    elem: Elem.volt,
    fx: [
      Fx(FxKind.damageAll, value: 14, target: FxTarget.allEnemies),
      Fx(FxKind.statusAll, value: 2, arg: 'shock', target: FxTarget.allEnemies),
    ],
  ),
  PotionDef(
    id: 'mirrorbrine',
    name: 'Mirror Brine',
    desc: 'Gain Ward 2 — the next two attacks on you simply do not land.',
    rarity: _u,
    elem: Elem.frost,
    fx: [Fx(FxKind.selfStatus, value: 2, arg: 'ward', target: FxTarget.self)],
  ),
  PotionDef(
    id: 'fossilmilk',
    name: 'Fossil Milk',
    desc: 'Gain 15 Guard and Fortify — your Guard stops draining away.',
    rarity: _u,
    elem: Elem.frost,
    fx: [
      Fx(FxKind.block, value: 15, target: FxTarget.self),
      Fx(FxKind.selfStatus, value: 1, arg: 'fortify', target: FxTarget.self),
    ],
  ),
  PotionDef(
    id: 'pagedust',
    name: 'Page Dust',
    desc: 'Gain Echo 2 — your next two frames each resolve twice.',
    rarity: _u,
    elem: Elem.umbra,
    fx: [Fx(FxKind.selfStatus, value: 2, arg: 'echo', target: FxTarget.self)],
  ),
  PotionDef(
    id: 'bloodrite',
    name: 'Blood Rite',
    desc: 'Lose 8 HP. Gain 3 Aether and draw 2.',
    rarity: _u,
    elem: Elem.umbra,
    fx: [
      Fx(FxKind.loseHp, value: 8, target: FxTarget.self),
      Fx(FxKind.energy, value: 3, target: FxTarget.self),
      Fx(FxKind.draw, value: 2, target: FxTarget.self),
    ],
  ),
  PotionDef(
    id: 'coldiron',
    name: 'Cold Iron',
    desc: 'Apply Rime 4 to every foe — they all take a third more damage.',
    rarity: _u,
    elem: Elem.frost,
    fx: [Fx(FxKind.statusAll, value: 4, arg: 'rime', target: FxTarget.allEnemies)],
  ),
  PotionDef(
    id: 'thorncrown',
    name: 'Thorn Crown',
    desc: 'Gain Thorns 6 — anything that hits you takes 6 back.',
    rarity: _u,
    fx: [Fx(FxKind.selfStatus, value: 6, arg: 'thorns', target: FxTarget.self)],
  ),
  PotionDef(
    id: 'emberwake',
    name: 'Emberwake',
    desc: 'Gain Overcharge 1 — deal half again more, take a quarter more.',
    rarity: _u,
    elem: Elem.ember,
    fx: [Fx(FxKind.selfStatus, value: 1, arg: 'overcharge', target: FxTarget.self)],
  ),
  PotionDef(
    id: 'veilwater',
    name: 'Veil Water',
    desc: 'Gain Stealth — nothing can target you this turn.',
    rarity: _u,
    elem: Elem.umbra,
    fx: [Fx(FxKind.selfStatus, value: 1, arg: 'stealth', target: FxTarget.self)],
  ),

  // --------------------------------------------------------------- rare
  PotionDef(
    id: 'authorsink',
    name: 'Author\'s Ink',
    desc: 'Upgrade every frame in your hand for the rest of this fight.',
    rarity: _r,
    fx: [Fx(FxKind.upgradeHand, target: FxTarget.self)],
  ),
  PotionDef(
    id: 'secondwind',
    name: 'Second Wind',
    desc: 'Heal 45 and clear every condition. Can be drunk on the road.',
    rarity: _r,
    elem: Elem.lumen,
    outOfBattle: true,
    fx: [
      Fx(FxKind.heal, value: 45, target: FxTarget.self),
      Fx(FxKind.cleanse, target: FxTarget.self),
    ],
  ),
  PotionDef(
    id: 'laststroke',
    name: 'The Last Stroke',
    desc: 'Deal 30 damage to every foe, ignoring Guard.',
    rarity: _r,
    fx: [Fx(FxKind.pierce, value: 30, target: FxTarget.allEnemies)],
  ),
  PotionDef(
    id: 'eclipsevial',
    name: 'Eclipse Vial',
    desc: 'Apply Doom 4 to every foe. When it runs out, they lose a third of themselves.',
    rarity: _r,
    elem: Elem.umbra,
    fx: [Fx(FxKind.statusAll, value: 4, arg: 'doom', target: FxTarget.allEnemies)],
  ),
  PotionDef(
    id: 'aetherheart',
    name: 'Aether Heart',
    desc: 'Gain 4 Aether now and 2 more at the start of next turn.',
    rarity: _r,
    elem: Elem.volt,
    fx: [
      Fx(FxKind.energy, value: 4, target: FxTarget.self),
      Fx(FxKind.gainEnergyNextTurn, value: 2, target: FxTarget.self),
    ],
  ),
  PotionDef(
    id: 'immortalsdram',
    name: 'The Immortal\'s Dram',
    desc: 'Gain Ward 3 and Regen 8.',
    rarity: _r,
    elem: Elem.lumen,
    fx: [
      Fx(FxKind.selfStatus, value: 3, arg: 'ward', target: FxTarget.self),
      Fx(FxKind.selfStatus, value: 8, arg: 'regen', target: FxTarget.self),
    ],
  ),
];

final Map<String, PotionDef> kPotionById = {for (final p in kPotions) p.id: p};

PotionDef potionDef(String id) => kPotionById[id] ?? kPotions.first;

/// Weighted draw, tightened by act.
///
/// A flat 6:3:1 meant roughly one draught in ten was a rare, from the first
/// floor onwards, which made the strongest tier ordinary. Rares now cannot
/// appear in Act I at all and stay uncommon after it, so finding The Last
/// Stroke is an event rather than a Tuesday.
int potionWeight(Rarity r, int act) => switch (r) {
      Rarity.common => switch (act) { 1 => 12, 2 => 9, _ => 7 },
      Rarity.uncommon => switch (act) { 1 => 3, 2 => 5, _ => 6 },
      Rarity.rare => switch (act) { 1 => 0, 2 => 1, _ => 2 },
      _ => 0,
    };
