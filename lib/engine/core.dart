import 'package:flutter/material.dart';
import '../theme.dart';

// ---------------------------------------------------------------- elements
enum Elem { none, ember, frost, volt, umbra, lumen }

extension ElemX on Elem {
  String get label => const {
        Elem.none: 'Void',
        Elem.ember: 'Ember',
        Elem.frost: 'Frost',
        Elem.volt: 'Volt',
        Elem.umbra: 'Umbra',
        Elem.lumen: 'Lumen',
      }[this]!;

  Color get color => const {
        Elem.none: Ae.dim,
        Elem.ember: Ae.ember,
        Elem.frost: Ae.frost,
        Elem.volt: Ae.volt,
        Elem.umbra: Ae.umbra,
        Elem.lumen: Ae.lumen,
      }[this]!;

  String get glyph => const {
        Elem.none: '◇',
        Elem.ember: '✹',
        Elem.frost: '❄',
        Elem.volt: '⚡',
        Elem.umbra: '●',
        Elem.lumen: '☀',
      }[this]!;
}

/// The reaction matrix — the beating heart of AEONFALL's combat depth.
/// Applying element B onto a target already carrying aura A triggers a reaction.
class Reaction {
  const Reaction(this.id, this.name, this.blurb, this.color);
  final String id;
  final String name;
  final String blurb;
  final Color color;
}

const kReactions = <String, Reaction>{
  'vaporize': Reaction('vaporize', 'VAPORIZE', 'Doubles the triggering hit.', Ae.ember),
  'overload': Reaction('overload', 'OVERLOAD', 'Detonates for splash damage on every foe.', Ae.ember),
  'wither': Reaction('wither', 'WITHER', 'Strips half of the target\'s guard and rots it.', Ae.umbra),
  'purge': Reaction('purge', 'PURGE', 'Burns away every buff and punishes each one.', Ae.lumen),
  'superconduct': Reaction('superconduct', 'SUPERCONDUCT', 'Freezes solid and cracks the shell open.', Ae.frost),
  'deepfreeze': Reaction('deepfreeze', 'DEEPFREEZE', 'Scrambles the foe\'s plan and makes it brittle.', Ae.frost),
  'prism': Reaction('prism', 'PRISM', 'Refracts the hit back into guard for you.', Ae.frost),
  'blackout': Reaction('blackout', 'BLACKOUT', 'Silences the foe — no special move next turn.', Ae.umbra),
  'judgment': Reaction('judgment', 'JUDGMENT', 'Chains lightning across the whole board.', Ae.volt),
  'eclipse': Reaction('eclipse', 'ECLIPSE', 'True damage and a countdown to death.', Ae.umbra),
};

String? reactionFor(Elem a, Elem b) {
  final s = {a, b};
  bool has(Elem x, Elem y) => s.containsAll({x, y});
  if (a == b || a == Elem.none || b == Elem.none) return null;
  if (has(Elem.ember, Elem.frost)) return 'vaporize';
  if (has(Elem.ember, Elem.volt)) return 'overload';
  if (has(Elem.ember, Elem.umbra)) return 'wither';
  if (has(Elem.ember, Elem.lumen)) return 'purge';
  if (has(Elem.frost, Elem.volt)) return 'superconduct';
  if (has(Elem.frost, Elem.umbra)) return 'deepfreeze';
  if (has(Elem.frost, Elem.lumen)) return 'prism';
  if (has(Elem.volt, Elem.umbra)) return 'blackout';
  if (has(Elem.volt, Elem.lumen)) return 'judgment';
  if (has(Elem.umbra, Elem.lumen)) return 'eclipse';
  return null;
}

// ---------------------------------------------------------------- statuses
class StatusDef {
  const StatusDef(this.id, this.name, this.desc,
      {this.debuff = false, this.glyph = '●', this.color = Ae.dim});
  final String id;
  final String name;
  final String desc;
  final bool debuff;
  final String glyph;
  final Color color;
}

