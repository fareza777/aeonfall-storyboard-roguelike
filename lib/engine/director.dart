import 'dart:math' as math;

import '../data/ascension.dart';
import '../data/beats.dart';
import '../data/cards.dart';
import '../data/chronicles.dart';
import '../data/companions.dart';
import '../data/enemies.dart';
import '../data/events.dart';
import '../data/narrative_model.dart';
import '../data/potions.dart';
import '../data/relics.dart';
import 'core.dart';
import 'map_gen.dart';
import 'rng.dart';
import 'run_state.dart';

/// Chooses what happens next and applies the consequences. Everything that
/// makes two runs differ lives here.
class Director {
  Director(this.run);
  final RunState run;

  Rng get _r => run.rng;

  /// Which Ascension rules are in force. Everything that scales with
  /// difficulty asks this rather than doing its own arithmetic.
  AscensionRules get asc => AscensionRules(run.ascension);

  // -------------------------------------------------------- run setup
  static RunState newRun(int seed, String vesselId, MetaState meta) {
    final run = RunState(seed: seed, vesselId: vesselId, ascension: meta.ascension);
    final asc = AscensionRules(meta.ascension);
    run.maxHp += meta.bonusHp - asc.startingMaxHpPenalty;
    if (run.maxHp < 20) run.maxHp = 20;
    run.hp = run.maxHp;
    run.gold = 120 + meta.bonusGold;
    if (meta.extraRelic) run.addRelic('bone_flute');
    // Ascension 4 — you set out already carrying something you did not choose.
    if (asc.startWithCurse) {
      run.addCard(run.rng.fork('asc').pick(kCursePool).id);
    }

    final r = run.rng.fork('narrative');
    final chron = r.pick(kChronicles);
    run.chronicleId = chron.id;
    run.antagonistId = chron.antagonist;

    // Two candidate companions; one of them is carrying an instruction.
    final pool = r.sample(kCompanions, 3);
    run.setFlag('cand_${pool[0].id}');
    run.setFlag('cand_${pool[1].id}');
    run.setFlag('cand_${pool[2].id}');
    run.betrayerId = r.pick(pool).id;

    run.map = generateMap(run.rng, 1, ascension: meta.ascension);
    run.note('${chron.title} — ${chron.subtitle}');
    return run;
  }

  // ------------------------------------------------------- encounters
  List<EnemyDef> encounter(NodeType type) {
    final r = _r.fork('enc-${run.act}-${run.floor}-${run.totalFloors}');
    switch (type) {
      case NodeType.boss:
        final pool = bossPool(run.act);
        return [pool.isEmpty ? kBosses.last : r.pick(pool)];
      case NodeType.elite:
        final pool = elitePool(run.act);
        final e = pool.isEmpty ? r.pick(kElites) : r.pick(pool);
        // An escort becomes likelier the deeper into the act the elite is.
        if (run.act >= 2 && r.chance(.20 + depth * .35)) {
          return [e, r.pick(normalPool(run.act))];
        }
        return [e];
      default:
        final pool = normalPool(run.act);
        // Foes used to be drawn flat from the whole act, so floor one could
        // hand you the heaviest thing in the book and the last floor before
        // the boss could hand you the lightest. Both read as the game not
        // paying attention. Draw from a band that climbs with depth instead.
        final dom = run.dominantElement;
        final count = _r.weighted([1, 2, 3], (n) => switch (n) {
              1 => 44 - (depth * 30).round(),
              2 => 42 + (depth * 6).round(),
              _ => 6 + (depth * 30).round(),
            });
        return List.generate(
          count,
          (_) => r.weighted(pool, (e) {
            // Element: still push towards what the deck is not built to beat.
            final elemW = e.elem == dom ? 6 : 14;
            return elemW * _depthFit(e, pool);
          }),
        );
    }
  }

  /// How far through the current act the player is: 0 at the entry layer,
  /// 1 at the boss door.
  double get depth => (run.floor / 13).clamp(0.0, 1.0);

  /// How well a foe's weight suits the current depth, as a multiplier.
  ///
  /// Never returns zero — a light foe deep in an act is fine as part of a
  /// group of three, it just should not be the whole encounter. This shapes
  /// the draw rather than censoring it.
  int _depthFit(EnemyDef e, List<EnemyDef> pool) {
    var lo = 9999.0, hi = 0.0;
    for (final x in pool) {
      final m = (x.hp + x.hpMax) / 2;
      if (m < lo) lo = m;
      if (m > hi) hi = m;
    }
    if (hi <= lo) return 10;

    final mine = ((e.hp + e.hpMax) / 2 - lo) / (hi - lo); // 0 lightest, 1 heaviest
    // Aim low early and high late. The band still overlaps its neighbours so
    // encounters stay varied, but the falloff is squared — a soft linear band
    // barely moved the average in acts whose pools have a narrow HP spread.
    final target = 0.10 * (1 - depth) + 0.94 * depth;
    final off = (mine - target).abs();
    final near = (1.0 - off * 1.35).clamp(0.0, 1.0);
    final fit = near * near;
    return (fit * 60).round().clamp(1, 60);
  }

