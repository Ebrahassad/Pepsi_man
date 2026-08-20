/// Global, static gameplay constants shared across the app.
/// Nothing gameplay-tunable per level lives here — see `level_data.dart`
/// for per-level speed/difficulty values.
class GameConstants {
  GameConstants._();

  // ===========================================================================
  // APP
  // ===========================================================================

  static const String appName = 'Pepsi Runner';
  static const String prefsPrefix = 'pepsi_runner_';

  // ===========================================================================
  // LANES
  // ===========================================================================

  static const int laneLeft = 0;
  static const int laneCenter = 1;
  static const int laneRight = 2;

  static const double laneWidth = 120.0;

  // ===========================================================================
  // PHYSICS DEFAULTS
  // ===========================================================================

  static const double gravity = 2200.0;
  static const double jumpVelocity = -820.0;

  static const double groundY = 0.0;

  static const double slideDurationSeconds = 0.6;

  static const double laneSwitchDurationSeconds = 0.18;

  // ===========================================================================
  // SPEED
  // ===========================================================================

  // Reference gameplay speed.
  // The previous 110/260 values caused the 400m Level 1 track
  // to complete in only a few seconds.
  static const double defaultBaseSpeed = 12.0;

  static const double defaultMaxSpeed = 25.0;

  // Smooth acceleration from base speed toward max speed.
  static const double defaultAcceleration = 2.0;

  // ===========================================================================
  // TRACK PERSPECTIVE
  // ===========================================================================

  // t = 0.0 → distant road / horizon
  // t = 1.0 → runner / near camera

  static const double trackHorizonYFraction = 0.42;

  static const double trackGroundYFraction = 0.85;

  static const double trackTopLeftXFraction = 0.475;
  static const double trackTopRightXFraction = 0.525;

  static const double trackBottomLeftXFraction = 0.10;
  static const double trackBottomRightXFraction = 0.90;

  // ===========================================================================
  // PLAYER VISUAL CALIBRATION
  // ===========================================================================

  // Reference resolution: 1080x1920
  // Reference player: 110x180
  //
  // Height = 180 / 1920 = 0.09375
  // Width / Height = 110 / 180 = 0.611111...
  static const double runnerHeightFraction = 180.0 / 1920.0;

  static const double runnerWidthToHeight = 110.0 / 180.0;

  // ===========================================================================
  // VISUAL DEPTH
  // ===========================================================================

  static const double visualDepthWindow = 700.0;

  static const double minimumVisibleDistance = -20.0;

  // ===========================================================================
  // PERSPECTIVE SCALE
  // ===========================================================================

  static const double obstacleMinScale = 0.05;
  static const double obstacleMaxScale = 1.00;

  static const double obstaclePerspectiveExponent = 3.0;

  // ===========================================================================
  // LIVES
  // ===========================================================================

  static const int startingLives = 3;

  // ===========================================================================
  // SCORE
  // ===========================================================================

  static const int scoreCan = 10;
  static const int scoreCoin = 25;
  static const int scoreBonusCan = 100;
  static const int scoreObstacleAvoided = 5;
  static const int scoreLevelCompletion = 500;

  // ===========================================================================
  // COMBO
  // ===========================================================================

  static const int comboThreshold = 3;
  static const double comboWindowSeconds = 2.5;

  static const List<double> comboMultipliers = [
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];

  // ===========================================================================
  // POWER UPS
  // ===========================================================================

  static const double magnetDuration = 8.0;
  static const double shieldHits = 1;
  static const double speedBoostDuration = 5.0;
  static const double speedBoostMultiplier = 1.6;
  static const double invincibilityDuration = 6.0;

  // ===========================================================================
  // WORLD / LEVELS
  // ===========================================================================

  static const int worldCount = 5;
  static const int levelsPerWorld = 10;
  static const int totalLevels = worldCount * levelsPerWorld;

  // ===========================================================================
  // OBJECT POOLING
  // ===========================================================================

  static const int obstaclePoolSize = 40;
  static const int itemPoolSize = 60;

  // ===========================================================================
  // CAMERA
  // ===========================================================================

  static const double cameraShakeDurationSeconds = 0.25;
  static const double cameraShakeMagnitude = 10.0;
}