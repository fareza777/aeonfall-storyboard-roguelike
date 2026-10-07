/// A node's immutable offers and durable claim state. The benefit and its
/// claim flag are written in the same RunState snapshot, never in widget state.
class PendingReward {
  PendingReward({
    required this.act,
    required this.nodeId,
    required this.gold,
    required this.title,
    required this.blurb,
    required this.art,
    this.relic = false,
    this.cards = false,
    this.isBoss = false,
    List<String> cardIds = const [],
    this.relicId,
    this.potionId,
    this.extraRelicId,
  }) : cardIds = List.unmodifiable(cardIds);

  final int act;
  final int nodeId;
  final int gold;
  final String title;
  final String blurb;
  final String art;
  final bool relic;
  final bool cards;
  final bool isBoss;
  final List<String> cardIds;
  final String? relicId;
  final String? potionId;
  final String? extraRelicId;

  bool goldTaken = false;
  bool relicTaken = false;
  bool cardTaken = false;
  bool potionTaken = false;
  bool extraTaken = false;
  bool bonusTaken = false;
  bool resolved = false;

  Map<String, dynamic> toJson() => {
    'act': act,
    'nodeId': nodeId,
    'gold': gold,
    'title': title,
    'blurb': blurb,
    'art': art,
    'relic': relic,
    'cards': cards,
    'isBoss': isBoss,
    'cardIds': cardIds,
    'relicId': relicId,
    'potionId': potionId,
    'extraRelicId': extraRelicId,
    'goldTaken': goldTaken,
    'relicTaken': relicTaken,
    'cardTaken': cardTaken,
    'potionTaken': potionTaken,
    'extraTaken': extraTaken,
    'bonusTaken': bonusTaken,
    'resolved': resolved,
  };

  static PendingReward fromJson(Map<String, dynamic> j) =>
      PendingReward(
          act: j['act'] as int,
          nodeId: j['nodeId'] as int,
          gold: j['gold'] as int,
          title: j['title'] as String,
          blurb: j['blurb'] as String,
          art: j['art'] as String,
          relic: j['relic'] == true,
          cards: j['cards'] == true,
          isBoss: j['isBoss'] == true,
          cardIds: List<String>.from(j['cardIds'] ?? []),
          relicId: j['relicId'] as String?,
          potionId: j['potionId'] as String?,
          extraRelicId: j['extraRelicId'] as String?,
        )
        ..goldTaken = j['goldTaken'] == true
        ..relicTaken = j['relicTaken'] == true
        ..cardTaken = j['cardTaken'] == true
        ..potionTaken = j['potionTaken'] == true
        ..extraTaken = j['extraTaken'] == true
        ..bonusTaken = j['bonusTaken'] == true
        ..resolved = j['resolved'] == true;
}
