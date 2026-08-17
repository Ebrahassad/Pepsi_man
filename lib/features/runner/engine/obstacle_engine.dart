import 'dart:math';

import '../../../core/constants/game_constants.dart';
import '../models/obstacle_model.dart';
import '../models/track_segment.dart';
import '../data/obstacle_data.dart';
import 'object_pool.dart';

/// Manages active obstacles for the current run.
///
/// Obstacles are pooled and recycled. Visibility/collision lookup ranges
/// scale with the runner's current speed so fast levels do not become
/// impossible simply because the engine uses small fixed distance windows.
class ObstacleEngine {
  final List<ObstacleInstance> active = [];

  final Random _random = Random();

  late final ObjectPool<ObstacleInstance> _pool =
      ObjectPool<ObstacleInstance>(
    size: GameConstants.obstaclePoolSize,
    factory: () => ObstacleInstance(
      type: ObstacleType.car,
      lane: 1,
      distance: 0,
    ),
    reset: (o) {
      o.isHit = false;
      o.isPassed = false;
      o.motionTimer = 0;
      o.hasAppeared = true;
    },
  );

  // ---------------------------------------------------------------------------
  // SPAWN
  // ---------------------------------------------------------------------------

  void spawnFromSegment(
    TrackSegment segment,
    double segmentStartDistance,
  ) {
    for (final template in segment.obstacles) {
      final config =
          ObstacleData.all[template.type];

      final instance = _pool.acquire();

      instance.type = template.type;
      instance.lane = template.lane;
      instance.distance =
          segmentStartDistance +
              template.distance;

      instance.isHit = false;
      instance.isPassed = false;
      instance.motionTimer = 0;

      instance.hasAppeared =
          config?.motion !=
              ObstacleMotion.sideAppear;

      active.add(instance);
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE
  // ---------------------------------------------------------------------------

  void update(
    double dt,
    double runnerDistance,
    double forwardSpeed,
  ) {
    if (dt <= 0) return;

    for (final obstacle in active) {
      final config =
          ObstacleData.all[obstacle.type];

      if (config == null) {
        continue;
      }

      switch (config.motion) {
        case ObstacleMotion.movingLaneChange:
          obstacle.motionTimer += dt;

          if (obstacle.motionTimer >= 1.8) {
            obstacle.motionTimer = 0;

            final direction =
                _random.nextBool()
                    ? 1
                    : -1;

            obstacle.lane =
                (obstacle.lane +
                        direction)
                    .clamp(
              GameConstants.laneLeft,
              GameConstants.laneRight,
            );
          }
          break;

        case ObstacleMotion.crossLane:
          obstacle.motionTimer += dt;

          if (obstacle.motionTimer >= 0.9) {
            obstacle.motionTimer = 0;

            obstacle.lane =
                (obstacle.lane + 1) % 3;
          }
          break;

        case ObstacleMotion.movingTowardPlayer:
          obstacle.distance -=
              forwardSpeed * dt * 0.15;
          break;

        case ObstacleMotion.sideAppear:
          // The old value was a fixed 12 units.
          // At high speed that is almost instantaneous.
          //
          // Keep approximately one second of reaction distance.
          final appearanceDistance =
              (forwardSpeed * 1.0)
                  .clamp(120.0, 650.0);

          final relative =
              obstacle.distance -
                  runnerDistance;

          obstacle.hasAppeared =
              relative <
                  appearanceDistance;
          break;

        case ObstacleMotion.static_:
          break;
      }

      if (obstacle.distance <
              runnerDistance - 5 &&
          !obstacle.isPassed) {
        obstacle.isPassed = true;
      }
    }

    // -------------------------------------------------------------------------
    // POOL CLEANUP
    // -------------------------------------------------------------------------

    final releaseDistance =
        runnerDistance - 80;

    final toRelease = active
        .where(
          (o) =>
              o.distance <
              releaseDistance,
        )
        .toList();

    for (final obstacle in toRelease) {
      active.remove(obstacle);
      _pool.release(obstacle);
    }
  }

  // ---------------------------------------------------------------------------
  // LOOKUP
  // ---------------------------------------------------------------------------

  List<ObstacleInstance> obstaclesNear(
    double runnerDistance, {
    double? range,
    double forwardSpeed =
        GameConstants.defaultBaseSpeed,
  }) {
    // The old range was 15 units.
    //
    // At 650 units/s the player can travel a very large distance between
    // meaningful gameplay moments, so the lookup window must scale with speed.
    final effectiveRange =
        (range ??
                (forwardSpeed * 0.35))
            .clamp(60.0, 300.0);

    return active
        .where(
          (o) =>
              o.hasAppeared &&
              (o.distance -
                          runnerDistance)
                      .abs() <=
                  effectiveRange,
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // RESET
  // ---------------------------------------------------------------------------

  void reset() {
    for (final obstacle in active) {
      _pool.release(obstacle);
    }

    active.clear();
  }

  // ---------------------------------------------------------------------------
  // POOL INFO
  // ---------------------------------------------------------------------------

  int get pooledCount =>
      _pool.totalCount;

  int get activePoolUsage =>
      _pool.activeCount;
}