const kStatus = <String, StatusDef>{
  'burn': StatusDef('burn', 'Burn', 'At end of turn, take damage equal to Burn, then it drops by 1.',
      debuff: true, glyph: '✹', color: Ae.ember),
  'poison': StatusDef('poison', 'Poison', 'End of turn: lose HP equal to Poison, ignoring guard. Drops by 1.',
      debuff: true, glyph: '☠', color: Color(0xFF8FBF5A)),
  'bleed': StatusDef('bleed', 'Bleed', 'Loses HP equal to Bleed whenever it attacks.',
      debuff: true, glyph: '▼', color: Ae.blood),
  'rime': StatusDef('rime', 'Rime', 'Takes +30% damage. Drops by 1 each turn.',
      debuff: true, glyph: '❄', color: Ae.frost),
  'shock': StatusDef('shock', 'Shock', 'When damaged, arcs 3 damage to another foe.',
      debuff: true, glyph: '⚡', color: Ae.volt),
  'frozen': StatusDef('frozen', 'Frozen', 'Skips its turn entirely.',
      debuff: true, glyph: '❅', color: Ae.frost),
  'silence': StatusDef('silence', 'Silence', 'Cannot use its special action.',
      debuff: true, glyph: '⊘', color: Ae.umbra),
  'weak': StatusDef('weak', 'Weak', 'Deals 25% less attack damage.',
      debuff: true, glyph: '↓', color: Color(0xFF9C7FB8)),
  'vulnerable': StatusDef('vulnerable', 'Vulnerable', 'Takes 40% more attack damage.',
      debuff: true, glyph: '✖', color: Ae.blood),
  'decay': StatusDef('decay', 'Decay', 'Cannot be healed. Loses 2 max HP each turn.',
      debuff: true, glyph: '☠', color: Color(0xFF6E7F5A)),
  'doom': StatusDef('doom', 'Doom', 'When it hits 0, the bearer loses 35% of max HP.',
      debuff: true, glyph: '⏳', color: Ae.umbra),
  'entangle': StatusDef('entangle', 'Entangle', 'Cannot play Attack frames this turn.',
      debuff: true, glyph: '❉', color: Color(0xFF7FA36B)),
  'curse': StatusDef('curse', 'Curse', 'Draw 1 fewer frame each turn.',
      debuff: true, glyph: '✡', color: Ae.umbra),
  'strength': StatusDef('strength', 'Strength', 'Each attack hit deals +Strength damage.',
      glyph: '⚔', color: Ae.ember),
  'guard': StatusDef('guard', 'Guard', 'Each Guard gain is increased by this much.',
      glyph: '⛨', color: Ae.frost),
  'fortify': StatusDef('fortify', 'Fortify', 'Guard is not cleared at the start of your turn.',
      glyph: '⛊', color: Ae.frost),
  'regen': StatusDef('regen', 'Regen', 'Heal this much at end of turn, then it drops by 1.',
      glyph: '✚', color: Ae.good),
  'thorns': StatusDef('thorns', 'Thorns', 'Attackers take this much damage back.',
      glyph: '⚘', color: Color(0xFF9BB07C)),
  'radiance': StatusDef('radiance', 'Radiance', 'Healing and Lumen damage +50%. Drops by 1.',
      glyph: '☀', color: Ae.lumen),
  'overcharge': StatusDef('overcharge', 'Overcharge', 'Deal +50% damage, take +25% damage.',
      glyph: '⚡', color: Ae.volt),
  'momentum': StatusDef('momentum', 'Momentum', 'Your next attack deals +2 per stack, then it clears.',
      glyph: '➤', color: Ae.gold),
  'ward': StatusDef('ward', 'Ward', 'Negates the next incoming attack entirely.',
      glyph: '❀', color: Ae.lumen),
  'echo': StatusDef('echo', 'Echo', 'Your next frame resolves twice.',
      glyph: '↻', color: Ae.umbra),
  'stealth': StatusDef('stealth', 'Stealth', 'Foes cannot target you this turn.',
      glyph: '◑', color: Ae.umbra),
};

// ----------------------------------------------------------------- effects
enum FxKind {
  damage,
  damageAll,
  pierce, // ignores guard
  block,
  heal,
  loseHp,
  draw,
  energy,
  status, // to target
  selfStatus,
  statusAll,
  aura, // apply elemental aura to target
  auraAll,
  addCard, // arg = card id -> hand
  addCardDraw,
  exhaustHand,
  discardRandom,
  gainGold,
  maxHp,
  doubleBlock,
  cleanse, // remove debuffs from self
  scaleDamageByBlock,
  scaleDamageByDebuffs,
  scaleDamageByHandSize,
  drainLife, // damage + heal for the same amount
  detonate, // remove a status and deal stacks * value damage
  damageScaled, // value + (times * stacks of arg on target)
  doubleStatus, // double stacks of arg on target
  removeStatus,
  copyLast, // replay the previously played frame
  upgradeHand,
  randomCurse, // shuffle a curse into the draw pile
  damageEqualBlock,
  gainEnergyNextTurn,
  damagePerPlayed, // value * frames played this turn
  recallDiscard, // pull random cards back from discard
  discardHandDraw, // discard hand, draw that many + value
  cleanseOne,
}

enum FxTarget { enemy, allEnemies, randomEnemy, self }

