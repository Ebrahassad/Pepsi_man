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

  static const double defaultBaseSpeed = 110.0;

  static const double defaultMaxSpeed = 260.0;

  static const double defaultAcceleration = 3.0;

  // ===========================================================================
  // TRACK PERSPECTIVE
  // ===========================================================================
  //
  // These values are calibrated for the supplied city-road artwork.
  //
  // t = 0.0 → distant road / horizon
  // t = 1.0 → runner / near camera
  //
  // The artwork has a long visible road, so the gameplay geometry must not
  // be compressed into the old 0.68 → 0.78 range.
  //

  // Vanishing/horizon area.
  static const double trackHorizonYFraction = 0.42;

  // Runner feet / collision plane.
  static const double trackGroundYFraction = 0.85;

  // Road width at the distant horizon.
  static const double trackTopLeftXFraction = 0.475;
  static const double trackTopRightXFraction = 0.525;

  // Road width close to the player.
  static const double trackBottomLeftXFraction = 0.10;
  static const double trackBottomRightXFraction = 0.90;

  // ===========================================================================
  // PLAYER VISUAL CALIBRATION
  // ===========================================================================

  // Player height relative to the screen height.
  static const double runnerHeightFraction = 0.20;

  // Player width relative to its height.
  static const double runnerWidthToHeight = 0.55;

  // ===========================================================================
  // VISUAL DEPTH
  // ===========================================================================

  // How far ahead obstacles/items remain visible.
  //
  // The previous value was 180, which made obstacles appear very close.
  // 700 gives the road enough visual length without making objects appear
  // impossibly distant.
  static const double visualDepthWindow = 700.0;

  // Objects can remain for a tiny amount behind the player so they disappear
  // naturally instead of being clipped exactly at the collision plane.
  static const double minimumVisibleDistance = -20.0;

  // ===========================================================================
  // PERSPECTIVE SCALE
  // ===========================================================================

  static const double obstacleMinScale = 0.05;
  static const double obstacleMaxScale = 1.00;

  // Controls how quickly objects grow near the camera.
  //
  // 3.0 means:
  // t=0.00 → 0.05
  // t=0.50 → about 0.17
  // t=0.80 → about 0.54
  // t=1.00 → 1.00
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