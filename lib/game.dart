import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio.dart';
import 'engine/battle.dart';
import 'engine/director.dart';
import 'engine/map_gen.dart';
// ignore: unused_import
import 'engine/core.dart';
import 'engine/run_state.dart';

/// Single source of truth for the app. Screens listen to this.
class Game extends ChangeNotifier {
  static final Game i = Game._();
  Game._();

  MetaState meta = MetaState();
  RunState? run;
  Director? director;
  Battle? battle;

  SharedPreferences? _prefs;
  bool ready = false;

  static const _kMeta = 'aeonfall_meta_v1';
  static const _kRun = 'aeonfall_run_v1';

  Future<void> boot() async {
    _prefs = await SharedPreferences.getInstance();
    final m = _prefs!.getString(_kMeta);
    if (m != null) {
      try {
        meta = MetaState.decode(m);
      } catch (_) {}
    }
    final r = _prefs!.getString(_kRun);
    if (r != null) {
      try {
        run = RunState.fromJson(jsonDecode(r) as Map<String, dynamic>);
        director = Director(run!);
      } catch (_) {
        run = null;
      }
    }
    Audio.i.musicOn = meta.music;
    Audio.i.sfxOn = meta.sfx;
    await Audio.i.init();
    ready = true;
    notifyListeners();
  }

  bool get hasRun => run != null && run!.hp > 0 && run!.act <= 3;

  // ------------------------------------------------------------ saving
  void saveMeta() {
    _prefs?.setString(_kMeta, meta.encode());
  }

  /// Persists the run *and* tells listening widgets to refresh. Every screen
  /// that mutates gold, HP or the deck calls this, so the HUD stays truthful.
  void saveRun() {
    if (run == null) {
      _prefs?.remove(_kRun);
    } else {
      _prefs?.setString(_kRun, jsonEncode(run!.toJson()));
    }
    notifyListeners();
  }

  void save() {
    saveMeta();
    saveRun();
  }

  // ------------------------------------------------------------- flow
  void startRun(int seed, String vesselId) {
    run = Director.newRun(seed, vesselId, meta);
    director = Director(run!);
    battle = null;
    meta.runs++;
    save();
    notifyListeners();
  }

  void abandonRun() {
    run = null;
    director = null;
    battle = null;
    saveRun();
    notifyListeners();
  }

  bool get wantsTutorial => !meta.tutorialDone;

  /// Events, curses and bargains can drain you to nothing outside of combat.
  /// Nothing used to check for that, so you could walk the map on 0 HP.
  /// Returns true if the run has just ended.
  bool checkDeathOutsideBattle() {
    final r = run;
    if (r == null || r.hp > 0) return false;
    if (r.relics.contains('mirror_coin') && !r.mirrorCoinUsed) {
      r.mirrorCoinUsed = true;
      r.hp = 1;
      saveRun();
      return false;
    }
    return true;
  }

  void beginBattle(NodeType type) {
    final d = director!;
    final foes = wantsTutorial && type == NodeType.battle
        ? [Director.tutorialFoe(run!.vessel.elem)]
        : d.encounter(type);
    final kind = switch (type) {
      NodeType.boss => 'boss',
      NodeType.elite => 'elite',
      _ => 'normal',
    };
    battle = Battle(
      run: run!,
      foeDefs: foes,
      rng: run!.rng.fork('battle-${run!.act}-${run!.totalFloors}'),
      kind: kind,
    )..start();
    for (final f in foes) {
      meta.codexEnemies.add(f.id);
    }
    Audio.i.music(kind == 'boss' ? 'boss' : (kind == 'elite' ? 'elite' : 'battle'));
    notifyListeners();
  }

  void endBattle() {
    battle = null;
    notifyListeners();
  }

  /// Called when a node is fully resolved.
  void completeNode(int nodeId) {
    final map = run!.map!;
    final node = map.byId(nodeId);
    node.visited = true;
    map.currentId = nodeId;
    map.available = List<int>.from(node.next);
    run!.floor = node.layer;
    run!.totalFloors++;
    // One reading per floor — the run's pulse line on the summary screen.
    run!.hpTrail.add(run!.hp);
    if (run!.relics.contains('ash_locket')) run!.heal(6);
    if (meta.deepestAct < run!.act) {
      meta.deepestAct = run!.act;
      if (run!.act >= 3) meta.vessels.add('paradox');
    }
    save();
    notifyListeners();
  }

  void enterNode(int nodeId) {
    final map = run!.map!;
    map.currentId = nodeId;
    notifyListeners();
  }

  void nextAct() {
    director!.advanceAct();
    save();
    notifyListeners();
  }

  void finishRun(String endingId, {required bool won}) {
    meta.endings.add(endingId);
    meta.recordRun(run!,
        won: won,
        ending: endingId,
        finishedAt: DateTime.now().millisecondsSinceEpoch);
    if (won) meta.wins++;
    meta.shards += 40 + run!.totalFloors * 3 + (won ? 120 : 0);
    if (won && meta.ascension < 20) meta.ascension++;
    lastRun = run;
    run = null;
    director = null;
    battle = null;
    save();
    notifyListeners();
  }

  void die() {
    meta.recordRun(run!,
        won: false, finishedAt: DateTime.now().millisecondsSinceEpoch);
    meta.shards += 20 + run!.totalFloors * 2;
    lastRun = run;
    run = null;
    director = null;
    battle = null;
    save();
    notifyListeners();
  }

  /// The run that just ended. `finishRun` and `die` clear `run`, but the
  /// result screen still has to be able to show what happened.
  RunState? lastRun;

  void touch() => notifyListeners();
}
