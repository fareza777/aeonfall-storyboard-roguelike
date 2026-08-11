enum OutKind {
  gold,
  loseGold,
  hp, // lose HP
  heal,
  maxHp,
  card, // arg = card id
  randomCard,
  curse,
  relic, // arg = relic id, or null for random
  removeCard,
  upgradeCard,
  flag,
  page,
  companion, // arg = companion id, or null = the offered one
  loseCompanion,
  battle, // arg = enemy id override, or null = normal encounter
  eliteBattle,
  shards,
  mercy,
  cruelty,
  twist,
  nothing,
}

class Out {
  const Out(this.kind, {this.value = 0, this.arg});
  final OutKind kind;
  final int value;
  final String? arg;
}

class EvChoice {
  const EvChoice({
    required this.label,
    required this.result,
    this.out = const [],
    this.hint,
    this.needGold = 0,
    this.needFlag,
    this.needRelic,
    this.needPages = 0,
    this.hidden = false,
  });

  final String label;
  final String result;
  final List<Out> out;
  final String? hint;
  final int needGold;
  final String? needFlag;
  final String? needRelic;
  final int needPages;

  /// Only shown if the player carries a Witness Stone or a Hollow Key.
  final bool hidden;
}

class GameEvent {
  const GameEvent({
    required this.id,
    required this.title,
    required this.art,
    required this.body,
    required this.choices,
    this.act = 0,
    this.tag = 'common',
    this.weight = 10,
    this.once = true,
    this.requireFlag,
    this.forbidFlag,
    this.speaker,
    this.plain,
  });

  final String id;
  final String title;
  final String art;
  final String body;
  final List<EvChoice> choices;
  final int act;
  final String tag;
  final int weight;
  final bool once;
  final String? requireFlag;
  final String? forbidFlag;
  final String? speaker;

  /// A blunt restatement shown beneath the prose, for players who would rather
  /// be told plainly what just happened.
  final String? plain;
}

class Chronicle {
  const Chronicle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.art,
    required this.premise,
    required this.actOne,
    required this.actTwo,
    required this.actThree,
    required this.antagonist,
    required this.number,
  });

  final String id;
  final String title;
  final String subtitle;
  final String art;
  final String premise;
  final String actOne;
  final String actTwo;
  final String actThree;

  /// What this draft calls the thing at the top of the tower.
  final String antagonist;

  /// The draft number the player will eventually discover.
  final int number;
}

class Companion {
  const Companion({
    required this.id,
    required this.name,
    required this.title,
    required this.art,
    required this.recruit,
    required this.bond1,
    required this.bond2,
    required this.betrayal,
    required this.spared,
    required this.death,
    required this.gift,
    required this.perk,
    required this.perkDesc,
  });

  final String id;
  final String name;
  final String title;
  final String art;
  final String recruit;
  final String bond1;
  final String bond2;
  final String betrayal;
  final String spared;
  final String death;

  /// Relic granted when you recruit them.
  final String gift;
  final String perk;
  final String perkDesc;
}

class Ending {
  const Ending({
    required this.id,
    required this.title,
    required this.art,
    required this.body,
    required this.epitaph,
  });
  final String id;
  final String title;
  final String art;
  final String body;
  final String epitaph;
}
