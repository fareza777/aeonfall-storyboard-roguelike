import '../engine/core.dart';
import 'cards_ember_frost.dart';
import 'cards_lumen_paradox.dart';
import 'cards_neutral.dart';
import 'cards_volt_umbra.dart';

final List<CardDef> kAllCards = [
  ...kEmberCards,
  ...kFrostCards,
  ...kVoltCards,
  ...kUmbraCards,
  ...kLumenCards,
  ...kParadoxCards,
  ...kNeutralCards,
  ...kCurseCards,
  ...kStatusCards,
];

final Map<String, CardDef> kCardById = {for (final c in kAllCards) c.id: c};

CardDef cardDef(String id) => kCardById[id] ?? kNeutralCards.first;

/// Everything a Vessel can be offered as a reward.
List<CardDef> rewardPoolFor(String vesselId) => kAllCards
    .where((c) =>
        (c.vessel == vesselId || c.vessel == 'neutral') &&
        c.rarity != Rarity.starter &&
        c.rarity != Rarity.curse)
    .toList();

final List<CardDef> kCursePool =
    kCurseCards.where((c) => c.rarity == Rarity.curse).toList();

/// How often each tier is offered, by act.
///
/// The old curve handed out a rare in roughly one offer in seven from Act I
/// onwards and a mythic could show up on the first floor, which flattened the
/// whole reward arc — the best cards were simply available. Rares are now
/// scarce early and become the reason to go deep, and mythics do not exist
/// before Act II at all.
int rarityWeight(Rarity r, int act) => switch (r) {
      Rarity.common => switch (act) { 1 => 74, 2 => 64, _ => 56 },
      Rarity.uncommon => switch (act) { 1 => 23, 2 => 29, _ => 32 },
      Rarity.rare => switch (act) { 1 => 3, 2 => 7, _ => 11 },
      Rarity.mythic => switch (act) { 1 => 0, 2 => 1, _ => 3 },
      _ => 0,
    };
