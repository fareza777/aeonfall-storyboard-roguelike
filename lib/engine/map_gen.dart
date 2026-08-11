import 'rng.dart';

enum NodeType { battle, elite, event, shop, rest, treasure, mystery, boss, beat }

extension NodeTypeX on NodeType {
  String get label => switch (this) {
        NodeType.battle => 'BATTLE',
        NodeType.elite => 'ELITE',
        NodeType.event => 'EVENT',
        NodeType.shop => 'MARKET',
        NodeType.rest => 'RESPITE',
        NodeType.treasure => 'CACHE',
        NodeType.mystery => 'UNKNOWN',
        NodeType.boss => 'BOSS',
        NodeType.beat => 'STORY',
      };

  String get icon => switch (this) {
        NodeType.battle => 'node_battle',
        NodeType.elite => 'node_elite',
        NodeType.event => 'node_event',
        NodeType.shop => 'node_shop',
        NodeType.rest => 'node_rest',
        NodeType.treasure => 'node_treasure',
        NodeType.mystery => 'node_mystery',
        NodeType.boss => 'node_boss',
        NodeType.beat => 'node_event',
      };
}

class MapNode {
  MapNode(this.id, this.layer, this.col, this.type);
  final int id;
  final int layer;
  final int col;
  NodeType type;
  final List<int> next = [];
  bool visited = false;

  Map<String, dynamic> toJson() => {
        'i': id,
        'l': layer,
        'c': col,
        't': type.index,
        'n': next,
        'v': visited,
      };

  static MapNode fromJson(Map<String, dynamic> j) {
    final n = MapNode(j['i'], j['l'], j['c'], NodeType.values[j['t']]);
    n.next.addAll(List<int>.from(j['n']));
    n.visited = j['v'] == true;
    return n;
  }
}

/// The branching storyboard for one Act.
class StoryMap {
  StoryMap(this.act, this.layers, this.nodes);

  final int act;
  final int layers;
  final List<MapNode> nodes;
  int currentId = -1;
  List<int> available = [];

  MapNode byId(int id) => nodes.firstWhere((n) => n.id == id);
  List<MapNode> atLayer(int l) => nodes.where((n) => n.layer == l).toList();
  int get width => nodes.fold(0, (m, n) => n.col > m ? n.col : m) + 1;

  Map<String, dynamic> toJson() => {
        'act': act,
        'layers': layers,
        'nodes': nodes.map((n) => n.toJson()).toList(),
        'cur': currentId,
        'avail': available,
      };

  static StoryMap fromJson(Map<String, dynamic> j) {
    final m = StoryMap(j['act'], j['layers'],
        (j['nodes'] as List).map((e) => MapNode.fromJson(e)).toList());
    m.currentId = j['cur'];
    m.available = List<int>.from(j['avail']);
    return m;
  }
}

const _layerCount = 15;
const _mapWidth = 4;

/// Builds one Act's branching map. Layout, node mix and path count all vary
/// with the seed, so no two Acts read the same.
StoryMap generateMap(Rng seed, int act) {
  final rng = seed.fork('map-$act');
  const layers = _layerCount;
  final grid = <String, MapNode>{};
  var nextId = 0;

  MapNode nodeAt(int l, int col) => grid.putIfAbsent(
      '$l:$col', () => MapNode(nextId++, l, col, NodeType.battle));

  // Random-walk several routes from the bottom to the boss.
  final routes = rng.range(4, 6);
  final entries = <int>{};
  for (var r = 0; r < routes; r++) {
    var col = rng.nextInt(_mapWidth);
    var node = nodeAt(0, col);
    entries.add(node.id);
    for (var l = 1; l < layers - 1; l++) {
      final shift = rng.nextInt(3) - 1;
      col = (col + shift).clamp(0, _mapWidth - 1);
      final nxt = nodeAt(l, col);
      if (!node.next.contains(nxt.id)) node.next.add(nxt.id);
      node = nxt;
    }
  }

  // Everything funnels into the boss.
  final boss = nodeAt(layers - 1, _mapWidth ~/ 2);
  boss.type = NodeType.boss;
  for (final n in grid.values.where((n) => n.layer == layers - 2)) {
    if (!n.next.contains(boss.id)) n.next.add(boss.id);
  }

  // Assign node types with a layer-aware mix.
  for (final n in grid.values) {
    if (n.layer == layers - 1) continue;
    n.type = _pickType(rng, n.layer, act);
  }
  // Guaranteed beats so every Act has structure.
  _force(grid, 0, NodeType.battle);
  _force(grid, 4, NodeType.treasure);
  _force(grid, 7, NodeType.beat);
  _force(grid, 9, NodeType.rest);
  _force(grid, layers - 2, NodeType.rest);
  _force(grid, layers - 3, NodeType.shop);

  final map = StoryMap(act, layers, grid.values.toList()..sort((a, b) => a.id - b.id));
  map.available = entries.toList()..sort();
  return map;
}

void _force(Map<String, MapNode> grid, int layer, NodeType t) {
  for (final n in grid.values.where((n) => n.layer == layer)) {
    n.type = t;
  }
}

NodeType _pickType(Rng rng, int layer, int act) {
  // Elites only appear once the player has had a chance to build.
  final canElite = layer >= 5;
  final pool = <NodeType, int>{
    NodeType.battle: 46,
    NodeType.event: 24,
    NodeType.mystery: 10,
    NodeType.shop: layer >= 3 ? 7 : 0,
    NodeType.rest: layer >= 5 ? 8 : 0,
    NodeType.elite: canElite ? 12 + act * 3 : 0,
    NodeType.treasure: 5,
  };
  final keys = pool.keys.toList();
  return rng.weighted(keys, (k) => pool[k]!);
}
