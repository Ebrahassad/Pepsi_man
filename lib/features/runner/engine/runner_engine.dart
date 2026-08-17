import '../../../core/audio/audio_manager.dart';
import '../models/runner_model.dart';
import '../models/level_model.dart';
import '../models/item_model.dart';
import '../models/power_up_model.dart';
import '../../../core/constants/game_constants.dart';
import 'runner_physics.dart';
import 'collision_engine.dart';
import 'obstacle_engine.dart';
import 'item_engine.dart';
import 'level_engine.dart';
import 'camera_engine.dart';
import 'score_engine.dart';

enum RunnerInputAction {
  laneLeft,
  laneRight,
  jump,
  slide,
}

enum RunEndReason {
  none,
  levelComplete,
  gameOver,
}

/// The single source of truth for one gameplay run.
///
/// Ties every sub-engine together and executes:
///
/// Input -> Physics -> Lane -> Obstacles -> Items
/// -> Collision -> Score -> Camera -> Render
///
/// Render is the caller's job; this class only computes gameplay state.
class RunnerEngine {
  final LevelModel level;

  final RunnerModel runner = RunnerModel();

  late final RunnerPhysics physics;
  late final LevelEngine levelEngine;

  final ObstacleEngine obstacleEngine =
      ObstacleEngine();

  final ItemEngine itemEngine =
      ItemEngine();

  final CollisionEngine collisionEngine =
      CollisionEngine();

  final ScoreEngine scoreEngine =
      ScoreEngine();

  final CameraEngine cameraEngine =
      CameraEngine();

  /// Current distance travelled by the runner.
  double distanceMeters = 0;

  /// Distance from the previous frame.
  ///
  /// Kept here so collision systems can later determine whether
  /// an obstacle/item was crossed between two frames.
  double previousDistanceMeters = 0;

  int _spawnedSegmentCount = 0;

  RunEndReason endReason =
      RunEndReason.none;

  double _hitInvulnerabilitySeconds = 0;

  RunnerEngine({
    required this.level,
    int? seed,
  }) {
    physics = RunnerPhysics(
      baseSpeed: level.baseSpeed,
      maxSpeedOverride: level.maxSpeed,
      accelerationOverride: level.acceleration,
    );

    levelEngine = LevelEngine(
      level: level,
      seed: seed,
    );

    runner.lives =
        GameConstants.startingLives;

    _spawnUpcomingSegments();
  }

  // ---------------------------------------------------------------------------
  // INPUT
  // ---------------------------------------------------------------------------

