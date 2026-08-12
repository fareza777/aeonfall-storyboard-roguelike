import '../engine/core.dart';

/// What a companion actually does when the fighting starts.
///
/// Recruiting one used to grant a passive perk and a sigil and then never
/// appear again until the ending — they were relics with faces. Each one now
/// has a single action you can call on once per battle, so the choice of who
/// walks with you is felt in the fight rather than only in the epilogue.
///
/// Deliberately once per battle and free: an Aid is a lever you pull when the
/// forecast says you are about to die, not a resource to optimise around.
class CompanionAid {
  const CompanionAid({
    required this.id,
    required this.name,
    required this.line,
    required this.desc,
    required this.fx,
  });

  final String id;

  /// What the button says.
  final String name;

  /// What they say when you call on them.
  final String line;
  final String desc;
  final List<Fx> fx;
}

const kCompanionAids = <String, CompanionAid>{
  'brann': CompanionAid(
    id: 'brann',
    name: 'HOLD THE LINE',
    line: '"Get behind me. That is the whole plan."',
    desc: 'Gain 20 Guard and Fortify.',
    fx: [
      Fx(FxKind.block, value: 20, target: FxTarget.self),
      Fx(FxKind.selfStatus, value: 1, arg: 'fortify', target: FxTarget.self),
    ],
  ),
  'lira': CompanionAid(
    id: 'lira',
    name: 'READ THE GROUND',
    line: '"Left. Now. Do not ask."',
    desc: 'Draw 3 frames and gain 1 Aether.',
    fx: [
      Fx(FxKind.draw, value: 3, target: FxTarget.self),
      Fx(FxKind.energy, value: 1, target: FxTarget.self),
    ],
  ),
  'mordwen': CompanionAid(
    id: 'mordwen',
    name: 'LAST RITES',
    line: '"Not today. I am not finished with you."',
    desc: 'Heal 30 and clear every condition on you.',
    fx: [
      Fx(FxKind.heal, value: 30, target: FxTarget.self),
      Fx(FxKind.cleanse, target: FxTarget.self),
    ],
  ),
  'vessa': CompanionAid(
    id: 'vessa',
    name: 'OPENING',
    line: '"There. Under the arm. Take it."',
    desc: 'Gain 4 Strength and apply Vulnerable 3 to every foe.',
    fx: [
      Fx(FxKind.selfStatus, value: 4, arg: 'strength', target: FxTarget.self),
      Fx(FxKind.statusAll, value: 3, arg: 'vulnerable', target: FxTarget.allEnemies),
    ],
  ),
  'tock': CompanionAid(
    id: 'tock',
    name: 'WIND IT BACK',
    line: '"One more. I can give you one more."',
    desc: 'Gain 3 Aether now and 1 at the start of next turn.',
    fx: [
      Fx(FxKind.energy, value: 3, target: FxTarget.self),
      Fx(FxKind.gainEnergyNextTurn, value: 1, target: FxTarget.self),
    ],
  ),
  'silvane': CompanionAid(
    id: 'silvane',
    name: 'FORESIGHT',
    line: '"The next two do not land. I have checked."',
    desc: 'Gain Ward 2 and Regen 6.',
    fx: [
      Fx(FxKind.selfStatus, value: 2, arg: 'ward', target: FxTarget.self),
      Fx(FxKind.selfStatus, value: 6, arg: 'regen', target: FxTarget.self),
    ],
  ),
  'harrow': CompanionAid(
    id: 'harrow',
    name: 'FINISH IT',
    line: '"You have been polite for long enough."',
    desc: 'Deal 26 damage to every foe, ignoring Guard.',
    fx: [Fx(FxKind.pierce, value: 26, target: FxTarget.allEnemies)],
  ),
  'nim': CompanionAid(
    id: 'nim',
    name: 'POCKETS',
    line: '"Borrowed. Obviously borrowed."',
    desc: 'Draw 2 frames, gain 60 Aeon and 8 Guard.',
    fx: [
      Fx(FxKind.draw, value: 2, target: FxTarget.self),
      Fx(FxKind.gainGold, value: 60, target: FxTarget.self),
      Fx(FxKind.block, value: 8, target: FxTarget.self),
    ],
  ),
  'calder': CompanionAid(
    id: 'calder',
    name: 'EARTH IT',
    line: '"Everything metal, put it down."',
    desc: 'Deal 16 Volt damage to every foe and Shock 3 all of them.',
    fx: [
      Fx(FxKind.damageAll, value: 16, target: FxTarget.allEnemies),
      Fx(FxKind.statusAll, value: 3, arg: 'shock', target: FxTarget.allEnemies),
    ],
  ),
  'orrin': CompanionAid(
    id: 'orrin',
    name: 'CROSS-REFERENCE',
    line: '"I have seen this exact fight. Page four-eleven."',
    desc: 'Upgrade every frame in your hand and draw 1.',
    fx: [
      Fx(FxKind.upgradeHand, target: FxTarget.self),
      Fx(FxKind.draw, value: 1, target: FxTarget.self),
    ],
  ),
  'thessa': CompanionAid(
    id: 'thessa',
    name: 'RIMEBLOOD',
    line: '"Cold does not argue. That is why I like it."',
    desc: 'Apply Rime 5 to every foe and gain 12 Guard.',
    fx: [
      Fx(FxKind.statusAll, value: 5, arg: 'rime', target: FxTarget.allEnemies),
      Fx(FxKind.block, value: 12, target: FxTarget.self),
    ],
  ),
  'the_stranger': CompanionAid(
    id: 'the_stranger',
    name: 'UNLISTED',
    line: '"I am not in this scene. Neither are you, for a moment."',
    desc: 'Gain Stealth and Echo 2.',
    fx: [
      Fx(FxKind.selfStatus, value: 1, arg: 'stealth', target: FxTarget.self),
      Fx(FxKind.selfStatus, value: 2, arg: 'echo', target: FxTarget.self),
    ],
  ),
};

CompanionAid? aidFor(String companionId) => kCompanionAids[companionId];
