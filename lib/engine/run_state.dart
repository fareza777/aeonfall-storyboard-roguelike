import 'dart:convert';

import '../data/cards.dart';
import '../data/vessels.dart';
import 'core.dart';
import 'map_gen.dart';
import 'rng.dart';

/// Everything about the current run. Persisted so a run survives app restarts.
class RunState {
  RunState({
    required this.seed,
    required this.vesselId,
    required this.ascension,
  }) : vessel = vesselById(vesselId),
       hp = vesselById(vesselId).hp,
       maxHp = vesselById(vesselId).hp {
    rng = Rng(seed);
    deck = [];
    for (final e in vessel.deck.entries) {
      for (var i = 0; i < e.value; i++) {
        deck.add(CardInst(cardDef(e.key)));
      }
    }
    relics = [vessel.relic];
  }

  RunState._raw(this.seed, this.vesselId, this.ascension)
    : vessel = vesselById(vesselId);

  final int seed;
  final String vesselId;
  final VesselDef vessel;
  final int ascension;

  late Rng rng;
  int hp = 1;
  int maxHp = 1;
  int gold = 120;
  int act = 1;
  int floor = 0;
  int totalFloors = 0;
  bool mirrorCoinUsed = false;

  late List<CardInst> deck;
  late List<String> relics;
  StoryMap? map;

  /// The draught belt. Three slots, four with the Deep Satchel.
  List<String> potions = [];
  int get potionSlots => relics.contains('deep_satchel') ? 4 : 3;
  bool get beltFull => potions.length >= potionSlots;

  /// Returns false when there was no room, so callers can offer a swap.
  bool addPotion(String id) {
    if (beltFull) return false;
    potions.add(id);
    return true;
  }

  // ------------------------------------------------------- narrative
  String chronicleId = '';
  String antagonistId = '';
  String betrayerId = '';
  int betrayalActed = 0;
  List<String> companions = [];
  List<String> pages = [];
  Set<String> flags = {};
  Set<String> seenEvents = {};
  List<String> journal = [];
  int mercy = 0;
  int cruelty = 0;
  String? pendingTwist;

  // ------------------------------------------------------- run record
  /// Counted as the run happens so the end-of-run summary is a record rather
  /// than a reconstruction.
  int foesFelled = 0;
  int elitesFelled = 0;
  int bossesFelled = 0;
  int damageDealt = 0;
  int damageTaken = 0;
  int cinematics = 0;
  int reactions = 0;
  int draughtsDrunk = 0;
  int aidsCalled = 0;
  int turnsTaken = 0;

  /// One entry per floor: HP on arrival. Drawn as the run's pulse line.
  List<int> hpTrail = [];

  Map<String, dynamic> get record => {
    'foes': foesFelled,
    'elites': elitesFelled,
    'bosses': bossesFelled,
    'dealt': damageDealt,
    'taken': damageTaken,
    'cine': cinematics,
    'react': reactions,
    'draughts': draughtsDrunk,
    'aids': aidsCalled,
    'turns': turnsTaken,
    'trail': hpTrail,
  };

  void loadRecord(Map<String, dynamic>? j) {
    if (j == null) return;
    foesFelled = j['foes'] ?? 0;
    elitesFelled = j['elites'] ?? 0;
    bossesFelled = j['bosses'] ?? 0;
    damageDealt = j['dealt'] ?? 0;
    damageTaken = j['taken'] ?? 0;
    cinematics = j['cine'] ?? 0;
    reactions = j['react'] ?? 0;
    draughtsDrunk = j['draughts'] ?? 0;
    aidsCalled = j['aids'] ?? 0;
    turnsTaken = j['turns'] ?? 0;
    hpTrail = List<int>.from(j['trail'] ?? []);
  }