  void handleInput(
    RunnerInputAction action,
  ) {
    switch (action) {
      case RunnerInputAction.laneLeft:
        physics.requestLaneChange(-1);
        break;

      case RunnerInputAction.laneRight:
        physics.requestLaneChange(1);
        break;

      case RunnerInputAction.jump:
        physics.jump();
        AudioManager.instance.playJump();
        break;

      case RunnerInputAction.slide:
        physics.slide();
        AudioManager.instance.playSlide();
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // FRAME UPDATE
  // ---------------------------------------------------------------------------

  /// Advances the complete gameplay simulation by [dt] seconds.
  void update(double dt) {
    if (dt <= 0) return;

    if (endReason != RunEndReason.none) {
      return;
    }

    // -----------------------------------------------------------------------
    // Keep previous distance before advancing the frame.
    // -----------------------------------------------------------------------

    previousDistanceMeters =
        distanceMeters;

    // -----------------------------------------------------------------------
    // 1. PHYSICS
    // -----------------------------------------------------------------------

    if (itemEngine.hasSpeedBoost) {
      physics.applySpeedMultiplier(
        1 +
            (GameConstants.speedBoostMultiplier - 1) *
                dt,
      );
    }

    physics.update(dt);

    // -----------------------------------------------------------------------
    // 2. DISTANCE / WORLD SCROLL
    // -----------------------------------------------------------------------

    distanceMeters +=
        physics.forwardSpeed * dt;

    // -----------------------------------------------------------------------
    // 3. OBSTACLES + ITEMS
    // -----------------------------------------------------------------------

    obstacleEngine.update(
      dt,
      distanceMeters,
      physics.forwardSpeed,
    );

    itemEngine.update(dt);

    _spawnUpcomingSegments();

    // -----------------------------------------------------------------------
    // 4. COLLISION
    // -----------------------------------------------------------------------

    _resolveCollisions();

    // -----------------------------------------------------------------------
    // 5. SCORE
    // -----------------------------------------------------------------------

    scoreEngine.update(dt);

    scoreEngine.updateDistance(
      distanceMeters,
    );

    // -----------------------------------------------------------------------
    // 6. LEVEL GOAL / CHECKPOINTS
    // -----------------------------------------------------------------------

    levelEngine.update(
      dt,
      distanceMeters,
    );

    // -----------------------------------------------------------------------
    // 7. CAMERA
    // -----------------------------------------------------------------------

    cameraEngine.update(
      dt,
      physics.forwardSpeed,
    );

    // -----------------------------------------------------------------------
    // 8. RUNNER VISUAL STATE
    // -----------------------------------------------------------------------

    runner.state =
        physics.resolveState(
      isHit:
          _hitInvulnerabilitySeconds > 0 &&
              runner.lives > 0,
    );

    if (_hitInvulnerabilitySeconds > 0) {
      _hitInvulnerabilitySeconds -= dt;

      if (_hitInvulnerabilitySeconds < 0) {
        _hitInvulnerabilitySeconds = 0;
      }
    }

    // -----------------------------------------------------------------------
    // 9. END CONDITIONS
    // -----------------------------------------------------------------------

    _checkEndConditions();
  }

  // ---------------------------------------------------------------------------
  // SPAWN
  // ---------------------------------------------------------------------------

  /// How far ahead the game should prepare segments.
  ///
  /// Previously this was a fixed 60 units:
  ///
  ///     distanceMeters + 60
  ///
  /// That becomes far too short at higher speeds.
  ///
  /// We now calculate the look-ahead from the current speed and a target
  /// preparation time.
  double get _spawnLookAheadDistance {
    const preparationTimeSeconds = 2.2;

    const minimumLookAhead = 180.0;
    const maximumLookAhead = 1600.0;

    final speed =
        physics.forwardSpeed;

    final calculated =
        speed * preparationTimeSeconds;

    return calculated.clamp(
      minimumLookAhead,
      maximumLookAhead,
    );
  }

  void _spawnUpcomingSegments() {
    final starts =
        levelEngine.segmentStartDistances;

    final lookAhead =
        _spawnLookAheadDistance;

    final spawnLimit =
        distanceMeters + lookAhead;

    for (
      int i = _spawnedSegmentCount;
      i < levelEngine.segments.length;
      i++
    ) {
      if (starts[i] > spawnLimit) {
        break;
      }

      obstacleEngine.spawnFromSegment(
        levelEngine.segments[i],
        starts[i],
      );

      itemEngine.spawnFromSegment(
        levelEngine.segments[i],
        starts[i],
      );

      _spawnedSegmentCount = i + 1;
    }
  }

  // ---------------------------------------------------------------------------
  // COLLISION
  // ---------------------------------------------------------------------------

  void _resolveCollisions() {
    // -------------------------------------------------------------------------
    // OBSTACLES
    // -------------------------------------------------------------------------

    for (
  final obstacle
      in obstacleEngine.obstaclesNear(
    distanceMeters,
    forwardSpeed: physics.forwardSpeed,
  )
) {
      if (obstacle.isHit ||
          obstacle.isPassed) {
        continue;
      }

      final hit =
          collisionEngine.checkObstacleHit(
        obstacle: obstacle,
        physics: physics,
        runnerDistance: distanceMeters,
      );

      if (hit) {
        obstacle.isHit = true;
        _applyHit();
      } else if (
          (obstacle.distance -
                  distanceMeters)
              .abs() <
          0.5) {
        obstacle.isPassed = true;

        scoreEngine
            .registerObstacleAvoided();
      }
    }

    // -------------------------------------------------------------------------
    // ITEMS
    // -------------------------------------------------------------------------

    final magnetRadius =
        itemEngine.hasMagnet
            ? 6.0
            : 0.0;

    for (
  final item
      in itemEngine.itemsNear(
    distanceMeters,
    forwardSpeed: physics.forwardSpeed,
  )
) {
      final collected =
          collisionEngine.checkItemCollected(
        item: item,
        physics: physics,
        runnerDistance: distanceMeters,
        magnetRadius: magnetRadius,
      );

      if (collected) {
        _collectItem(item);
      }
    }

    itemEngine
        .pruneCollectedAndPassed(
      distanceMeters,
    );
  }

  // ---------------------------------------------------------------------------
  // ITEMS / POWER UPS
  // ---------------------------------------------------------------------------

  void _collectItem(
    ItemInstance item,
  ) {
    itemEngine.collect(item);

    scoreEngine.registerItem(
      item.type,
    );

    if (item.type ==
            ItemType.energyCan ||
        item.type ==
            ItemType.bonusCan) {
      levelEngine.registerCan();

      AudioManager.instance
          .playCanCollect();
    } else if (
        item.type == ItemType.coin) {
      levelEngine.registerCoin();

      AudioManager.instance
          .playCoinCollect();
    }

    if (isPowerUpItem(item.type)) {
      final powerUpType =
          _powerUpTypeFor(
        item.type,
      );

      if (powerUpType != null) {
        itemEngine.activatePowerUp(
          powerUpType,
        );

        _reflectPowerUpOnRunner();

        _playPowerUpSfx(
          powerUpType,
        );
      }
    }
  }

  PowerUpType? _powerUpTypeFor(
    ItemType type,
  ) {
    switch (type) {
      case ItemType.magnet:
        return PowerUpType.magnet;

      case ItemType.shield:
        return PowerUpType.shield;

      case ItemType.speedBoost:
        return PowerUpType.speedBoost;

      case ItemType.invincibility:
        return PowerUpType.invincibility;

      default:
        return null;
    }
  }

  void _playPowerUpSfx(
    PowerUpType type,
  ) {
    switch (type) {
      case PowerUpType.magnet:
        AudioManager.instance
            .playMagnetActivate();
        break;

      case PowerUpType.shield:
        break;

      case PowerUpType.speedBoost:
        AudioManager.instance
            .playSpeedBoost();
        break;

      case PowerUpType.invincibility:
        AudioManager.instance
            .playInvincibility();
        break;
    }
  }

  void _reflectPowerUpOnRunner() {
    runner.hasShield =
        itemEngine.hasShield;

    runner.isMagnetActive =
        itemEngine.hasMagnet;

    runner.isSpeedBoostActive =
        itemEngine.hasSpeedBoost;

    runner.isInvincible =
        itemEngine.hasInvincibility;
  }

  // ---------------------------------------------------------------------------
  // HIT
  // ---------------------------------------------------------------------------

  void _applyHit() {
    if (_hitInvulnerabilitySeconds >
        0) {
      return;
    }

    final shieldAbsorbed =
        itemEngine.consumeShieldHit();

    if (shieldAbsorbed) {
      runner.hasShield = false;

      AudioManager.instance
          .playShieldBreak();

      return;
    }

    final lostLife =
        collisionEngine.applyHit(
      runner,
    );

    levelEngine.registerHit();

    if (lostLife) {
      AudioManager.instance
          .playPlayerHit();

      cameraEngine.shake(
        durationSeconds:
            GameConstants
                .cameraShakeDurationSeconds,
        magnitude:
            GameConstants
                .cameraShakeMagnitude,
      );

      _hitInvulnerabilitySeconds =
          1.0;

      if (runner.lives <= 0) {
        endReason =
            RunEndReason.gameOver;
      } else {
        _respawnAtCheckpoint();
      }
    }
  }

  // ---------------------------------------------------------------------------
  // CHECKPOINT
  // ---------------------------------------------------------------------------

  void _respawnAtCheckpoint() {
    final checkpoint =
        levelEngine.lastReachedCheckpoint;

    if (checkpoint != null) {
      distanceMeters =
          checkpoint.distance;

      previousDistanceMeters =
          distanceMeters;

      AudioManager.instance
          .playCheckpoint();
    }
  }

  // ---------------------------------------------------------------------------
  // END CONDITIONS
  // ---------------------------------------------------------------------------

  void _checkEndConditions() {
    if (endReason !=
        RunEndReason.none) {
      return;
    }

    if (levelEngine
        .progress.isComplete) {
      scoreEngine
          .registerLevelCompletion();

      endReason =
          RunEndReason.levelComplete;

      runner.state =
          RunnerState.celebrating;

      AudioManager.instance
          .playLevelComplete();
    } else if (runner.lives <= 0) {
      endReason =
          RunEndReason.gameOver;

      AudioManager.instance
          .playGameOver();
    }
  }

  // ---------------------------------------------------------------------------
  // RESET
  // ---------------------------------------------------------------------------

  void reset() {
    distanceMeters = 0;

    previousDistanceMeters = 0;

    _spawnedSegmentCount = 0;

    endReason =
        RunEndReason.none;

    _hitInvulnerabilitySeconds = 0;

    scoreEngine.reset();

    obstacleEngine.reset();

    itemEngine.reset();

    cameraEngine.reset();

    // Restore runner state.
    runner.lives =
        GameConstants.startingLives;

    runner.state =
        RunnerState.running;
  }
}