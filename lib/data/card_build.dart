import '../engine/core.dart';

// Terse builders so the card tables stay readable.
Fx dmg(int v, {int times = 1, FxTarget t = FxTarget.enemy}) =>
    Fx(FxKind.damage, value: v, times: times, target: t);
Fx dmgAll(int v, {int times = 1}) =>
    Fx(FxKind.damageAll, value: v, times: times, target: FxTarget.allEnemies);
Fx pierce(int v, {FxTarget t = FxTarget.enemy}) => Fx(FxKind.pierce, value: v, target: t);
Fx blk(int v) => Fx(FxKind.block, value: v, target: FxTarget.self);
Fx heal(int v) => Fx(FxKind.heal, value: v, target: FxTarget.self);
Fx hurt(int v) => Fx(FxKind.loseHp, value: v, target: FxTarget.self);
Fx draw(int v) => Fx(FxKind.draw, value: v, target: FxTarget.self);
Fx nrg(int v) => Fx(FxKind.energy, value: v, target: FxTarget.self);
Fx st(String s, int v, {FxTarget t = FxTarget.enemy}) =>
    Fx(FxKind.status, value: v, arg: s, target: t);
Fx me(String s, int v) => Fx(FxKind.selfStatus, value: v, arg: s, target: FxTarget.self);
Fx stAll(String s, int v) => Fx(FxKind.statusAll, value: v, arg: s, target: FxTarget.allEnemies);
Fx aura(Elem e, {FxTarget t = FxTarget.enemy}) => Fx(FxKind.aura, arg: e.name, target: t);
Fx auraAll(Elem e) => Fx(FxKind.auraAll, arg: e.name, target: FxTarget.allEnemies);
Fx boom(String s, int mult, {FxTarget t = FxTarget.enemy}) =>
    Fx(FxKind.detonate, value: mult, arg: s, target: t);
Fx dmgPer(int base, String s, int per) =>
    Fx(FxKind.damageScaled, value: base, times: per, arg: s);
Fx dbl(String s) => Fx(FxKind.doubleStatus, arg: s);
Fx drain(int v) => Fx(FxKind.drainLife, value: v);
Fx addCard(String id, {int n = 1}) =>
    Fx(FxKind.addCard, value: n, arg: id, target: FxTarget.self);

CardDef c(
  String id,
  String name,
  Elem e,
  CardType t,
  int cost,
  Rarity r,
  String vessel,
  String art,
  String text,
  List<Fx> fx, {
  String? up,
  List<Fx>? fxUp,
  int? costUp,
  bool exhaust = false,
  bool innate = false,
  bool retain = false,
  bool unplayable = false,
  List<Fx>? handTick,
}) =>
    CardDef(
      id: id,
      name: name,
      elem: e,
      type: t,
      cost: cost,
      rarity: r,
      vessel: vessel,
      art: 'card_$art',
      text: text,
      fx: fx,
      textUp: up,
      fxUp: fxUp,
      costUp: costUp,
      exhaust: exhaust,
      innate: innate,
      retain: retain,
      unplayable: unplayable,
      handTick: handTick,
    );
