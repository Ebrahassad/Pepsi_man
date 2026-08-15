import '../../../core/constants/game_constants.dart';

enum PowerUpType { magnet, shield, speedBoost, invincibility }

class PowerUpModel {
  final PowerUpType type;
  final String assetPath;
  final double durationSeconds;

  const PowerUpModel({
    required this.type,
    required this.assetPath,
    required this.durationSeconds,
  });

  static double defaultDuration(PowerUpType type) {
    switch (type) {
      case PowerUpType.magnet:
        return GameConstants.magnetDuration;
      case PowerUpType.shield:
        return 0; // Shield is hit-based, not time-based.
      case PowerUpType.speedBoost:
        return GameConstants.speedBoostDuration;
      case PowerUpType.invincibility:
        return GameConstants.invincibilityDuration;
    }
  }
}

/// Tracks an active power-up's remaining time (or remaining hits, for Shield).
class ActivePowerUp {
  final PowerUpType type;
  double remainingSeconds;
  int remainingHits;

  ActivePowerUp({
    required this.type,
    this.remainingSeconds = 0,
    this.remainingHits = 0,
  });

  bool get isActive => remainingSeconds > 0 || remainingHits > 0;
}
