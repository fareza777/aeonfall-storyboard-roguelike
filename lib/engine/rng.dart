/// Deterministic, seedable RNG. Every run is reproducible from its seed, and
/// each subsystem draws from its own stream so adding content to one system
/// never reshuffles another.
class Rng {
  Rng(this.seed) : _s = seed == 0 ? 0x9E3779B9 : seed;

  final int seed;
  int _s;

  int _next() {
    // xorshift32 — small, fast, good enough for game content
    _s ^= (_s << 13) & 0xFFFFFFFF;
    _s ^= _s >> 17;
    _s ^= (_s << 5) & 0xFFFFFFFF;
    _s &= 0xFFFFFFFF;
    return _s;
  }

  /// A fresh independent stream derived from this one.
  Rng fork(String tag) {
    var h = seed;
    for (final c in tag.codeUnits) {
      h = ((h * 31) + c) & 0xFFFFFFFF;
    }
    return Rng(h ^ 0x5BF03635);
  }

  int nextInt(int max) => max <= 0 ? 0 : _next() % max;
  int range(int a, int b) => a + nextInt(b - a + 1);
  double nextDouble() => _next() / 0xFFFFFFFF;
  bool chance(double p) => nextDouble() < p;

  T pick<T>(List<T> list) => list[nextInt(list.length)];

  List<T> shuffled<T>(List<T> list) {
    final out = List<T>.from(list);
    for (var i = out.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final t = out[i];
      out[i] = out[j];
      out[j] = t;
    }
    return out;
  }

  /// Take [n] distinct entries.
  List<T> sample<T>(List<T> list, int n) {
    if (n >= list.length) return shuffled(list);
    return shuffled(list).take(n).toList();
  }

  /// Weighted pick. [weight] must return a non-negative value.
  T weighted<T>(List<T> list, int Function(T) weight) {
    var total = 0;
    for (final x in list) {
      total += weight(x);
    }
    if (total <= 0) return pick(list);
    var roll = nextInt(total);
    for (final x in list) {
      roll -= weight(x);
      if (roll < 0) return x;
    }
    return list.last;
  }
}

/// Human-friendly seed words so players can share a run.
const _seedWords = [
  'ASH', 'BELL', 'CINDER', 'DUSK', 'EMBER', 'FROST', 'GRAVE', 'HOLLOW',
  'INK', 'JADE', 'KILN', 'LUMEN', 'MARROW', 'NULL', 'OSSUARY', 'PYRE',
  'QUILL', 'RIME', 'STORM', 'THORN', 'UMBRA', 'VAULT', 'WRAITH', 'ZENITH',
];

String seedToWords(int seed) {
  final a = _seedWords[(seed >> 16) % _seedWords.length];
  final b = _seedWords[(seed >> 8) % _seedWords.length];
  final c = (seed % 1000).toString().padLeft(3, '0');
  return '$a-$b-$c';
}
