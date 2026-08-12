import 'dart:math' as math;

import '../data/cards.dart';
import '../data/potions.dart';
import '../data/relics.dart';
import '../data/vessels.dart';
import 'core.dart';
import 'rng.dart';
import 'run_state.dart';

/// One participant in a fight.
class Combatant {
  Combatant.hero(this.name, this.hp, this.maxHp)
      : isPlayer = true,
        def = null,
        mods = const [];

  Combatant.foe(this.def, this.hp, this.maxHp, this.mods)
      : isPlayer = false,
        name = def!.name;

  final bool isPlayer;
  final EnemyDef? def;
  final List<String> mods;
  String name;
  int hp;
  int maxHp;
  int block = 0;
  final Map<String, int> st = {};
  Elem aura = Elem.none;
  int auraTurns = 0;

  /// Turns until a foe's innate elemental aura reasserts itself after being
  /// consumed by a Reaction. This is what makes Reactions a repeatable rhythm
  /// rather than a one-off.
  int auraCooldown = 0;

  int patternIdx = 0;
  Intent? intent;
  int turnsTaken = 0;
  bool awake = true;
  bool phaseTwo = false;

  /// Reset at the top of every round. `regenerator` and `rewind` both need to
  /// know whether anybody actually touched this foe since it last acted.
  bool hurtThisRound = false;

  /// True on the turns a `phasing` foe is intangible.
  bool get phasedOut => def?.passive == 'phasing' && turnsTaken.isOdd;

  bool get alive => hp > 0;
  int s(String k) => st[k] ?? 0;
  void add(String k, int v) {
    if (v == 0) return;
    st[k] = (st[k] ?? 0) + v;
    if (st[k]! <= 0) st.remove(k);
  }

  void clear(String k) => st.remove(k);

  String get displayName {
    if (mods.isEmpty) return name;
    return '${mods.first.toUpperCase()} $name';
  }
}

/// A fully resolved description of one foe's telegraphed action.
class FoeIntentInfo {
  const FoeIntentInfo({
    required this.name,
    required this.kind,
    this.perHit = 0,
    this.times = 1,
    this.total = 0,
    this.guard = 0,
    this.rider,
    this.note,
    this.buff,
  });

  final String name;
  final IntentKind kind;

  /// Damage per hit, after every modifier on both sides.
  final int perHit;
  final int times;
  final int total;
  final int guard;

  /// e.g. "Rime 3" — a condition the attack also applies.
  final String? rider;
  final String? note;
  final String? buff;
}

/// One entry in the combat record. [kind] drives the icon and colour the UI
/// gives it; [turn] lets the full record group itself by round.
class LogLine {
  LogLine(this.text, {this.kind = 'info', this.turn = 0});
  final String text;

  /// card · foe · tick · reaction · cinematic · death · info
  final String kind;
  final int turn;
}

/// Floating combat text queued for the UI.
class Popup {
  Popup(this.targetIdx, this.text, this.kind);
  final int targetIdx; // -1 == hero
  final String text;
  final String kind; // damage | heal | block | status | reaction | cinematic
}

/// The non-damage half of each Reaction, stated plainly for the readout.
const _reactionRider = <String, String?>{
  'vaporize': 'doubled hit',
  'overload': 'all foes',
  'wither': 'Decay 3 · half its Guard',
  'purge': 'buffs burned off',
  'superconduct': 'Frozen 1 · Vulnerable 2',
  'deepfreeze': 'Rime 4 · plan scrambled',
  'prism': 'converted to Guard',
  'blackout': 'Silence 2',
  'judgment': 'all foes · Shock 2',
  'eclipse': 'ignores Guard · Doom 3',
};

const kEnemyMods = <String, String>{
  'ashen': 'Immune to Burn. +3 Strength.',
  'mirrored': 'Reflects 20% of damage taken.',
  'hollow': '+35% max HP.',
  'swift': 'Acts twice every third turn.',
  'waning': '-25% max HP, +50% damage dealt.',
  'warded': 'Starts the fight with heavy Guard.',
  'venomous': 'Every attack also applies 2 Poison.',
  'gilded': 'Drops double Aeon.',
};

class Battle {
  Battle({
    required this.run,
    required this.foeDefs,
    required this.rng,
    required this.kind,
  })  : hero = Combatant.hero(run.vessel.name, run.hp, run.maxHp),
        foes = [] {
    _buildFoes();
  }

  final RunState run;
  final List<EnemyDef> foeDefs;
  final Rng rng;
  final String kind; // normal | elite | boss

  final Combatant hero;
  final List<Combatant> foes;

  List<CardInst> drawPile = [];
  List<CardInst> hand = [];
  List<CardInst> discard = [];
  List<CardInst> exhausted = [];

  int energy = 3;
  int baseEnergy = 3;
  int turn = 0;
  int playedThisTurn = 0;
  int reactionsThisTurn = 0;
  int nextTurnEnergy = 0;
  final List<Elem> elemsThisTurn = [];
  CardInst? lastPlayed;
  bool cinematicUsedThisTurn = false;
  int cinematicsFired = 0;
  int reactionsFired = 0;

  /// When true, a triggered Cinematic waits for [resolveCinematic] instead of
  /// going off inside play(). The UI sets this so it can announce the moment
  /// before the damage lands; tests leave it off and resolve immediately.
  bool deferCinematics = false;
  Elem? pendingCinematic;

  int _resolveDepth = 0;

  /// Running total of damage you dealt inside the current card / reaction, so
  /// the readout can report a concrete number instead of prose.
  int _tally = 0;

  /// Damage per victim within the current action, so a log line can name who
  /// actually got hit rather than just totalling it.
  final Map<Combatant, int> _hits = {};

  /// Keeps readout lines short enough that they never truncate.
  static String _short(String s, [int max = 15]) =>
      s.length <= max ? s : '${s.substring(0, max - 1)}…';

  /// Index of the foe currently taking its turn, or -1. Drives the highlight.
  int actingFoe = -1;
  bool inFoePhase = false;
  int _foeCursor = 0;

  bool ended = false;
  bool victory = false;
  int goldReward = 0;
  bool phoenixUsed = false;

  final List<LogLine> log = [];
  final List<Popup> popups = [];

  VesselDef get vessel => run.vessel;
  bool has(String relicId) => run.relics.contains(relicId);

  // ------------------------------------------------------------ setup
  void _buildFoes() {
    final modPool = kEnemyMods.keys.toList();
    for (final d in foeDefs) {
      final mods = <String>[];
      final chance = switch (run.act) { 1 => .18, 2 => .34, _ => .50 };
      if (d.tier == 0 && rng.chance(chance)) mods.add(rng.pick(modPool));
      if (d.tier == 1 && rng.chance(chance + .15)) mods.add(rng.pick(modPool));

      var maxHp = rng.range(d.hp, d.hpMax);
      maxHp = (maxHp * (1 + .06 * run.ascension)).round();
      if (mods.contains('hollow')) maxHp = (maxHp * 1.35).round();
      if (mods.contains('waning')) maxHp = (maxHp * .75).round();

      final f = Combatant.foe(d, maxHp, maxHp, mods);
      // A foe wears its own element. Strike it with a different one to react.
      f.aura = d.elem;
      f.auraTurns = 99;
      if (mods.contains('ashen')) f.add('strength', 3);
      if (mods.contains('warded')) f.block = 12 + run.act * 8;
      if (d.passive == 'colossus') f.awake = false;
      foes.add(f);
    }
  }

