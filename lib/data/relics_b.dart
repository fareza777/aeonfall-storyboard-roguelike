import '../engine/core.dart';
import 'card_build.dart';

/// Second sigil book.
///
/// The first shipped with twelve commons against twenty-four uncommons, so the
/// tier a player sees most often was the thinnest. These even that out, add a
/// belt slot for the new draughts, and give every boss a sigil that only it
/// drops — so beating a specific boss is worth something specific.
RelicDef _r(String id, String name, String desc, Rarity rarity, RelicTrigger t,
        {int value = 0, String? arg, List<Fx> fx = const []}) =>
    RelicDef(
      id: id,
      name: name,
      desc: desc,
      rarity: rarity,
      trigger: t,
      value: value,
      arg: arg,
      art: 'relic_$id',
      fx: fx,
    );

const _bs = RelicTrigger.onBattleStart;
const _ts = RelicTrigger.onTurnStart;
const _pas = RelicTrigger.passive;

// ══════════════════════════════════════════════ commons — the thin tier
final kRelicsCommonB = <RelicDef>[
  _r('deep_satchel', 'Deep Satchel',
      'Carry a fourth draught, and find them more often.', Rarity.common, _pas),
  _r('chipped_whetstone', 'Chipped Whetstone',
      'Gain 1 Strength at the start of each battle.', Rarity.common, _bs,
      fx: [me('strength', 1)]),
  _r('tin_cup', 'Tin Cup', 'Gain 4 Guard at the start of each turn.',
      Rarity.common, _ts, fx: [blk(4)]),
  _r('short_wick', 'Short Wick',
      'Apply 1 Burn to every foe at the start of each turn.', Rarity.common, _ts,
      fx: [stAll('burn', 1)]),
  _r('salt_pouch', 'Salt Pouch',
      'Apply 1 Weak to every foe when a battle begins.', Rarity.common, _bs,
      fx: [stAll('weak', 1)]),
  _r('dry_kindling', 'Dry Kindling',
      'Draw 1 extra frame on the first turn of every battle.', Rarity.common, _bs,
      fx: [draw(1)]),
  _r('bone_needle', 'Bone Needle',
      'Apply 2 Poison to every foe when a battle begins.', Rarity.common, _bs,
      fx: [stAll('poison', 2)]),
  _r('cracked_lens', 'Cracked Lens',
      'Apply 1 Vulnerable to every foe when a battle begins.', Rarity.common, _bs,
      fx: [stAll('vulnerable', 1)]),
  _r('wool_lining', 'Wool Lining', 'Gain 6 Guard when a battle begins.',
      Rarity.common, _bs, fx: [blk(6)]),
  _r('travellers_crust', 'Traveller\'s Crust',
      'Heal 3 at the start of each turn.', Rarity.common, _ts, fx: [heal(3)]),
  _r('copper_pin', 'Copper Pin', 'Gain Regen 3 when a battle begins.',
      Rarity.common, _bs, fx: [me('regen', 3)]),
  _r('lodestone_chip', 'Lodestone Chip',
      'Apply 1 Shock to every foe when a battle begins.', Rarity.common, _bs,
      fx: [stAll('shock', 1)]),
  _r('pressed_flower', 'Pressed Flower', 'Gain Thorns 3 when a battle begins.',
      Rarity.common, _bs, fx: [me('thorns', 3)]),
  _r('char_stub', 'Charcoal Stub',
      'Gain 1 Momentum at the start of each turn.', Rarity.common, _ts,
      fx: [me('momentum', 1)]),
  _r('cold_compress', 'Cold Compress',
      'Apply 1 Rime to every foe at the start of each turn.', Rarity.common, _ts,
      fx: [stAll('rime', 1)]),
];

// ══════════════════════════════════════════════════ a few more mythics
final kRelicsMythicB = <RelicDef>[
  _r('the_understudys_notes', 'The Understudy\'s Notes',
      'Gain 1 Aether and 1 Strength at the start of each turn.',
      Rarity.mythic, _ts, fx: [nrg(1), me('strength', 1)]),
  _r('unspent_page', 'The Unspent Page',
      'Begin every battle with Ward 2 and Echo 1.', Rarity.mythic, _bs,
      fx: [me('ward', 2), me('echo', 1)]),
  _r('second_hand', 'The Second Hand',
      'Draw 2 extra frames and gain 10 Guard when a battle begins.',
      Rarity.mythic, _bs, fx: [draw(2), blk(10)]),
  _r('kitchen_scene', 'Two Pages From a Kitchen',
      'Heal 6 and gain 6 Guard at the start of every turn. Nothing in it matters. '
          'It is the best thing you are carrying.',
      Rarity.mythic, _ts, fx: [heal(6), blk(6)]),
];

