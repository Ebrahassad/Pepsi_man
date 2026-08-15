enum ControlType { swipe, buttons }

class SettingsModel {
  bool musicEnabled;
  bool soundEnabled;
  bool vibrationEnabled;
  ControlType controlType;

  SettingsModel({
    this.musicEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.controlType = ControlType.swipe,
  });

  SettingsModel copyWith({
    bool? musicEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    ControlType? controlType,
  }) {
    return SettingsModel(
      musicEnabled: musicEnabled ?? this.musicEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      controlType: controlType ?? this.controlType,
    );
  }
}