  void start() {
    drawPile = rng.shuffled(run.deck.map((c) => c.copy()).toList());
    baseEnergy = vessel.energy;
    _say('${vessel.title} enters the frame.');

    for (final id in run.relics) {
      final r = relicDef(id);
      if (r.trigger == RelicTrigger.onBattleStart) {
        _applyFxList(r.fx, null, source: r.name);
      }
      if (id == 'aeon_sigil') hero.maxHp = math.max(10, hero.maxHp - 6);
      if (id == 'bell_fragment' && foes.isNotEmpty) {
        _damage(hero, foes.first, 12, isAttack: false);
      }
    }
    _beginTurn(first: true);
  }

  // ------------------------------------------------------- turn flow
  void _beginTurn({bool first = false}) {
    turn++;
    playedThisTurn = 0;
    reactionsThisTurn = 0;
    elemsThisTurn.clear();
    cinematicUsedThisTurn = false;

    energy = baseEnergy + nextTurnEnergy;
    nextTurnEnergy = 0;
    if (first && has('gear_ring')) energy += 1;
    if (hero.s('stormheart') > 0) {
      energy += 1;
      _hurt(hero, hero.s('stormheart') >= 2 ? 1 : 3, 'Stormheart');
    }

    if (hero.s('fortify') <= 0) hero.block = 0;
    if (hero.s('guardturn') > 0) _gainBlock(hero, hero.s('guardturn'));
    if (hero.s('ascension') > 0) {
      _heal(hero, hero.s('ascension'));
      hero.add('radiance', 1);
    }

    for (final id in run.relics) {
      final r = relicDef(id);
      if (r.trigger == RelicTrigger.onTurnStart) {
        _applyFxList(r.fx, null, source: r.name);
      }
    }

    var n = 5 - hero.s('curse') - hand.where((c) => c.def.id == 'cu_doubt').length;
    if (has('clock_hand') && hand.isEmpty) n += 2;
    _draw(math.max(1, n));

    if (hero.s('revision') > 0) {
      for (var i = 0; i < hero.s('revision'); i++) {
        final ups = hand.where((c) => c.canUpgrade).toList();
        if (ups.isNotEmpty) rng.pick(ups).upgraded = true;
      }
    }
    _foesReachIntoYourTurn();

    for (final f in foes) {
      if (!f.alive || f.aura != Elem.none || f.def!.elem == Elem.none) continue;
      if (f.auraCooldown > 0) {
        f.auraCooldown--;
      } else {
        f.aura = f.def!.elem;
        f.auraTurns = 99;
      }
    }
    _planIntents();
  }

  /// Passives that reach across the table and touch your hand, deck or Aether
  /// at the top of your turn. These used to be printed on the foe and never
  /// happen; a boss that says it erases your frames now erases them.
  void _foesReachIntoYourTurn() {
    for (final f in foes) {
      if (!f.alive || !f.awake) continue;
      switch (f.def!.passive) {
        case 'siphon':
          if (energy > 1) {
            energy--;
            _say('${_short(f.displayName)} siphons 1 Aether', kind: 'foe');
          }

        case 'editor':
          final ups = hand.where((c) => c.upgraded).toList();
          if (ups.isNotEmpty) {
            final c = rng.pick(ups);
            c.upgraded = false;
            _say('${_short(f.displayName)} un-edits ${_short(c.name)}', kind: 'foe');
          }

        case 'author':
          // The only passive in the game that costs you a card for good.
          final pool = [...hand, ...drawPile, ...discard]
              .where((c) => c.def.type != CardType.curse && c.def.type != CardType.status)
              .toList();
          if (pool.isNotEmpty) {
            final c = rng.pick(pool);
            hand.remove(c);
            drawPile.remove(c);
            discard.remove(c);
            run.deck.removeWhere((x) => x.uid == c.uid);
            exhausted.add(c);
            _say('${_short(f.displayName)} erases ${_short(c.name)} — for good',
                kind: 'foe');
          }

        case 'devour':
          if (discard.isNotEmpty) {
            final c = rng.pick(discard);
            discard.remove(c);
            exhausted.add(c);
            _say('${_short(f.displayName)} devours ${_short(c.name)}', kind: 'foe');
          }

        case 'firstvessel':
          if (run.relics.isNotEmpty && turn % 2 == 0) {
            final r = relicDef(rng.pick(run.relics));
            _damage(f, hero, 8, isAttack: false);
            _say('${_short(f.displayName)} turns ${_short(r.name)} against you',
                kind: 'foe');
          }
      }
    }
  }

  void _planIntents() {
    for (final f in foes) {
      if (!f.alive) continue;
      if (!f.awake) {
        f.intent = sleepIntent;
        continue;
      }
      final p = f.def!.pattern;
      var next = p[f.patternIdx % p.length];
      if (next.kind == IntentKind.special && f.s('silence') > 0) {
        next = p[(f.patternIdx + 1) % p.length];
      }
      f.intent = next;
    }
  }

  static const sleepIntent = Intent(IntentKind.sleep, note: 'Dormant');

  /// The player ends their turn; foes act; a new turn begins.
  /// Runs a whole round at once. Used by tests and simulations; the UI drives
  /// [endPlayerTurn] / [stepFoes] / [beginNextTurn] instead so the player can
  /// actually see each foe take its turn.
  void endTurn() {
    endPlayerTurn();
    while (stepFoes()) {}
    beginNextTurn();
  }

  /// Phase 1 — your own end of turn: statuses tick, the hand is discarded.
  void endPlayerTurn() {
    if (ended || inFoePhase) return;

    // cards that punish you for holding them
    for (final c in List<CardInst>.from(hand)) {
      final tick = c.def.handTick;
      if (tick != null && !has('null_marble')) {
        if (c.def.id == 'cu_blank' && hand.length == 1) continue;
        _applyFxList(tick, null, source: c.def.name);
      }
    }

    if (hero.s('immolate') > 0) {
      for (final f in foes.where((f) => f.alive)) {
        _applyStatus(f, 'burn', hero.s('immolate'));
      }
      _hurt(hero, 2, 'Immolation');
    }
    if (hero.s('encore') > 0 && playedThisTurn >= hero.s('encore')) _draw(2);

    _tickEnd(hero);
    if (_checkEnd()) return;

    // discard hand except retained
    for (final c in List<CardInst>.from(hand)) {
      if (c.def.retain) continue;
      hand.remove(c);
      if (c.def.type == CardType.status) {
        exhausted.add(c);
      } else {
        discard.add(c);
      }
    }

    _foeCursor = 0;
    inFoePhase = true;
  }

