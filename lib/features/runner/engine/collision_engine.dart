import '../models/obstacle_model.dart';
import '../models/item_model.dart';
import '../models/checkpoint_model.dart';
import '../models/runner_model.dart';
import 'runner_physics.dart';

enum CollisionResult {
  none,
  obstacleHit,
  obstacleAvoided,
  itemCollected,
  checkpointReached,
}

/// Pure collision-resolution logic.
///
/// Collision detection uses frame-crossing detection rather than relying
/// only on a small fixed distance tolerance.
///
/// This is important at high runner speeds: an obstacle can move from one
/// side of the runner to the other between two frames. In that situation
/// the obstacle's distance must still count as crossed.
///
/// No rendering, audio, or UI logic lives here.
class CollisionEngine {
  /// Small safety margin used when checking whether an object crossed
  /// the runner between the previous and current frame.
  static const double crossingMarginMeters = 0.35;

  /// Returns true when [objectDistance] was crossed by the runner between
  /// [previousRunnerDistance] and [runnerDistance].
  bool _crossedRunner({
    required double objectDistance,
    required double previousRunnerDistance,
    required double runnerDistance,
  }) {
    final minDistance =
        previousRunnerDistance < runnerDistance
            ? previousRunnerDistance
            : runnerDistance;

    final maxDistance =
        previousRunnerDistance > runnerDistance
            ? previousRunnerDistance
            : runnerDistance;

    return objectDistance >= minDistance - crossingMarginMeters &&
        objectDistance <= maxDistance + crossingMarginMeters;
  }

  /// Checks a single obstacle against the runner.
  ///
  /// The obstacle is considered for collision when its distance was crossed
  /// between the previous and current frame.
  ///
  /// This prevents high-speed frames from skipping over the old
  /// hitToleranceMeters window.
  bool checkObstacleHit({
    required ObstacleInstance obstacle,
    required RunnerPhysics physics,
    required double runnerDistance,
    required double previousRunnerDistance,
  }) {
    if (!_crossedRunner(
      objectDistance: obstacle.distance,
      previousRunnerDistance: previousRunnerDistance,
      runnerDistance: runnerDistance,
    )) {
      return false;
    }

    if (obstacle.lane != physics.currentLane) {
      return false;
    }

    final config = _requiredActionFor(obstacle.type);

    switch (config) {
      case ObstacleAction.jump:
        // Must be airborne when crossing the obstacle.
        return physics.isGrounded;

      case ObstacleAction.slide:
        // Must be sliding when crossing the obstacle.
        return !physics.isSliding;

      case ObstacleAction.avoidLane:
        // Same lane means collision.
        return true;

      case ObstacleAction.any:
        // Jumping or sliding avoids generic obstacles.
        return !(physics.isSliding || !physics.isGrounded);
    }
  }

  /// Checks whether an item was collected during this frame.
  ///
  /// Normal collection uses frame-crossing detection.
  ///
  /// Magnet collection still uses a radius around the current runner
  /// position, allowing it to pull items toward the player.
  bool checkItemCollected({
    required ItemInstance item,
    required RunnerPhysics physics,
    required double runnerDistance,
    required double previousRunnerDistance,
    double magnetRadius = 0,
  }) {
    if (item.isCollected) return false;

    final distanceDelta =
        (item.distance - runnerDistance).abs();

    // Magnet has priority and uses the current position.
    if (magnetRadius > 0 && distanceDelta <= magnetRadius) {
      return true;
    }

    if (item.lane != physics.currentLane) {
      return false;
    }

    // Normal item pickup uses frame crossing so high speed cannot skip
    // the item between frames.
    return _crossedRunner(
      objectDistance: item.distance,
      previousRunnerDistance: previousRunnerDistance,
      runnerDistance: runnerDistance,
    );
  }

  /// Checks whether the runner has reached a checkpoint.
  bool checkCheckpointReached({
    required CheckpointModel checkpoint,
    required double runnerDistance,
  }) {
    return runnerDistance >= checkpoint.distance;
  }

  ObstacleAction _requiredActionFor(ObstacleType type) {
    // Mirrors ObstacleData without importing it directly, so this engine
    // stays independent of the data layer's shape.

    const jumpTypes = {
      ObstacleType.barrier,
      ObstacleType.cone,
      ObstacleType.constructionBarrier,
      ObstacleType.lowBarrier,
      ObstacleType.roadBlock,
    };

    const slideTypes = {
      ObstacleType.gate,
      ObstacleType.highBarrier,
    };

    if (jumpTypes.contains(type)) {
      return ObstacleAction.jump;
    }

    if (slideTypes.contains(type)) {
      return ObstacleAction.slide;
    }

    return ObstacleAction.avoidLane;
  }

  /// Applies the effect of a confirmed hit to the runner model.
  ///
  /// Returns true only when a life was actually lost.
  bool applyHit(RunnerModel runner) {
    if (runner.isInvincible) {
      return false;
    }

    if (runner.hasShield) {
      runner.hasShield = false;
      return false;
    }

    runner.lives -= 1;
    runner.state = RunnerState.hit;

    return true;
  }
}