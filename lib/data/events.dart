import 'narrative_model.dart';
import 'events_a.dart';
import 'events_b.dart';
import 'events_c.dart';
import 'events_d.dart';
import 'events_e.dart';

const kAllEvents = <GameEvent>[
  ...kEventsA,
  ...kEventsB,
  ...kEventsC,
  ...kEventsD,
  ...kEventsE,
];

GameEvent eventById(String id) =>
    kAllEvents.firstWhere((e) => e.id == id, orElse: () => kAllEvents.first);