  /// Phase 2 — one foe acts per call so the UI can animate the beat.
  /// Returns false once every foe has moved.
  bool stepFoes() {
    if (ended) {
      inFoePhase = false;
      actingFoe = -1;
      return false;
    }
    while (_foeCursor < foes.length) {
      final i = _foeCursor++;
      final f = foes[i];
      if (!f.alive) continue;
      actingFoe = i;

      if (f.s('frozen') > 0) {
        f.add('frozen', -1);
        _pop(f, 'FROZEN', 'status');
        _say('${f.displayName} is frozen solid and loses its turn.');
        return true;
      }
      if (!f.awake) {
        _say('${f.displayName} does not stir.');
        return true;
      }

      // `chorus` reads the board before it swings, so killing its friends is
      // the counterplay rather than a consolation.
      if (f.def!.passive == 'chorus') {
        final friends = foes.where((x) => x.alive && x != f).length;
        if (friends > 0) f.add('strength', friends);
      }

      _act(f);
      if (f.mods.contains('swift') && f.turnsTaken % 3 == 2 && f.alive && !ended) {
        f.patternIdx++;
        _planIntents();
        _say('${f.displayName} is SWIFT — it moves twice.');
        _act(f);
      }
      _extraActions(f);

      f.turnsTaken++;
      f.patternIdx++;
      _tickEnd(f);
      _foeEndOfTurn(f);
      f.hurtThisRound = false;
      _checkEnd();
      return true;
    }
    actingFoe = -1;
    inFoePhase = false;
    return false;
  }

  /// Passives that buy a foe a second swing. Kept separate from [_act] so a
  /// foe can never chain them into an unbounded loop.
  void _extraActions(Combatant f) {
    if (!f.alive || ended) return;
    void again(String why) {
      f.patternIdx++;
      _planIntents();
      _say('${_short(f.displayName)} — $why', kind: 'foe');
      _act(f);
    }

    switch (f.def!.passive) {
      case 'wind':
        if (f.turnsTaken == 0) again('moves on the wind, and moves again');
      case 'hourglass':
        if (f.turnsTaken % 3 == 2) again('the hour turns over');
      case 'rewind':
        if (!f.hurtThisRound) again('nothing touched it, so it does it again');
      case 'storm':
        final every = f.def!.tier >= 2 ? 3 : 4;
        if (f.turnsTaken % every == every - 1) {
          final v = 6 + f.def!.tier * 5;
          _say('${_short(f.displayName)} breaks over the whole board', kind: 'foe');
          _damage(f, hero, v, isAttack: true, elem: Elem.volt);
          for (final o in foes.where((x) => x.alive && x != f)) {
            _applyStatus(o, 'shock', 1);
          }
        }
      case 'toll':
        _applyStatus(hero, 'vulnerable', 1);
    }
  }

  /// Everything a foe does once its own swing is over.
  void _foeEndOfTurn(Combatant f) {
    if (!f.alive) return;
    switch (f.def!.passive) {
      case 'sprout':
        _heal(f, 4);
      case 'matron':
        _heal(f, f.def!.tier >= 2 ? 18 : (f.def!.tier == 1 ? 15 : 12));
      case 'regenerator':
        if (!f.hurtThisRound) {
          _heal(f, 8 + f.def!.tier * 4);
          _pop(f, 'MENDS', 'status');
        }
      case 'hunger':
        f.maxHp += 4;
        _heal(f, 4);
      case 'warden':
        for (final o in foes.where((x) => x.alive && x != f)) {
          o.block += 6;
          _pop(o, '+6', 'block');
        }
      case 'marshal':
        final amt = f.def!.tier >= 1 ? 2 : 1;
        for (final o in foes.where((x) => x.alive && x != f)) {
          o.add('strength', amt);
        }
    }
  }

  /// Phase 3 — hand back to you.
  void beginNextTurn() {
    if (ended) return;
    _beginTurn();
  }

  void _act(Combatant f) {
    final it = f.intent ?? f.def!.pattern.first;
    final who = f.displayName;
    switch (it.kind) {
      case IntentKind.attack:
      case IntentKind.attackMulti:
      case IntentKind.aoe:
        final before = hero.hp + hero.block;
        final hits = it.kind == IntentKind.aoe ? 1 : it.times;
        for (var i = 0; i < hits; i++) {
          if (!f.alive || ended) break;
          var dmgAmt = it.value;
          if (f.mods.contains('waning')) dmgAmt = (dmgAmt * 1.5).round();
          _damage(f, hero, dmgAmt, isAttack: true, elem: it.elem);
          if (f.s('bleed') > 0) _hurt(f, f.s('bleed'), 'Bleed');
          if (f.mods.contains('venomous')) _applyStatus(hero, 'poison', 2);
        }
        if (it.status != null) _applyStatus(hero, it.status!, it.statusAmt);
        final took = before - (hero.hp + hero.block);
        _say([
          '${_short(who)} → you $took',
          if (it.status != null)
            '${kStatus[it.status!]?.name ?? it.status!} ${it.statusAmt}',
        ].join(' · '), kind: 'foe');
      case IntentKind.block:
        f.block += it.value;
        _pop(f, '+${it.value}', 'block');
        _say('${_short(who)} guards ${it.value}', kind: 'foe');
        if (f.def!.passive == 'zeal') f.add('strength', f.def!.tier >= 2 ? 2 : 1);
        if (f.def!.passive == 'frostheart') _applyStatus(hero, 'rime', 1);
      case IntentKind.buff:
        f.add(it.status ?? 'strength', it.statusAmt);
        _pop(f, '${it.status ?? 'strength'} +${it.statusAmt}', 'status');
        _say('${_short(who)} +${it.statusAmt} '
            '${kStatus[it.status ?? 'strength']?.name ?? 'Strength'}', kind: 'foe');
      case IntentKind.debuff:
        _applyStatus(hero, it.status ?? 'weak', it.statusAmt);
        _say('${_short(who)} → you ${kStatus[it.status ?? 'weak']?.name ?? 'Weak'} '
            '${it.statusAmt}', kind: 'foe');
      case IntentKind.special:
        _special(f, it);
      case IntentKind.sleep:
        _say('${_short(who)} does not stir', kind: 'foe');
    }
  }