  Elem get dominantElement {
    final counts = <Elem, int>{};
    for (final c in deck) {
      if (c.def.elem == Elem.none) continue;
      counts[c.def.elem] = (counts[c.def.elem] ?? 0) + 1;
    }
    if (counts.isEmpty) return vessel.elem;
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  bool flag(String f) => flags.contains(f);
  void setFlag(String f) => flags.add(f);

  void addCard(String id, {bool upgraded = false}) =>
      deck.add(CardInst(cardDef(id), upgraded: upgraded));

  void addRelic(String id) {
    if (!relics.contains(id)) relics.add(id);
  }

  void heal(int v) => hp = (hp + v).clamp(1, maxHp);
  void damage(int v) => hp = (hp - v).clamp(0, maxHp);
  void gainMaxHp(int v) {
    // Events use this with a negative value to carve max HP away, so both
    // numbers have to be floored or the run records a negative pool.
    maxHp = (maxHp + v).clamp(1, 9999);
    hp = (hp + v).clamp(0, maxHp);
  }

  void note(String s) {
    journal.add(s);
    if (journal.length > 60) journal.removeAt(0);
  }

  Map<String, dynamic> toJson() => {
    'seed': seed,
    'vessel': vesselId,
    'asc': ascension,
    'hp': hp,
    'maxHp': maxHp,
    'gold': gold,
    'act': act,
    'floor': floor,
    'totalFloors': totalFloors,
    'mirror': mirrorCoinUsed,
    'deck': deck.map((c) => c.toJson()).toList(),
    'relics': relics,
    'potions': potions,
    'map': map?.toJson(),
    'chron': chronicleId,
    'antag': antagonistId,
    'betrayer': betrayerId,
    'betrayed': betrayalActed,
    'comps': companions,
    'pages': pages,
    'flags': flags.toList(),
    'seen': seenEvents.toList(),
    'journal': journal,
    'mercy': mercy,
    'cruelty': cruelty,
    'twist': pendingTwist,
    'record': record,
  };

  static RunState fromJson(Map<String, dynamic> j) {
    final r = RunState._raw(
      j['seed'] as int,
      j['vessel'] as String,
      j['asc'] as int? ?? 0,
    );
    r.rng = Rng(r.seed);
    r.hp = j['hp'];
    r.maxHp = j['maxHp'];
    r.gold = j['gold'];
    r.act = j['act'];
    r.floor = j['floor'];
    r.totalFloors = j['totalFloors'] ?? 0;
    r.mirrorCoinUsed = j['mirror'] ?? false;
    r.deck = (j['deck'] as List)
        .map((e) => CardInst(cardDef(e['id']), upgraded: e['up'] == true))
        .toList();
    r.relics = List<String>.from(j['relics']);
    r.potions = List<String>.from(j['potions'] ?? []);
    r.map = j['map'] == null ? null : StoryMap.fromJson(j['map']);
    r.chronicleId = j['chron'] ?? '';
    r.antagonistId = j['antag'] ?? '';
    r.betrayerId = j['betrayer'] ?? '';
    r.betrayalActed = j['betrayed'] ?? 0;
    r.companions = List<String>.from(j['comps'] ?? []);
    r.pages = List<String>.from(j['pages'] ?? []);
    r.flags = Set<String>.from(j['flags'] ?? []);
    r.seenEvents = Set<String>.from(j['seen'] ?? []);
    r.journal = List<String>.from(j['journal'] ?? []);
    r.mercy = j['mercy'] ?? 0;
    r.cruelty = j['cruelty'] ?? 0;
    r.pendingTwist = j['twist'];
    r.loadRecord(j['record'] as Map<String, dynamic>?);
    return r;
  }
}

/// Progress that survives death.
class MetaState {
  int shards = 0;
  int runs = 0;
  int wins = 0;
  int deepestAct = 1;
  int ascension = 0;
  Set<String> vessels = {'ashcaller', 'saintcoralis', 'voltborn'};
  Set<String> endings = {};
  Set<String> lore = {};
  Set<String> codexEnemies = {};
  Set<String> upgrades = {};
  bool onboarded = false;
  bool tutorialDone = false;
  bool music = true;
  bool sfx = true;
  bool adsRemoved = false;

