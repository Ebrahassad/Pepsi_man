/// Global, static gameplay constants shared across the app.
/// Nothing gameplay-tunable per level lives here — see `level_data.dart`
/// for per-level speed/difficulty values.
class GameConstants {
  GameConstants._();

  // App
  static const String appName = 'Pepsi Runner';
  static const String prefsPrefix = 'pepsi_runner_';

  // Lanes
  static const int laneLeft = 0;
  static const int laneCenter = 1;
  static const int laneRight = 2;
  static const double laneWidth = 120.0;

  // Physics defaults (can be overridden per level via LevelModel)
  static const double gravity = 2200.0; // px/s^2
  static const double jumpVelocity = -820.0; // px/s (negative = upward)
  static const double groundY = 0.0;
  static const double slideDurationSeconds = 0.6;
  static const double laneSwitchDurationSeconds = 0.18;

  // Speed
static const double defaultBaseSpeed = 260.0;
static const double defaultMaxSpeed = 650.0;
static const double defaultAcceleration = 4.0;

// Track perspective calibration
//
// Calibrated against the city background artwork.
// t = 0 → distant/horizon
// t = 1 → runner/ground area

static const double trackHorizonYFraction = 0.68;
static const double trackGroundYFraction = 0.78;

static const double trackTopLeftXFraction = 0.48;
static const double trackTopRightXFraction = 0.52;

static const double trackBottomLeftXFraction = 0.18;
static const double trackBottomRightXFraction = 0.82;
  
  // Lives
  static const int startingLives = 3;

  // Score
  static const int scoreCan = 10;
  static const int scoreCoin = 25;
  static const int scoreBonusCan = 100;
  static const int scoreObstacleAvoided = 5;
  static const int scoreLevelCompletion = 500;

  // Combo
  static const int comboThreshold = 3; // items in a row to bump combo tier
  static const double comboWindowSeconds = 2.5;
  static const List<double> comboMultipliers = [1.0, 1.25, 1.5, 1.75, 2.0];

  // Power-up durations (seconds)
  static const double magnetDuration = 8.0;
  static const double shieldHits = 1;
  static const double speedBoostDuration = 5.0;
  static const double speedBoostMultiplier = 1.6;
  static const double invincibilityDuration = 6.0;

  // World / Level counts
  static const int worldCount = 5;
  static const int levelsPerWorld = 10;
  static const int totalLevels = worldCount * levelsPerWorld;

  // Object pooling
  static const int obstaclePoolSize = 40;
  static const int itemPoolSize = 60;

  // Camera
  static const double cameraShakeDurationSeconds = 0.25;
  static const double cameraShakeMagnitude = 10.0;
}