  /// The scripted first fight: a single weak foe whose element is deliberately
  /// different from the Vessel's, so the player's own starter cards trigger a
  /// Reaction while the tutorial is explaining what one is.
  static EnemyDef tutorialFoe(Elem vesselElem) {
    final base = switch (vesselElem) {
      Elem.ember => enemyDef('drowned_choirboy'),
      Elem.frost => enemyDef('cinder_wretch'),
      Elem.volt => enemyDef('bone_florist'),
      Elem.umbra => enemyDef('dawn_sentry'),
      Elem.lumen => enemyDef('shade_stalker'),
      _ => enemyDef('cinder_wretch'),
    };
    // Padded health so the fight outlives the 13 coaching steps — a Reaction
    // on turn one would otherwise end the tutorial before it taught anything.
    return EnemyDef(
      id: base.id,
      name: base.name,
      hp: 84,
      hpMax: 84,
      elem: base.elem,
      tier: 0,
      act: 1,
      pattern: base.pattern,
      art: base.art,
      blurb: base.blurb,
    );
  }

  // ----------------------------------------------------------- events
  GameEvent? nextEvent({bool mystery = false}) {
    final beat = _pendingBeat();
    if (beat != null) return beat;

    final r = _r.fork('ev-${run.act}-${run.totalFloors}');
    final pool = kAllEvents.where((e) {
      if (e.once && run.seenEvents.contains(e.id)) return false;
      if (e.act != 0 && e.act != run.act) return false;
      if (e.requireFlag != null && !run.flag(e.requireFlag!)) return false;
      if (e.forbidFlag != null && run.flag(e.forbidFlag!)) return false;
      return true;
    }).toList();
    if (pool.isEmpty) return null;
    final ev = r.weighted(pool, (e) => e.weight);
    run.seenEvents.add(ev.id);
    return ev;
  }

  /// Mandatory story beats fire on fixed floors so the three revelations always
  /// land, in order, whichever Chronicle is running.
  GameEvent? _pendingBeat() {
    if (run.act == 1 && run.floor >= 7 && !run.flag('beat1')) {
      run.setFlag('beat1');
      return beatById('beat_act1');
    }
    if (run.act == 2 && run.floor >= 6 && !run.flag('beat2')) {
      run.setFlag('beat2');
      return beatById('beat_act2');
    }
    if (run.act == 2 && run.floor >= 11 && !run.flag('beat_betrayal') &&
        run.companions.contains(run.betrayerId)) {
      run.setFlag('beat_betrayal');
      return _betrayalBeat();
    }
    if (run.act == 3 && run.floor >= 9 && !run.flag('beat3')) {
      run.setFlag('beat3');
      return beatById('beat_act3');
    }
    return null;
  }

  GameEvent _betrayalBeat() {
    final c = companionById(run.betrayerId);
    final base = beatById('beat_betrayal');
    return GameEvent(
      id: base.id,
      title: base.title,
      art: base.art,
      tag: 'beat',
      once: false,
      speaker: c.name,
      body: '${c.betrayal}\n\n— ${c.name}, ${c.title}',
      choices: base.choices
          .map((ch) => EvChoice(
                label: ch.label,
                hint: ch.hint,
                needGold: ch.needGold,
                needFlag: ch.needFlag,
                hidden: ch.hidden,
                result: ch.result == 'SPARED_RESULT' ? c.spared : ch.result,
                out: ch.out,
              ))
          .toList(),
    );
  }

  /// Offer a companion at a rest site, twice per run.
  Companion? offerCompanion() {
    if (run.companions.length >= 2) return null;
    final cands = kCompanions
        .where((c) => run.flag('cand_${c.id}') && !run.companions.contains(c.id))
        .toList();
    if (cands.isEmpty) return null;
    return _r.fork('comp-${run.totalFloors}').pick(cands);
  }

  void recruit(String id) {
    if (run.companions.contains(id)) return;
    run.companions.add(id);
    run.setFlag('has_companion');
    run.addRelic(companionById(id).gift);
    run.note('${companionById(id).name} joins you.');
  }

