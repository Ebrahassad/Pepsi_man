import 'dart:math';

import '../../../core/constants/game_constants.dart';
import '../models/obstacle_model.dart';
import '../models/track_segment.dart';
import '../data/obstacle_data.dart';
import 'object_pool.dart';

/// Manages the set of active obstacles for the current run. Backed by a
/// real [ObjectPool] (per rule 47: never allocate thousands of objects at
/// runtime) — spawning acquires a recycled [ObstacleInstance] instead of
/// calling `ObstacleInstance(...)` directly, and obstacles that fall
/// behind the player are released back to the pool instead of being left
/// for the garbage collector.
class ObstacleEngine {
  final List<ObstacleInstance> active = [];
  final Random _random = Random();

  late final ObjectPool<ObstacleInstance> _pool = ObjectPool<ObstacleInstance>(
    size: GameConstants.obstaclePoolSize,
    factory: () => ObstacleInstance(type: ObstacleType.car, lane: 1, distance: 0),
    reset: (o) {
      o.isHit = false;
      o.isPassed = false;
      o.motionTimer = 0;
      o.hasAppeared = true;
    },
  );

  void spawnFromSegment(TrackSegment segment, double segmentStartDistance) {
    for (final template in segment.obstacles) {
      final config = ObstacleData.all[template.type];
      final instance = _pool.acquire();
      instance.type = template.type;
      instance.lane = template.lane;
      instance.distance = segmentStartDistance + template.distance;
      instance.isHit = false;
      instance.isPassed = false;
      instance.motionTimer = 0;
      instance.hasAppeared = config?.motion != ObstacleMotion.sideAppear;
      active.add(instance);
    }
  }

  void update(double dt, double runnerDistance, double forwardSpeed) {
    for (final obstacle in active) {
      final config = ObstacleData.all[obstacle.type];
      if (config == null) continue;

      switch (config.motion) {
        case ObstacleMotion.movingLaneChange:
          // Periodically shifts one lane left/right, staying in bounds.
          obstacle.motionTimer += dt;
          if (obstacle.motionTimer >= 1.8) {
            obstacle.motionTimer = 0;
            final direction = _random.nextBool() ? 1 : -1;
            obstacle.lane = (obstacle.lane + direction).clamp(
              GameConstants.laneLeft,
              GameConstants.laneRight,
            );
          }
          break;

        case ObstacleMotion.crossLane:
          // Sweeps continuously across all 3 lanes, faster than a plain
          // lane change, to force an active dodge.
          obstacle.motionTimer += dt;
          if (obstacle.motionTimer >= 0.9) {
            obstacle.motionTimer = 0;
            obstacle.lane = (obstacle.lane + 1) % 3;
          }
          break;

        case ObstacleMotion.movingTowardPlayer:
          obstacle.distance -= forwardSpeed * dt * 0.15;
          break;

        case ObstacleMotion.sideAppear:
          // Stays invisible/non-collidable until the player gets close,
          // then "appears" suddenly from the side.
          final relative = obstacle.distance - runnerDistance;
          obstacle.hasAppeared = relative < 12;
          break;

        case ObstacleMotion.static_:
          break;
      }

      if (obstacle.distance < runnerDistance - 5 && !obstacle.isPassed) {
        obstacle.isPassed = true;
      }
    }

    final toRelease = active.where((o) => o.distance < runnerDistance - 20).toList();
    for (final obstacle in toRelease) {
      active.remove(obstacle);
      _pool.release(obstacle);
    }
  }

  List<ObstacleInstance> obstaclesNear(double runnerDistance, {double range = 15}) {
    return active
        .where((o) => o.hasAppeared && (o.distance - runnerDistance).abs() <= range)
        .toList();
  }

  void reset() {
    for (final obstacle in active) {
      _pool.release(obstacle);
    }
    active.clear();
  }

  int get pooledCount => _pool.totalCount;
  int get activePoolUsage => _pool.activeCount;
}
