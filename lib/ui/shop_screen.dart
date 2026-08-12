import 'package:flutter/material.dart';

import '../audio.dart';
import '../data/potions.dart';
import '../engine/core.dart';
import '../engine/run_state.dart';
import '../game.dart';
import '../theme.dart';
import 'run_hud.dart';
import 'widgets.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key, required this.nodeId});
  final int nodeId;

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late final List<CardDef> _stock = Game.i.director!.shopStock();
  late final Map<String, int> _prices = {
    for (final c in _stock) c.id: Game.i.director!.cardPrice(c)
  };
  late final RelicDef _relic = Game.i.director!.relicReward();
  late final int _relicPrice = 180 + Game.i.run!.act * 60;
  late final List<PotionDef> _potions = Game.i.director!.potionStock();
  late final Map<String, int> _potionPrices = {
    for (final p in _potions) p.id: Game.i.director!.potionPrice(p)
  };
  final Set<String> _potionsSold = {};
  final Set<String> _sold = {};
  bool _relicSold = false;
  bool _removed = false;

  int get _removalCost {
    final r = Game.i.run!;
    if (r.relics.contains('scribes_thumb') && !r.flag('freeremove_${r.act}')) return 0;
    return 80 + r.act * 20;
  }

  @override
  void initState() {
    super.initState();
    Audio.i.music('map');
  }

  void _buyCard(CardDef c) {
    final r = Game.i.run!;
    final p = _prices[c.id]!;
    if (r.gold < p || _sold.contains(c.id)) return;
    Audio.i.sfx('coin');
    setState(() {
      r.gold -= p;
      r.addCard(c.id);
      _sold.add(c.id);
    });
    Game.i.saveRun();
  }

  void _buyRelic() {
    final r = Game.i.run!;
    if (r.gold < _relicPrice || _relicSold) return;
    Audio.i.sfx('relic');
    setState(() {
      r.gold -= _relicPrice;
      r.addRelic(_relic.id);
      _relicSold = true;
    });
    Game.i.saveRun();
  }

  void _remove() {
    final r = Game.i.run!;
    final cost = _removalCost;
    if (r.gold < cost || _removed) return;
    final removable = r.deck.where((c) => c.def.rarity != Rarity.starter).toList();
    final pool = removable.isEmpty ? r.deck : removable;
    Audio.i.sfx('draw', volume: .5);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * .78,
        decoration: const BoxDecoration(
          color: Ae.ink2,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          border: Border(top: BorderSide(color: Ae.blood, width: 2)),
        ),
        child: Column(children: [
          const SizedBox(height: 14),
          Text('BURN A FRAME', style: Ae.display(21)),
          const SizedBox(height: 4),
          Text('It will not be in the next draft either.',
              style: Ae.body(15, c: Ae.dim)),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(14),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1 / 1.52,
              ),
              itemCount: pool.length,
              itemBuilder: (_, i) => FrameCard(
                card: pool[i],
                width: 108,
                onTap: () {
                  Audio.i.sfx('ember');
                  r.gold -= cost;
                  if (cost == 0) r.setFlag('freeremove_${r.act}');
                  r.deck.remove(pool[i]);
                  Game.i.saveRun();
                  Navigator.pop(context);
                  setState(() => _removed = true);
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _potionShelf(RunState r) => Row(
        children: [
          for (final p in _potions)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _potionTile(r, p),
              ),
            ),
        ],
      );

  Widget _potionTile(RunState r, PotionDef p) {
    final price = _potionPrices[p.id]!;
    final sold = _potionsSold.contains(p.id);
    final c = p.elem == Elem.none ? Ae.gold : p.elem.color;
    final afford = r.gold >= price && !r.beltFull;
    return GestureDetector(
      onTap: sold ? null : () => _buyPotion(p),
      child: Opacity(
        opacity: sold ? .4 : 1,
        child: AePanel(
          border: sold ? Ae.panelHi : (afford ? c : Ae.panelHi),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(p.elem == Elem.none ? '◈' : p.elem.glyph,
                  style: TextStyle(fontSize: 24, color: c, height: 1.1)),
              const SizedBox(height: 6),
              Text(p.name.toUpperCase(),
                  textAlign: TextAlign.center, maxLines: 2, style: Ae.label(10.5)),
              const SizedBox(height: 6),
              Text(sold ? 'SOLD' : '◈ $price',
                  style: Ae.body(14,
                      w: 800, c: sold ? Ae.dim : (afford ? Ae.gold : Ae.blood))),
            ],
          ),
        ),
      ),
    );
  }

  void _buyPotion(PotionDef p) {
    final r = Game.i.run!;
    final price = _potionPrices[p.id]!;
    if (r.gold < price || _potionsSold.contains(p.id)) return;
    if (r.beltFull) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Ae.ink2,
        content: Text('Your belt is full. Drink one first.', style: Ae.body(15)),
      ));
      return;
    }
    Audio.i.sfx('coin');
    setState(() {
      r.gold -= price;
      r.addPotion(p.id);
      _potionsSold.add(p.id);
    });
    Game.i.saveRun();
  }

  @override
  Widget build(BuildContext context) {
    final r = Game.i.run!;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Column(
          children: [
            RunHud(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(children: [
                      SizedBox(height: 180, width: double.infinity, child: Art('site_shopkeep')),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Ae.ink],
                              stops: const [.3, 1],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        bottom: 10,
                        right: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('THE MARKET', style: Ae.display(24)),
                            Text('"Everything here was somebody\'s. That is the discount."',
                                style: Ae.body(14, c: Ae.dim)),
                          ],
                        ),
                      ),
                    ]),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('FRAMES', style: Ae.label(14)),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 262,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _stock.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 10),
                              itemBuilder: (_, i) {
                                final c = _stock[i];
                                final p = _prices[c.id]!;
                                final sold = _sold.contains(c.id);
                                return Column(
                                  children: [
                                    FrameCard(
                                      card: CardInst(c),
                                      width: 136,
                                      playable: !sold && r.gold >= p,
                                      onTap: () => _buyCard(c),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(sold ? 'SOLD' : '◈ $p',
                                        style: Ae.body(16,
                                            w: 800,
                                            c: sold
                                                ? Ae.dim
                                                : (r.gold >= p ? Ae.gold : Ae.blood))),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text('DRAUGHTS', style: Ae.label(14)),
                          const SizedBox(height: 10),
                          _potionShelf(r),
                          const SizedBox(height: 20),
                          Text('SIGIL', style: Ae.label(14)),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: _buyRelic,
                            child: AePanel(
                              border: _relicSold ? Ae.panelHi : _relic.rarity.color,
                              child: Row(children: [
                                SizedBox(width: 54, height: 54, child: Art(_relic.artKey())),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_relic.name.toUpperCase(),
                                          style: Ae.label(15,
                                              c: _relicSold ? Ae.dim : Ae.bone)),
                                      const SizedBox(height: 4),
                                      Text(_relic.desc, style: Ae.body(15, c: Ae.dim)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(_relicSold ? 'SOLD' : '◈ $_relicPrice',
                                    style: Ae.body(16,
                                        w: 800,
                                        c: _relicSold
                                            ? Ae.dim
                                            : (r.gold >= _relicPrice ? Ae.gold : Ae.blood))),
                              ]),
                            ),
                          ),
                          const SizedBox(height: 20),
                          AeButton(
                            label: _removed ? 'The brazier is cold' : 'Burn a Frame',
                            sub: _removed
                                ? null
                                : (_removalCost == 0
                                    ? 'Free — Scribe\'s Thumb'
                                    : '◈ $_removalCost · remove a card from your deck'),
                            color: Ae.blood,
                            enabled: !_removed && r.gold >= _removalCost,
                            onTap: _remove,
                          ),
                          const SizedBox(height: 24),
                          AeButton(
                            label: 'Leave the market',
                            big: true,
                            onTap: () {
                              Audio.i.sfx('tap');
                              Game.i.completeNode(widget.nodeId);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