// ═══════════════════════════════════ boss sigils — one per boss, exclusive
/// Never rolled from the ordinary pool. [bossRelicFor] hands one out when the
/// matching boss goes down, so a specific kill is worth a specific thing.
final kBossRelics = <RelicDef>[
  _r('illustrators_brush', 'The Illustrator\'s Brush',
      'Gain 2 Strength when a battle begins.', Rarity.rare, _bs,
      fx: [me('strength', 2)]),
  _r('pyre_ember', 'Ember of the Pyre',
      'Apply 3 Burn to every foe at the start of each turn.', Rarity.rare, _ts,
      fx: [stAll('burn', 3)]),
  _r('hoarmothers_shawl', 'The Hoarmother\'s Shawl',
      'Gain 10 Guard and Fortify when a battle begins.', Rarity.rare, _bs,
      fx: [blk(10), me('fortify', 1)]),
  _r('erasers_nub', 'The Eraser\'s Nub',
      'Begin each battle immune to the first condition put on you.',
      Rarity.rare, _bs, fx: [me('ward', 1)]),
  _r('chorus_gear', 'A Gear From the Chorus Engine',
      'Apply 2 Shock to every foe at the start of each turn.', Rarity.rare, _ts,
      fx: [stAll('shock', 2)]),
  _r('archivists_index', 'The Archivist\'s Index',
      'Draw 1 extra frame every turn.', Rarity.rare, _ts, fx: [draw(1)]),
  _r('risen_script', 'The Risen Script',
      'Gain 1 Aether at the start of each turn.', Rarity.rare, _ts, fx: [nrg(1)]),
  _r('mourning_spring', 'A Spring From the Mourning Engine',
      'Apply 4 Poison to every foe when a battle begins.', Rarity.rare, _bs,
      fx: [stAll('poison', 4)]),
  _r('gilded_promise', 'The Gilded Promise',
      'Heal 8 at the start of each turn.', Rarity.rare, _ts, fx: [heal(8)]),
  _r('saints_rod', 'The Thunderhead Saint\'s Rod',
      'Gain Overcharge when a battle begins.', Rarity.rare, _bs,
      fx: [me('overcharge', 1)]),
  _r('blank_leaf', 'A Leaf of the Blank Page',
      'Gain 12 Guard at the start of each turn.', Rarity.rare, _ts, fx: [blk(12)]),
  _r('collaborators_note', 'The Collaborator\'s Note',
      'Gain Radiance 2 at the start of each turn.', Rarity.rare, _ts,
      fx: [me('radiance', 2)]),
  _r('readers_bookmark', 'The Reader\'s Bookmark',
      'Draw 2 extra frames when a battle begins.', Rarity.rare, _bs, fx: [draw(2)]),
  _r('ninth_shard', 'A Shard of the Ninth Fall',
      'Apply 3 Rime to every foe when a battle begins.', Rarity.rare, _bs,
      fx: [stAll('rime', 3)]),
  _r('margin_strip', 'A Strip of the Margin',
      'Gain 1 Momentum and 4 Guard at the start of each turn.', Rarity.rare, _ts,
      fx: [me('momentum', 1), blk(4)]),
];

/// Which sigil a given boss leaves behind. Falls through to null for the
/// original bosses that already had bespoke drops elsewhere.
const kBossRelicByFoe = <String, String>{
  'the_illustrator': 'illustrators_brush',
  'pyre_of_drafts': 'pyre_ember',
  'hoarmother': 'hoarmothers_shawl',
  'the_eraser': 'erasers_nub',
  'chorus_engine': 'chorus_gear',
  'the_archivist': 'archivists_index',
  'the_understudy_risen': 'risen_script',
  'mourning_engine': 'mourning_spring',
  'the_gilded_end': 'gilded_promise',
  'thunderhead_saint': 'saints_rod',
  'the_blank_page': 'blank_leaf',
  'the_collaborator': 'collaborators_note',
  'the_reader': 'readers_bookmark',
  'the_ninth_fall': 'ninth_shard',
  'the_margin': 'margin_strip',
};

String? bossRelicFor(String foeId) => kBossRelicByFoe[foeId];

/// Everything that should join the ordinary reward pool.
final kRelicsB = <RelicDef>[...kRelicsCommonB, ...kRelicsMythicB];