  // --------------------------------------------------------- outcomes
  String applyOutcome(Out o) {
    switch (o.kind) {
      case OutKind.gold:
        run.gold += o.value;
        return '+${o.value} Aeon';
      case OutKind.loseGold:
        run.gold = math.max(0, run.gold - o.value);
        return '−${o.value} Aeon';
      case OutKind.hp:
        // Silver Thread: the Sanctum's only sigil that softens the road.
        final v = run.relics.contains('silver_thread')
            ? math.max(1, (o.value / 2).round())
            : o.value;
        run.damage(v);
        return '−$v HP';
      case OutKind.heal:
        run.heal(o.value);
        return '+${o.value} HP';
      case OutKind.maxHp:
        run.gainMaxHp(o.value);
        return o.value >= 0 ? '+${o.value} Max HP' : '${o.value} Max HP';
      case OutKind.card:
        run.addCard(o.arg!);
        return 'Gained ${cardDef(o.arg!).name}';
      case OutKind.randomCard:
        final pool = rewardPoolFor(run.vesselId);
        final c = _r.pick(pool);
        run.addCard(c.id);
        return 'Gained ${c.name}';
      case OutKind.curse:
        final c = _r.pick(kCursePool);
        run.addCard(c.id);
        return 'Cursed: ${c.name}';
      case OutKind.relic:
        final id = o.arg ?? _randomRelic();
        run.addRelic(id);
        return 'Sigil: ${relicDef(id).name}';
      case OutKind.removeCard:
        final removable = run.deck.where((c) => c.def.rarity != Rarity.starter).toList();
        final target = removable.isNotEmpty ? _r.pick(removable) : null;
        if (target != null) {
          run.deck.remove(target);
          return 'Removed ${target.name}';
        }
        return 'Nothing to remove';
      case OutKind.upgradeCard:
        final ups = run.deck.where((c) => c.canUpgrade).toList();
        if (ups.isEmpty) return 'Nothing to upgrade';
        final t = _r.pick(ups);
        t.upgraded = true;
        return '${t.def.name} upgraded';
      case OutKind.flag:
        run.setFlag(o.arg!);
        return '';
      case OutKind.page:
        final n = run.pages.length + 1;
        run.pages.add('page_$n');
        return 'Torn Page ${run.pages.length}/9';
      case OutKind.companion:
        if (o.arg != null) recruit(o.arg!);
        return '';
      case OutKind.loseCompanion:
        if (run.companions.contains(run.betrayerId)) {
          run.companions.remove(run.betrayerId);
          run.addRelic('mercy_blade');
        }
        return '';
      case OutKind.shards:
        run.setFlag('shards_${o.value}_${run.totalFloors}');
        return '+${o.value} Aeon Shards';
      case OutKind.mercy:
        run.mercy += o.value;
        return '';
      case OutKind.cruelty:
        run.cruelty += o.value;
        return '';
      case OutKind.battle:
      case OutKind.eliteBattle:
      case OutKind.twist:
      case OutKind.nothing:
        return '';
    }
  }

  String _randomRelic() {
    final owned = run.relics.toSet();
    final pool = kRelics.where((r) => !owned.contains(r.id)).toList();
    if (pool.isEmpty) return kRelics.first.id;
    return _r.weighted(pool, (r) => relicWeight(r, run.act)).id;
  }

  // --------------------------------------------------------- rewards
  List<CardDef> cardReward({int? count}) {
    final r = _r.fork('rw-${run.act}-${run.totalFloors}');
    final pool = rewardPoolFor(run.vesselId);
    final n = (count ?? asc.cardRewardCount) +
        (run.relics.contains('marrow_die') ? 1 : 0);
    final out = <CardDef>[];
    var guard = 0;
    while (out.length < n && guard++ < 200) {
      final c = r.weighted(pool, (x) => rarityWeight(x.rarity, run.act));
      if (!out.contains(c)) out.add(c);
    }
    return out;
  }

  RelicDef relicReward() => relicDef(_randomRelic());

  // ------------------------------------------------------------ draughts
  PotionDef _rollPotion(String salt) {
    final r = _r.fork('pot-$salt');
    return r.weighted(kPotions, (p) => potionWeight(p.rarity, run.act));
  }