  void _special(Combatant f, Intent it) {
    final id = f.def!.id;
    final before = hero.hp + hero.block;
    if (it.value > 0) {
      _damage(f, hero, it.value, isAttack: true, elem: f.def!.elem,
          pierce: id == 'aeonfall');
    }
    if (it.status != null) _applyStatus(hero, it.status!, it.statusAmt);
    final took = before - (hero.hp + hero.block);

    switch (id) {
      case 'the_clocksmith':
      case 'clocksmith_prime':
        _heal(f, id == 'clocksmith_prime' ? 45 : 25);
        f.add('strength', 5);
      case 'blank_effigy':
      case 'draft_titan':
        _heal(f, id == 'draft_titan' ? 30 : 20);
        f.add('strength', 4);
      case 'panel_wraith':
        _junk('st_ash', 2);
      case 'redline_editor':
        _junk('cu_blank', 2);
      case 'the_author':
        _junk('cu_blank', 3);
      case 'ink_devourer':
      case 'editor_of_names':
        if (hand.isNotEmpty) {
          final c = rng.pick(hand);
          hand.remove(c);
          exhausted.add(c);
          _say('${f.displayName} strikes out ${c.name}.');
        }
      case 'mirror_twin':
      case 'mirrorlord_vane':
      case 'mirrorlord_ascendant':
      case 'first_vessel':
      case 'paradox_echo':
        final v = 12 + run.act * 8;
        _damage(f, hero, v, isAttack: true);
      case 'reflection_eater':
        final buffs = hero.st.keys.where((k) => kStatus[k]?.debuff == false).toList();
        if (buffs.isNotEmpty) {
          hero.clear(rng.pick(buffs));
          _heal(f, 10);
        }
      case 'aeonfall':
        hero.block = 0;
        for (final k in hero.st.keys.toList()) {
          if (kStatus[k]?.debuff == false) hero.clear(k);
        }
        _say('AEONFALL unmakes your defences.');
      case 'endling':
        _say('${f.displayName} asks you, quietly, to stop.');
      default:
        break;
    }
    _say([
      '${_short(f.displayName)} ✦',
      if (it.note != null) _short(it.note!, 26),
      if (took > 0) '→ you $took',
      if (it.status != null)
        '${kStatus[it.status!]?.name ?? it.status!} ${it.statusAmt}',
    ].join(' '), kind: 'foe');
  }

  void _junk(String cardId, int n) {
    for (var i = 0; i < n; i++) {
      drawPile.insert(rng.nextInt(drawPile.length + 1), CardInst(cardDef(cardId)));
    }
    _say('${cardDef(cardId).name} x$n forced into your deck.');
  }

  // ---------------------------------------------------------- playing
  bool canPlay(CardInst c) {
    if (ended || c.def.unplayable) return false;
    if (c.def.type == CardType.attack && hero.s('entangle') > 0) return false;
    return energy >= _costOf(c);
  }

  int _costOf(CardInst c) {
    var cost = c.cost;
    if (playedThisTurn == 0 && hand.any((x) => x.def.id == 'cu_silence')) cost += 1;
    return math.max(0, cost);
  }

  void play(CardInst c, int targetIdx) {
    if (!canPlay(c)) return;
    energy -= _costOf(c);
    hand.remove(c);
    playedThisTurn++;
    if (c.def.elem != Elem.none) elemsThisTurn.add(c.def.elem);
    if (c.def.type == CardType.skill) {
      for (final f in foes.where((x) => x.alive && x.def!.passive == 'glutton')) {
        _heal(f, 6 + f.def!.tier * 2);
      }
    }
    // A prophet never hides its plan — it changes it. You always see the new
    // intent, you just cannot count on the old one.
    var reread = false;
    for (final f in foes.where((x) => x.alive && x.def!.passive == 'prophet')) {
      f.patternIdx++;
      reread = true;
    }
    if (reread) _planIntents();

    var repeats = 1;
    if (hero.s('echo') > 0) {
      repeats++;
      hero.add('echo', -1);
    }
    if (hero.s('echoloop') > 0 && playedThisTurn <= hero.s('echoloop')) repeats++;

    final hpBefore = hero.hp;
    final blockBefore = hero.block;
    _tally = 0;
    _hits.clear();
    for (var i = 0; i < repeats; i++) {
      _resolve(c, targetIdx);
      if (ended) break;
    }

    // One short factual line: what you played, who it hit, for how much.
    final healed = hero.hp - hpBefore;
    final guarded = hero.block - blockBefore;
    String? target;
    if (_hits.length == 1) {
      final e = _hits.entries.first;
      target = '→ ${_short(e.key.displayName)} ${e.value}';
    } else if (_hits.length > 1) {
      target = '→ ${_hits.length} foes $_tally';
    }
    _say([
      _short(c.name, 18),
      if (repeats > 1) '×$repeats',
      if (target != null) target,
      if (healed > 0) '+$healed HP',
      if (guarded > 0) '+$guarded Guard',
    ].join(' '), kind: 'card');

    lastPlayed = c;
    if (c.def.exhaust) {
      exhausted.add(c);
      _onExhaust();
    } else if (c.def.type == CardType.power) {
      exhausted.add(c);
    } else {
      discard.add(c);
    }

    // combo triggers
    if (hero.s('coil') > 0 && playedThisTurn % 3 == 0) {
      for (final f in foes.where((f) => f.alive)) {
        _damage(hero, f, hero.s('coil'), isAttack: false);
      }
    }
    if (has('cinder_dice') && playedThisTurn == 3) {
      for (final f in foes.where((f) => f.alive)) {
        _damage(hero, f, 8, isAttack: false);
      }
    }
    if (has('gilded_finger') && playedThisTurn == 4) nextTurnEnergy += 1;

    _checkCinematic();
    _checkEnd();
  }

  /// Drink a draught from the belt. Free — it costs no Aether and does not
  /// count as a played frame, so it can never be the reason a Cinematic
  /// fails to fire.
  bool usePotion(String potionId) {
    if (ended || inFoePhase) return false;
    if (!run.potions.remove(potionId)) return false;
    final p = potionDef(potionId);
    _say('${_short(p.name, 18)} — drunk', kind: 'card');
    _tally = 0;
    _hits.clear();
    _applyFxList(p.fx, null, source: p.name);
    if (_hits.isNotEmpty) {
      _say(
          _hits.length == 1
              ? '→ ${_short(_hits.keys.first.displayName)} $_tally'
              : '→ ${_hits.length} foes $_tally',
          kind: 'card');
    }
    _checkEnd();
    return true;
  }

  void _onExhaust() {
    if (has('moth_lantern')) {
      final alive = foes.where((f) => f.alive).toList();
      if (alive.isNotEmpty) _damage(hero, rng.pick(alive), 4, isAttack: false);
    }
  }

  void _resolve(CardInst c, int targetIdx) {
    if (_resolveDepth > 4) return; // copy effects must not recurse forever
    _resolveDepth++;
    try {
      _applyFxList(c.fx, targetIdx, card: c);
      // every elemental attack paints its aura on what it hit
      if (c.def.elem != Elem.none && c.def.type == CardType.attack) {
        final t = _target(targetIdx);
        if (t != null && t.alive) _paint(t, c.def.elem);
      }
    } finally {
      _resolveDepth--;
    }
  }

  void _checkCinematic() {
    if (cinematicUsedThisTurn || pendingCinematic != null) return;
    for (final e in Elem.values) {
      if (e == Elem.none) continue;
      if (elemsThisTurn.where((x) => x == e).length >= 3) {
        cinematicUsedThisTurn = true;
        cinematicsFired++;
        elemsThisTurn.clear(); // meter empties the instant it triggers
        if (deferCinematics) {
          pendingCinematic = e;
        } else {
          _fireCinematic();
        }
        return;
      }
    }
  }

  /// Fires the Cinematic the UI has been holding back.
  void resolveCinematic() {
    if (pendingCinematic == null) return;
    pendingCinematic = null;
    _fireCinematic();
    _checkEnd();
  }

