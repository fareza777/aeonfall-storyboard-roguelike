import 'package:aeonfall/data/cards.dart';
import 'package:aeonfall/data/chronicles.dart';
import 'package:aeonfall/data/companions.dart';
import 'package:aeonfall/data/enemies.dart';
import 'package:aeonfall/data/endings.dart';
import 'package:aeonfall/data/events.dart';
import 'package:aeonfall/data/narrative_model.dart';
import 'package:aeonfall/data/relics.dart';
import 'package:aeonfall/data/vessels.dart';
import 'package:aeonfall/engine/core.dart';
import 'package:aeonfall/engine/director.dart';
import 'package:aeonfall/engine/map_gen.dart';
import 'package:aeonfall/engine/rng.dart';
import 'package:aeonfall/engine/run_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// Not a pass/fail test — a content census, so design decisions are made
/// against real numbers.
void main() {
  test('content census', () {
    void say(String s) => print(s); // ignore: avoid_print

    say('=== CONTENT ===');
    say('vessels           ${kVessels.length}');
    for (final v in kVessels) {
      final own = kAllCards.where((c) => c.vessel == v.id).length;
      say('  ${v.id.padRight(14)} cards $own');
    }
    say('neutral cards     ${kAllCards.where((c) => c.vessel == 'neutral').length}');
    say('curse/status      '
        '${kAllCards.where((c) => c.vessel == 'curse' || c.vessel == 'status').length}');
    say('total cards       ${kAllCards.length}');
    say('relics            ${kRelics.length} (+${kStarterRelics.length} starters)');
    for (final r in Rarity.values) {
      final n = kRelics.where((x) => x.rarity == r).length;
      if (n > 0) say('  ${r.name.padRight(10)} $n');
    }

    say('');
    say('=== FOES ===');
    for (var act = 1; act <= 3; act++) {
      say('act $act  normal ${normalPool(act).length}'
          '  elite ${elitePool(act).length}'
          '  boss ${bossPool(act).length}');
    }

    say('');
    say('=== NARRATIVE ===');
    say('chronicles        ${kChronicles.length}');
    say('companions        ${kCompanions.length}');
    say('endings           ${kEndings.length}');
    say('wandering events  ${kAllEvents.length}');
    final pageSources = kAllEvents
        .expand((e) => e.choices)
        .expand((c) => c.out)
        .where((o) => o.kind == OutKind.page)
        .length;
    say('page sources      $pageSources  (need 5 of 9 for the true ending)');
    final hidden =
        kAllEvents.expand((e) => e.choices).where((c) => c.hidden).length;
    say('hidden choices    $hidden');

    say('');
    say('=== A SINGLE RUN CONSUMES ===');
    final map = generateMap(Rng(7), 1);
    final types = <NodeType, int>{};
    for (final n in map.nodes) {
      types[n.type] = (types[n.type] ?? 0) + 1;
    }
    say('act nodes generated ${map.nodes.length} across ${map.layers} layers');
    say('  $types');
    say('layers walked per act ~${map.layers}');
    say('so ~${map.layers * 3} nodes per full run, vs '
        '${kAllEvents.length} authored events');

    say('');
    say('=== BALANCE PROBE (random bot) ===');
    var wins = 0, battles = 0;
    for (var seed = 1; seed <= 40; seed++) {
      final run = Director.newRun(seed * 31, kVessels[seed % 3].id, MetaState());
      final d = Director(run);
      for (final t in [NodeType.battle, NodeType.elite, NodeType.boss]) {
        final foes = d.encounter(t);
        battles++;
        // crude proxy: total foe HP vs the deck's raw damage per turn
        final hp = foes.fold(0, (s, f) => s + f.hp);
        final dmg = run.deck
            .map((c) => c.fx
                .where((x) => x.kind == FxKind.damage || x.kind == FxKind.damageAll)
                .fold(0, (s, x) => s + x.value * x.times))
            .fold(0, (s, x) => s + x);
        if (dmg > hp) wins++;
      }
    }
    say('encounters sampled $battles, deck-damage>foe-HP in $wins');
  });
}
