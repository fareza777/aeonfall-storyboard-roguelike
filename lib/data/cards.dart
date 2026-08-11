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

int rarityWeight(Rarity r, int act) => switch (r) {
      Rarity.common => 62,
      Rarity.uncommon => 30 + act * 2,
      Rarity.rare => 7 + act * 3,
      Rarity.mythic => act >= 2 ? 3 : 1,
      _ => 0,
    };
