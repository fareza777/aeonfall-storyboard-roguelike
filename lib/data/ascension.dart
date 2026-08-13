/// The twenty Ascensions.
///
/// This used to be a single line in the battle setup — enemy max HP scaled by
/// six percent per level — which meant every Ascension was the same run with
/// bigger numbers. These change the rules instead, one at a time, so a player
/// at Ascension 14 is playing a materially different game from one at 3.
///
/// Each tier is cumulative: reaching 12 means 1 through 12 are all in force.
class AscensionTier {
  const AscensionTier(this.level, this.title, this.desc);
  final int level;
  final String title;

  /// Written as a plain consequence, not a stat line, because the player has
  /// to be able to plan around it.
  final String desc;
}

const kAscensions = <AscensionTier>[
  AscensionTier(1, 'Sturdier Drafts',
      'Every foe carries 8% more health.'),
  AscensionTier(2, 'The Road Narrows',
      'Elites appear more often, and can turn up on layers that used to be safe.'),
  AscensionTier(3, 'Thin Rations',
      'Resting heals a third less than it used to.'),
  AscensionTier(4, 'A Word In The Margin',
      'You begin every run with a Curse shuffled into your deck.'),
  AscensionTier(5, 'Sturdier Still',
      'Foes carry a further 8% health, and elites hit noticeably harder.'),
  AscensionTier(6, 'Thinner Plate',
      'Every Guard you gain is a fifth smaller.'),
  AscensionTier(7, 'The Market Marks Up',
      'Everything in every shop costs a quarter more.'),
  AscensionTier(8, 'Second Wind',
      'Bosses stand back up once at a third of their health.'),
  AscensionTier(9, 'Sharper Edges',
      'Every foe deals 10% more damage.'),
  AscensionTier(10, 'A Longer Take',
      'Cinematics need four frames of one element in a turn, not three.'),
  AscensionTier(11, 'Fewer Second Chances',
      'You start each run with 12 less maximum health.'),
  AscensionTier(12, 'The Author Notices',
      'Every elite arrives already carrying one mutation.'),
  AscensionTier(13, 'Cold Open',
      'You draw four frames on the first turn of a fight instead of five.'),
  AscensionTier(14, 'Deeper Pockets Required',
      'Every kind of fight leaves a draught half as often.'),
  AscensionTier(15, 'Sturdier Yet',
      'Foes carry a further 10% health.'),
  AscensionTier(16, 'No Warm-Up',
      'The first fight of every act is an elite.'),
  AscensionTier(17, 'The Ink Runs Thin',
      'You gain 20% less Aeon from every source.'),
  AscensionTier(18, 'Both Hands',
      'Bosses take an extra action every fourth turn.'),
  AscensionTier(19, 'Nothing Is Free',
      'Every card reward offers two frames rather than three.'),
  AscensionTier(20, 'The Last Draft',
      'The final boss begins with 3 Strength and does not stop growing.'),
];

/// Everything the engine needs to know about a given Ascension, resolved once
/// so no call site has to remember which level does what.
class AscensionRules {
  const AscensionRules(this.level);
  final int level;

  bool at(int n) => level >= n;

  /// Multiplier on foe maximum health.
  double get foeHp {
    var m = 1.0;
    if (at(1)) m += .08;
    if (at(5)) m += .08;
    if (at(15)) m += .10;
    return m;
  }

  double get foeDamage => at(9) ? 1.10 : 1.0;
  double get restHealing => at(3) ? .67 : 1.0;
  double get shopPrices => at(7) ? 1.25 : 1.0;
  double get goldGain => at(17) ? .80 : 1.0;
  double get potionDropRate => at(14) ? .5 : 1.0;

  bool get startWithCurse => at(4);
  double get guardGain => at(6) ? .80 : 1.0;
  bool get bossesReviveOnce => at(8);
  bool get elitesAlwaysMutated => at(12);
  bool get firstFightIsElite => at(16);
  bool get bossesActTwice => at(18);
  bool get finalBossGrows => at(20);

  int get cinematicFrames => at(10) ? 4 : 3;
  int get startingMaxHpPenalty => at(11) ? 12 : 0;
  int get firstDraw => at(13) ? 4 : 5;
  int get cardRewardCount => at(19) ? 2 : 3;
  int get eliteWeightBonus => at(2) ? 3 : 0;

  /// Every rule currently in force, for the run-setup screen.
  List<AscensionTier> get active =>
      kAscensions.where((t) => t.level <= level).toList();
}
