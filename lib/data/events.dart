import 'narrative_model.dart';
import 'events_a.dart';
import 'events_b.dart';

const kAllEvents = <GameEvent>[...kEventsA, ...kEventsB];

GameEvent eventById(String id) =>
    kAllEvents.firstWhere((e) => e.id == id, orElse: () => kAllEvents.first);
