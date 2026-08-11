import 'package:audioplayers/audioplayers.dart';

/// Music bed + a small pool of one-shot players so overlapping hits don't cut
/// each other off. Every call is fire-and-forget and never throws into the UI.
class Audio {
  static final Audio i = Audio._();
  Audio._();

  final AudioPlayer _music = AudioPlayer(playerId: 'aeon_music');
  final AudioPlayer _voice = AudioPlayer(playerId: 'aeon_voice');
  final List<AudioPlayer> _pool =
      List.generate(6, (n) => AudioPlayer(playerId: 'aeon_sfx_$n'));
  int _next = 0;

  bool musicOn = true;
  bool sfxOn = true;
  String? _current;
  bool _backgrounded = false;

  Future<void> init() async {
    try {
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(.45);
      await _voice.setReleaseMode(ReleaseMode.stop);
      await _voice.setVolume(1.0);
      for (final p in _pool) {
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setVolume(.7);
      }
    } catch (_) {
      // Audio is a nicety, never a blocker.
    }
  }

  /// Narration. One shared player, so a new line always replaces the old one
  /// and nothing can be left running behind a screen that has been popped.
  Future<void> voice(String name) async {
    if (_backgrounded) return;
    try {
      await _voice.stop();
      await _voice.play(AssetSource('audio/vo_$name.mp3'));
    } catch (_) {}
  }

  Future<void> stopVoice() async {
    try {
      await _voice.stop();
    } catch (_) {}
  }

  /// Silence everything when the app leaves the foreground. Android does not
  /// stop media for us, so without this the soundtrack follows you out.
  Future<void> pauseAll() async {
    _backgrounded = true;
    try {
      await _music.pause();
    } catch (_) {}
    try {
      await _voice.pause();
    } catch (_) {}
    for (final p in _pool) {
      try {
        await p.stop();
      } catch (_) {}
    }
  }

  Future<void> resumeAll() async {
    _backgrounded = false;
    if (!musicOn) return;
    try {
      await _music.resume();
    } catch (_) {}
  }

  Future<void> music(String name) async {
    if (!musicOn || _backgrounded) return;
    if (_current == name) return;
    _current = name;
    try {
      await _music.stop();
      await _music.play(AssetSource('audio/mus_$name.mp3'));
    } catch (_) {
      _current = null;
    }
  }

  Future<void> stopMusic() async {
    _current = null;
    try {
      await _music.stop();
    } catch (_) {}
  }

  Future<void> setMusic(bool on) async {
    musicOn = on;
    if (!on) {
      await stopMusic();
    }
  }

  void sfx(String name, {double volume = .7}) {
    if (!sfxOn || _backgrounded) return;
    final p = _pool[_next];
    _next = (_next + 1) % _pool.length;
    p.setVolume(volume).then((_) {
      p.play(AssetSource('audio/sfx_$name.mp3')).catchError((_) {});
    }).catchError((_) {});
  }

  /// Maps a battle popup kind onto a sound.
  void forPopup(String kind) => switch (kind) {
        'damage' => sfx('hit_light', volume: .5),
        'block' => sfx('block', volume: .5),
        'heal' => sfx('heal', volume: .5),
        'reaction' => sfx('reaction', volume: .85),
        'cinematic' => sfx('cinematic', volume: .95),
        _ => sfx('tap', volume: .3),
      };
}
