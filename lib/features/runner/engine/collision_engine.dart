import '../models/obstacle_model.dart';
import '../models/item_model.dart';
import '../models/checkpoint_model.dart';
import '../models/runner_model.dart';
import 'runner_physics.dart';

enum CollisionResult { none, obstacleHit, obstacleAvoided, itemCollected, checkpointReached }

/// Pure collision-resolution logic. Given the runner's physics state and
/// nearby world objects, decides what happened this frame. No rendering,
/// no audio — callers (RunnerEngine) react to the results.
class CollisionEngine {
  static const double hitToleranceMeters = 1.2;

  /// Checks a single obstacle against the runner's current physics state.
  /// Returns true if this counts as a hit (player did not perform the
  /// required jump/slide action, or is in the same lane with no dodge).
  bool checkObstacleHit({
    required ObstacleInstance obstacle,
    required RunnerPhysics physics,
    required double runnerDistance,
  }) {
    final distanceDelta = (obstacle.distance - runnerDistance).abs();
    if (distanceDelta > hitToleranceMeters) return false;
    if (obstacle.lane != physics.currentLane) return false;

    final config = _requiredActionFor(obstacle.type);
    switch (config) {
      case ObstacleAction.jump:
        return physics.isGrounded; // must be airborne to clear it
      case ObstacleAction.slide:
        return !physics.isSliding; // must be sliding to clear it
      case ObstacleAction.avoidLane:
        return true; // any contact in this lane is a hit
      case ObstacleAction.any:
        return !(physics.isSliding || !physics.isGrounded);
    }
  }

  bool checkItemCollected({
    required ItemInstance item,
    required RunnerPhysics physics,
    required double runnerDistance,
    double magnetRadius = 0,
  }) {
    final distanceDelta = (item.distance - runnerDistance).abs();
    final laneMatches = item.lane == physics.currentLane;
    if (magnetRadius > 0 && distanceDelta <= magnetRadius) return true;
    return laneMatches && distanceDelta <= hitToleranceMeters;
  }

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
    if (jumpTypes.contains(type)) return ObstacleAction.jump;
    if (slideTypes.contains(type)) return ObstacleAction.slide;
    return ObstacleAction.avoidLane;
  }

  /// Applies the effect of a confirmed hit to the runner model, respecting
  /// shield/invincibility.
  bool applyHit(RunnerModel runner) {
    if (runner.isInvincible) return false;
    if (runner.hasShield) {
      runner.hasShield = false;
      return false; // shield absorbed it
    }
    runner.lives -= 1;
    runner.state = RunnerState.hit;
    return true;
  }
}