  void _fireCinematic() {
    popups.add(Popup(-1, vessel.cinematicName, 'cinematic'));
    // The meter has been spent — empty it now rather than at end of turn, so
    // the UI never shows a full bar you can no longer use.
    elemsThisTurn.clear();
    final hpBefore = hero.hp;
    final blockBefore = hero.block;
    _tally = 0;
    final live = foes.where((f) => f.alive).toList();
    switch (vessel.id) {
      case 'ashcaller':
        for (final f in live) {
          _damage(hero, f, 12, isAttack: false, elem: Elem.ember);
          _applyStatus(f, 'burn', 6);
        }
      case 'saintcoralis':
        _gainBlock(hero, 24);
        for (final f in live) {
          _damage(hero, f, hero.block, isAttack: false, elem: Elem.frost);
        }
      case 'voltborn':
        for (var i = 0; i < 9; i++) {
          final a = foes.where((f) => f.alive).toList();
          if (a.isEmpty) break;
          final t = rng.pick(a);
          _damage(hero, t, 4, isAttack: false, elem: Elem.volt);
          _applyStatus(t, 'shock', 2);
        }
      case 'umbralnyx':
        for (final f in live) {
          _damage(hero, f, 20, isAttack: false, pierce: true, elem: Elem.umbra);
          _applyStatus(f, 'doom', 4);
        }
      case 'lumenherald':
        _heal(hero, 14);
        hero.add('ward', 2);
        for (final f in live) {
          _damage(hero, f, 18, isAttack: false, elem: Elem.lumen);
        }
      default:
        for (final c in List<CardInst>.from(hand)) {
          hand.remove(c);
          discard.add(c);
        }
        _draw(5);
        energy += 3;
        if (lastPlayed != null) _resolve(lastPlayed!, 0);
    }

    // Report it like any other action: what it did, in numbers.
    final healed = hero.hp - hpBefore;
    final guarded = hero.block - blockBefore;
    _say(
      [
        vessel.cinematicName,
        if (_tally > 0) '$_tally dmg',
        if (healed > 0) '+$healed HP',
        if (guarded > 0) '+$guarded Guard',
      ].join(' · '),
      kind: 'cinematic',
    );
  }

  // ------------------------------------------------------------ effects
  Combatant? _target(int idx) {
    final live = foes.where((f) => f.alive).toList();
    if (live.isEmpty) return null;
    if (idx < 0 || idx >= foes.length || !foes[idx].alive) return live.first;
    return foes[idx];
  }

  List<Combatant> _resolveTargets(FxTarget t, int idx) {
    final live = foes.where((f) => f.alive).toList();
    return switch (t) {
      FxTarget.self => [hero],
      FxTarget.allEnemies => live,
      FxTarget.randomEnemy => live.isEmpty ? [] : [rng.pick(live)],
      FxTarget.enemy => [if (_target(idx) != null) _target(idx)!],
    };
  }

  void _applyFxList(List<Fx> list, int? idx, {CardInst? card, String? source}) {
    for (final fx in list) {
      if (ended) return;
      _applyFx(fx, idx ?? 0, card: card, source: source);
    }
  }

  void _applyFx(Fx fx, int idx, {CardInst? card, String? source}) {
    final targets = _resolveTargets(fx.target, idx);
    final elem = card?.def.elem ?? Elem.none;

    switch (fx.kind) {
      case FxKind.damage:
      case FxKind.damageAll:
        for (var i = 0; i < fx.times; i++) {
          final ts = fx.target == FxTarget.randomEnemy
              ? _resolveTargets(fx.target, idx)
              : targets;
          for (final t in ts) {
            if (t.alive) {
              _damage(hero, t, fx.value, isAttack: true, elem: elem, multi: fx.times > 1);
            }
          }
        }
      case FxKind.pierce:
        for (final t in targets) {
          _damage(hero, t, fx.value, isAttack: true, pierce: true, elem: elem);
        }
      case FxKind.block:
        _gainBlock(hero, fx.value);
      case FxKind.heal:
        _heal(hero, fx.value);
      case FxKind.loseHp:
        _hurt(hero, fx.value, source ?? card?.name ?? 'cost');
        if (has('blood_vial')) _gainBlock(hero, 4);
      case FxKind.draw:
        _draw(fx.value);
      case FxKind.energy:
        energy += fx.value;
      case FxKind.gainEnergyNextTurn:
        nextTurnEnergy += fx.value;
      case FxKind.status:
      case FxKind.statusAll:
        for (final t in targets) {
          _applyStatus(t, fx.arg!, fx.value);
        }
      case FxKind.selfStatus:
        _applyStatus(hero, fx.arg!, fx.value);
      case FxKind.aura:
      case FxKind.auraAll:
        final e = Elem.values.firstWhere((x) => x.name == fx.arg, orElse: () => Elem.none);
        for (final t in targets) {
          _paint(t, e);
        }
      case FxKind.detonate:
        for (final t in targets) {
          final stacks = t.s(fx.arg!);
          if (stacks > 0) {
            t.clear(fx.arg!);
            _damage(hero, t, stacks * fx.value, isAttack: false, elem: elem);
          }
        }
      case FxKind.damageScaled:
        for (final t in targets) {
          _damage(hero, t, fx.value + t.s(fx.arg!) * fx.times, isAttack: true, elem: elem);
        }
      case FxKind.doubleStatus:
        for (final t in targets) {
          final v = t.s(fx.arg!);
          if (v > 0) _applyStatus(t, fx.arg!, v);
        }
      case FxKind.removeStatus:
        for (final t in targets) {
          t.clear(fx.arg!);
        }
      case FxKind.drainLife:
        var total = 0;
        for (final t in targets) {
          total += _damage(hero, t, fx.value, isAttack: true, elem: elem);
        }
        if (total > 0) _heal(hero, total);
      case FxKind.scaleDamageByBlock:
        for (final t in targets) {
          _damage(hero, t, fx.value + (hero.block * fx.times ~/ 100),
              isAttack: true, elem: elem);
        }
      case FxKind.damageEqualBlock:
        for (final t in targets) {
          _damage(hero, t, hero.block * fx.value ~/ 100, isAttack: true, elem: elem);
        }
      case FxKind.scaleDamageByDebuffs:
        for (final t in targets) {
          final n = t.st.keys.where((k) => kStatus[k]?.debuff == true).length;
          _damage(hero, t, fx.value * math.max(1, n), isAttack: true, elem: elem);
        }
      case FxKind.scaleDamageByHandSize:
        for (final t in targets) {
          _damage(hero, t, fx.value + hand.length * fx.times, isAttack: true, elem: elem);
        }
      case FxKind.damagePerPlayed:
        final mult = math.max(1, playedThisTurn - 1);
        for (final t in targets) {
          _damage(hero, t, fx.value * mult, isAttack: true, elem: elem);
        }
      case FxKind.cleanse:
        for (final k in hero.st.keys.toList()) {
          if (kStatus[k]?.debuff == true) hero.clear(k);
        }
      case FxKind.cleanseOne:
        final debuffs = hero.st.keys.where((k) => kStatus[k]?.debuff == true).toList();
        for (var i = 0; i < math.max(1, fx.value) && i < debuffs.length; i++) {
          hero.clear(debuffs[i]);
        }
      case FxKind.exhaustHand:
        final n = hand.length;
        exhausted.addAll(hand);
        hand.clear();
        _onExhaust();
        _draw(n + fx.value);
      case FxKind.discardHandDraw:
        final n = hand.length;
        discard.addAll(hand);
        hand.clear();
        _draw(n + fx.value);
      case FxKind.recallDiscard:
        for (var i = 0; i < fx.value && discard.isNotEmpty; i++) {
          final c = rng.pick(discard);
          discard.remove(c);
          hand.add(c);
        }
      case FxKind.copyLast:
        // Copying a copy would loop; Recall replays the last *other* frame.
        final target = lastPlayed;
        if (target != null &&
            target != card &&
            !target.fx.any((x) => x.kind == FxKind.copyLast)) {
          _resolve(target, idx);
        }
      case FxKind.upgradeHand:
        for (final c in hand) {
          if (c.canUpgrade) c.upgraded = true;
        }
      case FxKind.randomCurse:
        for (var i = 0; i < fx.value; i++) {
          _junk(rng.pick(kCursePool).id, 1);
        }
      case FxKind.addCard:
      case FxKind.addCardDraw:
        for (var i = 0; i < fx.value; i++) {
          hand.add(CardInst(cardDef(fx.arg!)));
        }
      case FxKind.gainGold:
        run.gold += fx.value;
        _say('+${fx.value} Aeon.');
      case FxKind.maxHp:
        hero.maxHp += fx.value;
        _heal(hero, fx.value);
      case FxKind.discardRandom:
        for (var i = 0; i < fx.value && hand.isNotEmpty; i++) {
          final c = rng.pick(hand);
          hand.remove(c);
          discard.add(c);
        }
      case FxKind.doubleBlock:
        _gainBlock(hero, hero.block);
    }
  }