class Fx {
  const Fx(this.kind, {this.value = 0, this.times = 1, this.arg, this.target = FxTarget.enemy});
  final FxKind kind;
  final int value;
  final int times;
  final String? arg;
  final FxTarget target;
}

// ------------------------------------------------------------------- cards
enum CardType { attack, skill, power, curse, status }

enum Rarity { starter, common, uncommon, rare, mythic, curse }

extension RarityX on Rarity {
  Color get color => const {
        Rarity.starter: Ae.dim,
        Rarity.common: Color(0xFFBFC6D6),
        Rarity.uncommon: Color(0xFF6FC3E8),
        Rarity.rare: Ae.gold,
        Rarity.mythic: Color(0xFFFF6FD8),
        Rarity.curse: Color(0xFF7A5FA8),
      }[this]!;
  String get label => name.toUpperCase();
}

class CardDef {
  const CardDef({
    required this.id,
    required this.name,
    required this.elem,
    required this.type,
    required this.cost,
    required this.rarity,
    required this.vessel,
    required this.text,
    required this.fx,
    this.art,
    this.textUp,
    this.fxUp,
    this.costUp,
    this.exhaust = false,
    this.innate = false,
    this.retain = false,
    this.unplayable = false,
    this.handTick,
  });

  final String id;
  final String name;
  final Elem elem;
  final CardType type;
  final int cost;
  final Rarity rarity;
  final String vessel;
  final String text;
  final List<Fx> fx;
  final String? art;
  final String? textUp;
  final List<Fx>? fxUp;
  final int? costUp;
  final bool exhaust;
  final bool innate;
  final bool retain;
  final bool unplayable;

  /// Applied at the end of your turn while this card sits in your hand.
  final List<Fx>? handTick;

  String artKey() => art ?? 'card_neutral_focus';
}

/// A card instance inside a run (tracks its own upgrade state).
class CardInst {
  CardInst(this.def, {this.upgraded = false, String? uid})
      : uid = uid ?? '${def.id}#${_n++}';
  static int _n = 0;

  final CardDef def;
  bool upgraded;
  final String uid;

  String get name => upgraded ? '${def.name}+' : def.name;
  int get cost => upgraded ? (def.costUp ?? def.cost) : def.cost;
  String get text => upgraded ? (def.textUp ?? def.text) : def.text;
  List<Fx> get fx => upgraded ? (def.fxUp ?? def.fx) : def.fx;
  bool get canUpgrade => !upgraded && def.rarity != Rarity.curse;

  CardInst copy() => CardInst(def, upgraded: upgraded);
  Map<String, dynamic> toJson() => {'id': def.id, 'up': upgraded};
}

// ------------------------------------------------------------------ relics
enum RelicTrigger {
  passive,
  onBattleStart,
  onTurnStart,
  onTurnEnd,
  onCardPlayed,
  onAttack,
  onDamaged,
  onKill,
  onReaction,
  onBattleWin,
  onRest,
  onFloor,
}

class RelicDef {
  const RelicDef({
    required this.id,
    required this.name,
    required this.desc,
    required this.rarity,
    required this.trigger,
    this.value = 0,
    this.arg,
    this.art,
    this.fx = const [],
  });
  final String id;
  final String name;
  final String desc;
  final Rarity rarity;
  final RelicTrigger trigger;
  final int value;
  final String? arg;
  final String? art;

  /// Effects fired when [trigger] happens. Anything more exotic is keyed by id
  /// inside the battle engine.
  final List<Fx> fx;

  String artKey() => art ?? 'relic_aeon_sigil';
}

// ----------------------------------------------------------------- enemies
enum IntentKind { attack, attackMulti, block, buff, debuff, special, sleep, aoe }

class Intent {
  const Intent(this.kind,
      {this.value = 0, this.times = 1, this.status, this.statusAmt = 0, this.elem = Elem.none, this.note});
  final IntentKind kind;
  final int value;
  final int times;
  final String? status;
  final int statusAmt;
  final Elem elem;
  final String? note;
}

class EnemyDef {
  const EnemyDef({
    required this.id,
    required this.name,
    required this.hp,
    required this.hpMax,
    required this.elem,
    required this.tier, // 0 normal, 1 elite, 2 boss
    required this.pattern,
    this.act = 1,
    this.art,
    this.passive,
    this.passiveDesc,
    this.passiveValue = 0,
    this.blurb = '',
  });
  final String id;
  final String name;
  final int hp;
  final int hpMax;
  final Elem elem;
  final int tier;
  final int act;
  final List<Intent> pattern;
  final String? art;
  final String? passive;
  final String? passiveDesc;
  final int passiveValue;
  final String blurb;

  String artKey() => art ?? 'enemy_$id';
}
