import 'package:audioplayers/audioplayers.dart';

/// Central audio system. All calls are wrapped so a missing asset file
/// never crashes the app — it just fails silently (silent fallback).
class AudioManager {
  AudioManager._internal();
  static final AudioManager instance = AudioManager._internal();
  factory AudioManager() => instance;

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool musicEnabled = true;
  bool sfxEnabled = true;
  double musicVolume = 0.6;
  double sfxVolume = 0.8;

  String? _currentMusicPath;

  static const String _musicDir = 'audio/music';
  static const String _sfxDir = 'audio/sfx';

  Future<void> init() async {
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (_) {
      // Non-fatal — music simply won't loop if this fails.
    }
  }

  Future<void> playMusic(String fileName) async {
    if (!musicEnabled) return;
    final path = '$_musicDir/$fileName';
    if (_currentMusicPath == path) return;
    _currentMusicPath = path;
    try {
      await _musicPlayer.stop();
      await _musicPlayer.setVolume(musicVolume);
      await _musicPlayer.play(AssetSource(path));
    } catch (_) {
      // Missing/corrupt music file — fail silently, gameplay continues.
    }
  }

  Future<void> stopMusic() async {
    _currentMusicPath = null;
    try {
      await _musicPlayer.stop();
    } catch (_) {}
  }

  Future<void> pauseMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (_) {}
  }

  Future<void> resumeMusic() async {
    if (!musicEnabled) return;
    try {
      await _musicPlayer.resume();
    } catch (_) {}
  }

  Future<void> playSfx(String fileName) async {
    if (!sfxEnabled) return;
    final path = '$_sfxDir/$fileName';
    try {
      final player = AudioPlayer();
      await player.setVolume(sfxVolume);
      await player.play(AssetSource(path));
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (_) {
      // Missing/corrupt SFX file — fail silently.
    }
  }

  Future<void> setMusicEnabled(bool value) async {
    musicEnabled = value;
    if (!value) {
      await stopMusic();
    }
  }

  void setSfxEnabled(bool value) {
    sfxEnabled = value;
  }

  Future<void> setMusicVolume(double value) async {
    musicVolume = value;
    try {
      await _musicPlayer.setVolume(value);
    } catch (_) {}
  }

  void setSfxVolume(double value) {
    sfxVolume = value;
  }

  // Convenience shortcuts for common SFX (matches AUDIO_MANIFEST.md)
  Future<void> playButtonClick() => playSfx('button_click.mp3');
  Future<void> playCanCollect() => playSfx('can_collect.mp3');
  Future<void> playCoinCollect() => playSfx('coin_collect.mp3');
  Future<void> playJump() => playSfx('jump.mp3');
  Future<void> playSlide() => playSfx('slide.mp3');
  Future<void> playPlayerHit() => playSfx('player_hit.mp3');
  Future<void> playShieldBreak() => playSfx('shield_break.mp3');
  Future<void> playMagnetActivate() => playSfx('magnet_activate.mp3');
  Future<void> playSpeedBoost() => playSfx('speed_boost.mp3');
  Future<void> playInvincibility() => playSfx('invincibility.mp3');
  Future<void> playCheckpoint() => playSfx('checkpoint.mp3');
  Future<void> playLevelStart() => playSfx('level_start.mp3');
  Future<void> playLevelComplete() => playSfx('level_complete.mp3');
  Future<void> playGameOver() => playSfx('game_over.mp3');

  Future<void> dispose() async {
    try {
      await _musicPlayer.dispose();
      await _sfxPlayer.dispose();
    } catch (_) {}
  }
}