  // ------------------------------------------------------------ combat math
  int _damage(Combatant src, Combatant dst, int raw,
      {bool isAttack = true, bool pierce = false, Elem elem = Elem.none, bool multi = false}) {
    if (raw <= 0 || !dst.alive) return 0;

    // Two foes refuse damage outright rather than reducing it. Both are meant
    // to redirect the player's turn, so they say so instead of silently eating
    // the hit.
    if (!dst.isPlayer && dst.phasedOut) {
      _pop(dst, 'PHASED', 'status');
      return 0;
    }
    if (!dst.isPlayer &&
        dst.def!.passive == 'shroud' &&
        foes.any((f) => f.alive && f != dst)) {
      _pop(dst, 'SHROUDED', 'status');
      return 0;
    }

    var v = raw.toDouble();

    if (isAttack) v += src.s('strength');
    if (src.s('momentum') > 0) {
      v += src.s('momentum') * 2;
      src.clear('momentum');
    }
    if (isAttack && src.s('weak') > 0) v *= .75;
    if (src.s('overcharge') > 0) v *= 1.5;
    if (src.isPlayer) {
      if (has('wolf_sigil') && hero.hp * 2 < hero.maxHp) v *= 1.15;
      if (elem == Elem.lumen && has('sun_nail')) v *= 1.25;
      if (has('nail_of_ending') && dst.s('doom') > 0) v *= 1.25;
      if (hero.s('radiance') > 0 && elem == Elem.lumen) v *= 1.5;
    }

    if (isAttack && dst.s('vulnerable') > 0) v *= 1.4;
    if (dst.s('rime') > 0) v *= 1.3;
    if (dst.s('overcharge') > 0) v *= 1.25;
    if (!dst.isPlayer && dst.def!.passive == 'pity' && dst.hp * 2 > dst.maxHp) v *= .5;
    if (!dst.isPlayer && dst.mods.contains('hollow')) v *= .9;
    if (!dst.isPlayer && dst.def!.passive == 'swarm' && raw >= 15) v *= .7;
    if (!dst.isPlayer && dst.def!.passive == 'bulwark' && multi) v *= .6;

    var amount = v.round();
    if (amount < 1) amount = 1;

    if (dst.isPlayer && dst.s('ward') > 0 && isAttack) {
      dst.add('ward', -1);
      _pop(dst, 'WARDED', 'status');
      return 0;
    }
    if (dst.isPlayer && dst.s('stealth') > 0 && isAttack && !src.isPlayer) {
      _pop(dst, 'MISSED', 'status');
      return 0;
    }

    if (!pierce) {
      final absorbed = math.min(dst.block, amount);
      dst.block -= absorbed;
      amount -= absorbed;
      if (absorbed > 0 && amount == 0) {
        _pop(dst, 'BLOCKED', 'block');
        return 0;
      }
    }

    dst.hp -= amount;
    if (src.isPlayer && !dst.isPlayer) {
      _tally += amount;
      _hits[dst] = (_hits[dst] ?? 0) + amount;
    }
    _pop(dst, '-$amount', 'damage');

    if (!dst.isPlayer && dst.def!.passive == 'colossus' && !dst.awake) {
      if (dst.maxHp - dst.hp >= 40) {
        dst.awake = true;
        _say('${dst.displayName} wakes.');
      }
    }
    if (!dst.isPlayer && dst.def!.passive == 'furnace' && elem == Elem.ember) {
      dst.add('strength', 1);
    }
    if (dst.s('shock') > 0) {
      final others = foes.where((f) => f.alive && f != dst).toList();
      if (others.isNotEmpty) {
        final t = rng.pick(others);
        t.hp -= 3;
        _pop(t, '-3', 'damage');
      }
      dst.add('shock', -1);
    }
    if (dst.s('thorns') > 0 && isAttack && src != dst) {
      src.hp -= dst.s('thorns');
      _pop(src, '-${dst.s('thorns')}', 'damage');
    }
    if (!dst.isPlayer && (dst.mods.contains('mirrored') || dst.def!.passive == 'mirror')) {
      final back = (amount * (dst.def!.passive == 'mirror' ? .3 : .2)).round();
      if (back > 0 && src.isPlayer) {
        hero.hp -= back;
        _pop(hero, '-$back', 'damage');
      }
    }
    if (!dst.isPlayer) {
      dst.hurtThisRound = true;
      if (dst.def!.passive == 'enrage') dst.add('strength', 2);
    }
    if (!dst.isPlayer && dst.def!.passive == 'leech') _heal(dst, amount ~/ 2);
    if (!dst.isPlayer && dst.def!.passive == 'kintsugi' && dst.hp * 2 < dst.maxHp && !dst.phaseTwo) {
      dst.phaseTwo = true;
      _heal(dst, 18);
    }

    if (dst.hp <= 0) _onDeath(dst);
    if (dst.isPlayer && dst.hp <= 0) {
      _tryCheatDeath();
      // A cheated death restores a positive pool; anything else floors at zero
      // so the run state never records a negative HP.
      if (dst.hp < 0) dst.hp = 0;
    }
    return amount;
  }