  // ------------------------------------------------------- preferences
  /// Multiplies every text size in the game. Some people need bigger type and
  /// some people want more on screen; both are reasonable.
  double textScale = 1.0;

  /// Elements get a distinct shape as well as a colour, for players who
  /// cannot rely on the colour alone.
  bool colourblind = false;

  /// Cuts shake, flourishes and the slower beats for anyone who finds them
  /// uncomfortable or simply wants to play faster.
  bool reducedMotion = false;
  bool haptics = true;

  // ----------------------------------------------------------- history
  /// The last thirty runs, newest first. Kept small on purpose — this is a
  /// record to look back on, not an analytics warehouse.
  List<Map<String, dynamic>> history = [];

  void recordRun(
    RunState r, {
    required bool won,
    String? ending,
    int? finishedAt,
  }) {
    history.insert(0, {
      'vessel': r.vesselId,
      'asc': r.ascension,
      'seed': r.seed,
      'act': r.act,
      'floors': r.totalFloors,
      'won': won,
      'ending': ending,
      'chron': r.chronicleId,
      'deck': r.deck.length,
      'relics': r.relics.length,
      'pages': r.pages.length,
      'at': finishedAt ?? 0,
      'record': r.record,
    });
    if (history.length > 30) history.removeRange(30, history.length);
  }

  int runsWith(String vesselId) =>
      history.where((h) => h['vessel'] == vesselId).length;
  int winsWith(String vesselId) =>
      history.where((h) => h['vessel'] == vesselId && h['won'] == true).length;

  int get bonusHp => upgrades.contains('vigor') ? 10 : 0;
  int get bonusGold => upgrades.contains('purse') ? 60 : 0;
  bool get extraRelic => upgrades.contains('sigil');
  bool get extraCardChoice => upgrades.contains('archive');

  Map<String, dynamic> toJson() => {
    'shards': shards,
    'runs': runs,
    'wins': wins,
    'deepest': deepestAct,
    'asc': ascension,
    'vessels': vessels.toList(),
    'endings': endings.toList(),
    'lore': lore.toList(),
    'codex': codexEnemies.toList(),
    'upgrades': upgrades.toList(),
    'onboarded': onboarded,
    'tutorial': tutorialDone,
    'music': music,
    'sfx': sfx,
    'adsRemoved': adsRemoved,
    'textScale': textScale,
    'colourblind': colourblind,
    'reducedMotion': reducedMotion,
    'haptics': haptics,
    'history': history,
  };

  static MetaState fromJson(Map<String, dynamic> j) {
    final m = MetaState();
    m.shards = j['shards'] ?? 0;
    m.runs = j['runs'] ?? 0;
    m.wins = j['wins'] ?? 0;
    m.deepestAct = j['deepest'] ?? 1;
    m.ascension = j['asc'] ?? 0;
    m.vessels = Set<String>.from(
      j['vessels'] ?? ['ashcaller', 'saintcoralis', 'voltborn'],
    );
    m.endings = Set<String>.from(j['endings'] ?? []);
    m.lore = Set<String>.from(j['lore'] ?? []);
    m.codexEnemies = Set<String>.from(j['codex'] ?? []);
    m.upgrades = Set<String>.from(j['upgrades'] ?? []);
    m.onboarded = j['onboarded'] ?? false;
    m.tutorialDone = j['tutorial'] ?? false;
    m.music = j['music'] ?? true;
    m.sfx = j['sfx'] ?? true;
    m.adsRemoved = j['adsRemoved'] ?? false;
    m.textScale = (j['textScale'] as num?)?.toDouble() ?? 1.0;
    m.colourblind = j['colourblind'] ?? false;
    m.reducedMotion = j['reducedMotion'] ?? false;
    m.haptics = j['haptics'] ?? true;
    m.history = ((j['history'] as List?) ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    return m;
  }

  String encode() => jsonEncode(toJson());
  static MetaState decode(String s) =>
      fromJson(jsonDecode(s) as Map<String, dynamic>);
}
