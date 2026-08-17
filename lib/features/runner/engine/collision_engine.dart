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
/// Uses frame-crossing detection when the previous runner distance is
/// available. The previous distance remains optional for compatibility
/// with existing unit tests and direct callers.
class CollisionEngine {
  /// Small safety margin used when checking whether an object crossed
  /// the runner between two frames.
  static const double crossingMarginMeters = 0.35;

  bool _crossedRunner({
    required double objectDistance,
    required double previousRunnerDistance,
    required double runnerDistance,
  }) {
    final minDistance = previousRunnerDistance < runnerDistance
        ? previousRunnerDistance
        : runnerDistance;

    final maxDistance = previousRunnerDistance > runnerDistance
        ? previousRunnerDistance
        : runnerDistance;

    return objectDistance >= minDistance - crossingMarginMeters &&
        objectDistance <= maxDistance + crossingMarginMeters;
  }

  bool checkObstacleHit({
    required ObstacleInstance obstacle,
    required RunnerPhysics physics,
    required double runnerDistance,
    double? previousRunnerDistance,
  }) {
    final previousDistance =
        previousRunnerDistance ?? runnerDistance;

    if (!_crossedRunner(
      objectDistance: obstacle.distance,
      previousRunnerDistance: previousDistance,
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
        return physics.isGrounded;

      case ObstacleAction.slide:
        return !physics.isSliding;

      case ObstacleAction.avoidLane:
        return true;

      case ObstacleAction.any:
        return !(physics.isSliding || !physics.isGrounded);
    }
  }

  bool checkItemCollected({
    required ItemInstance item,
    required RunnerPhysics physics,
    required double runnerDistance,
    double? previousRunnerDistance,
    double magnetRadius = 0,
  }) {
    if (item.isCollected) {
      return false;
    }

    final distanceDelta =
        (item.distance - runnerDistance).abs();

    // Magnet uses the current position.
    if (magnetRadius > 0 &&
        distanceDelta <= magnetRadius) {
      return true;
    }

    if (item.lane != physics.currentLane) {
      return false;
    }

    final previousDistance =
        previousRunnerDistance ?? runnerDistance;

    return _crossedRunner(
      objectDistance: item.distance,
      previousRunnerDistance: previousDistance,
      runnerDistance: runnerDistance,
    );
  }

  bool checkCheckpointReached({
    required CheckpointModel checkpoint,
    required double runnerDistance,
  }) {
    return runnerDistance >= checkpoint.distance;
  }

  ObstacleAction _requiredActionFor(
    ObstacleType type,
  ) {
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