  void _tryCheatDeath() {
    if (has('phoenix_ash') && !phoenixUsed) {
      phoenixUsed = true;
      hero.hp = (hero.maxHp * .3).round();
      _say('Phoenix Ash flares. You are not finished.', kind: 'cinematic');
    } else if (has('mirror_coin') && !run.mirrorCoinUsed) {
      run.mirrorCoinUsed = true;
      hero.hp = 1;
      _say('The Mirror Coin lands on its edge. You live at 1 HP.', kind: 'cinematic');
    }
  }

  void _onDeath(Combatant f) {
    if (f.isPlayer) return;
    f.hp = 0;
    _say('${_short(f.displayName)} is erased', kind: 'death');

    // Two foes cost you something for killing them, so "focus it down" is not
    // automatically the right answer.
    if (f.def!.passive == 'spite') {
      final v = 10 + f.def!.tier * 6;
      _say('${_short(f.displayName)} comes apart across you', kind: 'foe');
      _hurt(hero, v, f.displayName);
    }
    if (f.def!.passive == 'tether') {
      for (final o in foes.where((x) => x.alive)) {
        o.add('strength', 3);
      }
      _say('The others take up what it was carrying', kind: 'foe');
    }

    if (has('shadow_dice')) _heal(hero, 5);
    if (hero.s('gravetithe') > 0) {
      _heal(hero, hero.s('gravetithe'));
      _draw(1);
    }
  }

  void _paint(Combatant t, Elem e) {
    if (e == Elem.none || !t.alive) return;
    if (!t.isPlayer && t.def!.passive == 'erased') return;
    if (t.aura == Elem.none || t.auraTurns <= 0) {
      t.aura = e;
      t.auraTurns = 2;
      return;
    }
    if (t.aura == e) {
      t.auraTurns = t.isPlayer ? 2 : 99;
      return;
    }
    final r = reactionFor(t.aura, e);
    t.aura = Elem.none;
    t.auraTurns = 0;
    // An innate aura comes back after a short lull.
    if (!t.isPlayer && t.def!.elem != Elem.none) t.auraCooldown = 2;
    if (r != null) _reaction(r, t);
  }

  void _reaction(String id, Combatant t) {
    reactionsThisTurn++;
    reactionsFired++;
    final rd = kReactions[id]!;
    popups.add(Popup(foes.indexOf(t), rd.name, 'reaction'));

    final bonus = has('void_pearl') ? 8 : 0;
    final scale = 8 + run.act * 5;
    _tally = 0;

    switch (id) {
      case 'vaporize':
        _damage(hero, t, scale * 2 + bonus, isAttack: false);
      case 'overload':
        for (final f in foes.where((f) => f.alive)) {
          _damage(hero, f, scale + bonus, isAttack: false);
        }
      case 'wither':
        t.block = t.block ~/ 2;
        _applyStatus(t, 'decay', 3);
        _damage(hero, t, scale + bonus, isAttack: false);
      case 'purge':
        final buffs = t.st.keys.where((k) => kStatus[k]?.debuff == false).toList();
        for (final b in buffs) {
          t.clear(b);
        }
        _damage(hero, t, scale + buffs.length * 6 + bonus, isAttack: false);
      case 'superconduct':
        _applyStatus(t, 'frozen', 1);
        _applyStatus(t, 'vulnerable', 2);
      case 'deepfreeze':
        _applyStatus(t, 'rime', 4);
        t.patternIdx = rng.nextInt(t.def!.pattern.length);
        _planIntents();
      case 'prism':
        _gainBlock(hero, scale + bonus);
      case 'blackout':
        _applyStatus(t, 'silence', 2);
        _damage(hero, t, scale ~/ 2 + bonus, isAttack: false);
      case 'judgment':
        for (final f in foes.where((f) => f.alive)) {
          _damage(hero, f, scale + bonus, isAttack: false);
          _applyStatus(f, 'shock', 2);
        }
      case 'eclipse':
        _damage(hero, t, scale + 10 + bonus, isAttack: false, pierce: true);
        _applyStatus(t, 'doom', 3);
    }

    // Terse and factual — the readout is an instrument, not a narrator.
    final rider = _reactionRider[id];
    _say(
      [
        rd.name,
        if (_tally > 0) '$_tally dmg',
        if (rider != null) rider,
      ].join(' · '),
      kind: 'reaction',
    );

    for (final rid in run.relics) {
      final r = relicDef(rid);
      if (r.trigger == RelicTrigger.onReaction) {
        if (rid == 'quill_of_names' && reactionsThisTurn == 1) _draw(1);
        _applyFxList(r.fx, null, source: r.name);
      }
    }
  }

  void _applyStatus(Combatant t, String key, int amount) {
    if (amount == 0 || !t.alive) return;
    var v = amount;
    if (key == 'burn') {
      if (!t.isPlayer && t.mods.contains('ashen')) return;
      if (!t.isPlayer && t.def!.passive == 'unfinished') return;
      v += hero.s('wildfire');
      if (has('ember_coin')) v += 1;
    }
    if (key == 'poison' && !t.isPlayer && t.def!.passive == 'unfinished') return;
    if (key == 'shock' && has('storm_shard')) v += 1;
    t.add(key, v);
    _pop(t, '${kStatus[key]?.name ?? key} +$v', 'status');
  }

  void _gainBlock(Combatant t, int v) {
    if (v <= 0) return;
    var amt = v + t.s('guard');
    if (t.isPlayer && has('frozen_rose')) amt += 2;
    t.block += amt;
    _pop(t, '+$amt', 'block');
    if (t.isPlayer && hero.s('glacierheart') > 0) {
      final live = foes.where((f) => f.alive).toList();
      if (live.isNotEmpty) {
        _damage(hero, rng.pick(live), hero.s('glacierheart'), isAttack: false);
      }
    }
  }

  void _heal(Combatant t, int v) {
    if (v <= 0 || !t.alive) return;
    if (t.s('decay') > 0) return;
    if (t.isPlayer && has('ouroboros_true')) return;
    var amt = v;
    // A parasite on the board makes every heal you own worth half.
    if (t.isPlayer && foes.any((f) => f.alive && f.def!.passive == 'parasite')) {
      amt = math.max(1, amt ~/ 2);
    }
    if (t.isPlayer && t.s('radiance') > 0) amt = (amt * 1.5).round();
    final before = t.hp;
    t.hp = math.min(t.maxHp, t.hp + amt);
    final done = t.hp - before;
    if (done > 0) _pop(t, '+$done', 'heal');
    if (t.isPlayer && done > 0) {
      if (has('seed_of_dawn')) _gainBlock(hero, 2);
      if (hero.s('crown') > 0) {
        final live = foes.where((f) => f.alive).toList();
        if (live.isNotEmpty) {
          _damage(hero, rng.pick(live),
              hero.s('crown') >= 2 ? (done * 1.5).round() : done,
              isAttack: false);
        }
      }
    }
  }

  void _hurt(Combatant t, int v, String why) {
    if (v <= 0) return;
    t.hp -= v;
    _pop(t, '-$v', 'damage');
    if (t.hp <= 0 && t.isPlayer) {
      _tryCheatDeath();
      // Nothing downstream should ever see a negative pool — the run state is
      // written straight out of this number.
      if (t.hp < 0) t.hp = 0;
    }
  }