  /// Whether this fight left a draught behind.
  ///
  /// Nothing is guaranteed any more. Elites and bosses used to drop one every
  /// single time, which meant the belt was always full and the decision of
  /// when to drink one never had any weight behind it.
  PotionDef? potionDrop(String kind) {
    final r = _r.fork('drop-${run.act}-${run.totalFloors}');
    final satchel = run.relics.contains('deep_satchel');
    final base = switch (kind) {
      'boss' => satchel ? 85 : 70,
      'elite' => satchel ? 62 : 50,
      _ => satchel ? 28 : 20,
    };
    final chance = (base * asc.potionDropRate).round();
    if (r.nextInt(100) >= chance) return null;
    return _rollPotion('${run.act}-${run.totalFloors}');
  }

  List<PotionDef> potionStock() =>
      [for (var i = 0; i < 3; i++) _rollPotion('shop-${run.totalFloors}-$i')];

  int potionPrice(PotionDef p) => _marked(switch (p.rarity) {
        Rarity.common => 45 + _r.nextInt(15),
        Rarity.uncommon => 80 + _r.nextInt(25),
        _ => 135 + _r.nextInt(35),
      });

  List<CardDef> shopStock() {
    final r = _r.fork('shop-${run.act}-${run.totalFloors}');
    final pool = rewardPoolFor(run.vesselId);
    final n = 5 + (run.relics.contains('wax_seal') ? 1 : 0);
    final out = <CardDef>[];
    var guard = 0;
    while (out.length < n && guard++ < 200) {
      final c = r.weighted(pool, (x) => rarityWeight(x.rarity, run.act));
      if (!out.contains(c)) out.add(c);
    }
    return out;
  }

  /// Ascension 7 marks every shelf up.
  int _marked(int base) => (base * asc.shopPrices).round();

  int cardPrice(CardDef c) => _marked(switch (c.rarity) {
        Rarity.common => 55 + _r.nextInt(20),
        Rarity.uncommon => 95 + _r.nextInt(30),
        Rarity.rare => 165 + _r.nextInt(40),
        Rarity.mythic => 260,
        _ => 60,
      });

  // ----------------------------------------------------- act handling
  bool get atBossCleared =>
      run.map != null && run.map!.currentId >= 0 &&
      run.map!.byId(run.map!.currentId).type == NodeType.boss;

  void advanceAct() {
    run.act++;
    run.floor = 0;
    if (run.act <= 3) {
      run.map = generateMap(run.rng.fork('act$run.act'), run.act,
          ascension: run.ascension);
      run.heal((run.maxHp * .25).round());
    }
  }

  // -------------------------------------------------------- the ending
  /// [choice] is one of: pen, break, finish, walk.
  String pickEnding(String choice) {
    final kept = run.companions.isNotEmpty;
    final merciful = run.mercy >= run.cruelty + 3;
    final cruel = run.cruelty > run.mercy + 2;
    final pagesFull = run.pages.length >= 5;

    switch (choice) {
      case 'pen':
        if (cruel) return 'end_tyrant';
        if (run.mercy == 0 && run.cruelty == 0) return 'end_hollow';
        return 'end_become';
      case 'break':
        if (merciful && run.flag('saw_sunrise')) return 'end_sacrifice';
        if (run.flag('read_histories') || run.flag('saved_blanks')) return 'end_burn';
        if (run.vesselId == 'saintcoralis' && merciful) return 'end_freeze';
        return 'end_break';
      case 'finish':
        if (pagesFull && (merciful || kept)) return 'end_true';
        if (pagesFull) return 'end_ascend';
        if (kept) return 'end_companion';
        return 'end_hollow';
      default:
        if (kept && merciful) return 'end_companion';
        if (run.flag('knows_loop') && run.pages.length >= 3) return 'end_loop';
        return 'end_free';
    }
  }

  /// The four choices offered at the very top, gated by what the run earned.
  List<EvChoice> finaleChoices() => [
        const EvChoice(
          label: 'Take the pen.',
          result: '',
          out: [Out(OutKind.flag, arg: 'chose_pen')],
          hint: 'Become the next Author.',
        ),
        const EvChoice(
          label: 'Break the pen.',
          result: '',
          out: [Out(OutKind.flag, arg: 'chose_break')],
          hint: 'End every draft, permanently.',
        ),
        EvChoice(
          label: 'Finish the story.',
          result: '',
          out: const [Out(OutKind.flag, arg: 'chose_finish')],
          hint: run.pages.length >= 5
              ? 'Read the eleventh ending aloud. (${run.pages.length}/9 pages)'
              : 'You do not have enough of the original. (${run.pages.length}/9 pages)',
        ),
        const EvChoice(
          label: 'Walk out through the door nobody drew.',
          result: '',
          out: [Out(OutKind.flag, arg: 'chose_walk')],
          hint: 'Leave the page entirely.',
        ),
      ];
}
