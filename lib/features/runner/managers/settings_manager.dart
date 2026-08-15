import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/audio/audio_manager.dart';
import '../../../core/constants/game_constants.dart';
import '../models/settings_model.dart';

class SettingsManager extends ChangeNotifier {
  static const _musicKey = '${GameConstants.prefsPrefix}music_enabled';
  static const _soundKey = '${GameConstants.prefsPrefix}sound_enabled';
  static const _vibrationKey = '${GameConstants.prefsPrefix}vibration_enabled';
  static const _controlKey = '${GameConstants.prefsPrefix}control_type';

  SettingsModel _settings = SettingsModel();

  SettingsModel get settings => _settings;
  bool get musicEnabled => _settings.musicEnabled;
  bool get soundEnabled => _settings.soundEnabled;
  bool get vibrationEnabled => _settings.vibrationEnabled;
  ControlType get controlType => _settings.controlType;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _settings = SettingsModel(
        musicEnabled: prefs.getBool(_musicKey) ?? true,
        soundEnabled: prefs.getBool(_soundKey) ?? true,
        vibrationEnabled: prefs.getBool(_vibrationKey) ?? true,
        controlType: (prefs.getString(_controlKey) == 'buttons')
            ? ControlType.buttons
            : ControlType.swipe,
      );
      notifyListeners();
    } catch (_) {
      // Keep defaults.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_musicKey, _settings.musicEnabled);
      await prefs.setBool(_soundKey, _settings.soundEnabled);
      await prefs.setBool(_vibrationKey, _settings.vibrationEnabled);
      await prefs.setString(
        _controlKey,
        _settings.controlType == ControlType.buttons ? 'buttons' : 'swipe',
      );
    } catch (_) {}
  }

  Future<void> setMusicEnabled(bool value) async {
    _settings = _settings.copyWith(musicEnabled: value);
    await AudioManager.instance.setMusicEnabled(value);
    notifyListeners();
    await _persist();
  }

  Future<void> setSoundEnabled(bool value) async {
    _settings = _settings.copyWith(soundEnabled: value);
    AudioManager.instance.setSfxEnabled(value);
    notifyListeners();
    await _persist();
  }

  Future<void> setVibrationEnabled(bool value) async {
    _settings = _settings.copyWith(vibrationEnabled: value);
    notifyListeners();
    await _persist();
  }

  Future<void> setControlType(ControlType type) async {
    _settings = _settings.copyWith(controlType: type);
    notifyListeners();
    await _persist();
  }
}