  void _tickEnd(Combatant t) {
    if (!t.alive) return;
    final label = t.isPlayer ? 'you' : _short(t.displayName);

    if (t.s('burn') > 0) {
      final b = t.s('burn');
      _damage(t.isPlayer ? t : hero, t, b, isAttack: false);
      t.add('burn', -1);
      _say('Burn → $label $b', kind: 'tick');
    }
    if (t.s('poison') > 0) {
      final p = t.s('poison');
      t.hp -= p;
      _pop(t, '-$p', 'damage');
      t.add('poison', -1);
      _say('Poison → $label $p', kind: 'tick');
      if (t.hp <= 0) _onDeath(t);
    }
    if (t.s('regen') > 0) {
      _heal(t, t.s('regen'));
      _say('Regen → $label +${t.s('regen')}', kind: 'tick');
      t.add('regen', -1);
    }
    if (t.s('decay') > 0) {
      t.maxHp = math.max(1, t.maxHp - 2);
      t.hp = math.min(t.hp, t.maxHp);
      t.add('decay', -1);
    }
    if (t.s('doom') > 0) {
      t.add('doom', -1);
      if (t.s('doom') <= 0) {
        final d = (t.maxHp * .35).round();
        t.hp -= d;
        _pop(t, 'DOOM -$d', 'damage');
        _say('DOOM → $label $d', kind: 'death');
        if (t.hp <= 0) _onDeath(t);
      }
    }
    for (final k in ['rime', 'vulnerable', 'weak', 'radiance', 'overcharge', 'silence', 'stealth', 'entangle']) {
      if (t.s(k) > 0) t.add(k, -1);
    }
    if (t.auraTurns > 0) {
      t.auraTurns--;
      if (t.auraTurns == 0) t.aura = Elem.none;
    }
  }

  // ------------------------------------------------------------- piles
  void _draw(int n) {
    for (var i = 0; i < n; i++) {
      if (hand.length >= 10) return;
      if (drawPile.isEmpty) {
        if (discard.isEmpty) return;
        drawPile = rng.shuffled(discard);
        discard = [];
      }
      hand.add(drawPile.removeLast());
    }
  }

  bool _checkEnd() {
    if (ended) return true;
    if (hero.hp <= 0) {
      ended = true;
      victory = false;
      run.hp = 0;
      return true;
    }
    if (foes.every((f) => !f.alive)) {
      ended = true;
      victory = true;
      _finish();
      return true;
    }
    return false;
  }

  void _finish() {
    run.hp = math.max(1, hero.hp);
    run.maxHp = hero.maxHp;
    var gold = switch (kind) {
      'elite' => rng.range(55, 85),
      'boss' => rng.range(100, 150),
      _ => rng.range(24, 44),
    };
    if (foes.any((f) => f.mods.contains('gilded'))) gold *= 2;
    goldReward = gold;
    for (final id in run.relics) {
      final r = relicDef(id);
      if (r.trigger == RelicTrigger.onBattleWin) {
        if (id == 'last_ember') _heal(hero, 5 * foes.length);
        if (id == 'crown_shard' && kind != 'normal') {
          run.maxHp += 4;
          hero.maxHp += 4;
        }
      }
    }
    run.hp = math.max(1, hero.hp);
    _say('The frame holds. You are still here.', kind: 'cinematic');
  }

  // ------------------------------------------------------------- forecast
  /// One row of the combat readout: exactly what this foe will do, with the
  /// arithmetic already done.
  List<FoeIntentInfo> intentInfos() {
    final out = <FoeIntentInfo>[];
    for (final f in foes) {
      if (!f.alive) continue;
      final name = f.displayName;

      if (f.s('frozen') > 0) {
        out.add(FoeIntentInfo(name: name, kind: IntentKind.sleep, note: 'frozen — loses its turn'));
        continue;
      }
      if (!f.awake) {
        out.add(FoeIntentInfo(name: name, kind: IntentKind.sleep, note: 'dormant'));
        continue;
      }
      final it = f.intent;
      if (it == null) continue;

      final total = incomingFrom(f);
      final times = it.kind == IntentKind.attackMulti ? it.times : 1;
      final perHit = times > 1 ? (total / times).round() : total;
      final rider = (it.status != null && it.statusAmt > 0)
          ? '${kStatus[it.status!]?.name ?? it.status!} ${it.statusAmt}'
          : null;

      out.add(FoeIntentInfo(
        name: name,
        kind: it.kind,
        perHit: perHit,
        times: times,
        total: total,
        guard: it.kind == IntentKind.block ? it.value : 0,
        rider: rider,
        note: it.kind == IntentKind.special ? it.note : null,
        buff: it.kind == IntentKind.buff
            ? '${kStatus[it.status ?? 'strength']?.name ?? 'Strength'} +${it.statusAmt}'
            : null,
      ));
    }
    return out;
  }

  /// What one foe's telegraphed intent will actually cost you, after Strength,
  /// Weak, Vulnerable and its own modifiers. This is the number the player
  /// needs to make every decision, so the UI shows it rather than the raw one.
  int incomingFrom(Combatant f) {
    if (!f.alive || !f.awake || f.s('frozen') > 0) return 0;
    final it = f.intent;
    if (it == null) return 0;
    if (it.kind != IntentKind.attack &&
        it.kind != IntentKind.attackMulti &&
        !(it.kind == IntentKind.special && it.value > 0)) {
      return 0;
    }
    var per = it.value.toDouble() + f.s('strength');
    if (f.mods.contains('waning')) per *= 1.5;
    if (f.s('weak') > 0) per *= .75;
    if (f.s('overcharge') > 0) per *= 1.5;
    if (hero.s('vulnerable') > 0) per *= 1.4;
    if (hero.s('rime') > 0) per *= 1.3;
    if (hero.s('overcharge') > 0) per *= 1.25;
    final hits = it.kind == IntentKind.special ? 1 : it.times;
    return (per < 1 ? 1 : per).round() * hits;
  }

  /// Total telegraphed damage this turn across every foe.
  int get incomingTotal =>
      foes.fold(0, (sum, f) => sum + incomingFrom(f));

  /// How much of [incomingTotal] your Guard will actually stop. Multi-hit
  /// attacks chew through Guard hit by hit, so this is an honest simulation
  /// rather than a simple subtraction.
  int get incomingAfterGuard {
    if (hero.s('ward') > 0) return 0;
    var guard = hero.block;
    var through = 0;
    for (final f in foes) {
      if (!f.alive) continue;
      final total = incomingFrom(f);
      if (total <= 0) continue;
      final it = f.intent!;
      final hits = it.kind == IntentKind.attackMulti ? it.times : 1;
      final per = (total / hits).round();
      for (var i = 0; i < hits; i++) {
        final absorbed = per < guard ? per : guard;
        guard -= absorbed;
        through += per - absorbed;
      }
    }
    return through;
  }

  void _say(String s, {String kind = 'info'}) =>
      log.add(LogLine(s, kind: kind, turn: turn));
  void _pop(Combatant t, String text, String kind) =>
      popups.add(Popup(t.isPlayer ? -1 : foes.indexOf(t), text, kind));
}
