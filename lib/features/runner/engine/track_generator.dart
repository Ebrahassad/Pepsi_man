import 'dart:math';

import '../models/track_segment.dart';
import '../models/obstacle_model.dart';
import '../models/item_model.dart';
import '../models/level_model.dart';
import '../data/obstacle_data.dart';

/// Builds a level's full track out of short, reusable [TrackSegment]s
/// instead of hand-placing obstacles for 50 separate levels. Segment
/// choice is weighted by `LevelModel.segmentWeights`.
class TrackGenerator {
  final Random _random;

  TrackGenerator({int? seed}) : _random = Random(seed);

  static const double _segmentBaseLength = 40.0;

  // Level 2 goal.
  static const int _level2RequiredCans = 75;

  List<TrackSegment> generate(LevelModel level) {
    final segments = <TrackSegment>[];
    double coveredDistance = 0;
    double distanceSinceCheckpoint = 0;

    final weightedTypes = _expandWeights(level.segmentWeights);

    final worldObstacles =
        ObstacleData.byWorld[level.worldId] ?? ObstacleData.byWorld[1]!;

    while (coveredDistance < level.distanceMeters) {
      final type = weightedTypes[_random.nextInt(weightedTypes.length)];

      final forceCheckpoint =
          distanceSinceCheckpoint >= level.checkpointIntervalMeters;

      final segment = _buildSegment(
        type: forceCheckpoint
            ? TrackSegmentType.checkpointSection
            : type,
        worldObstacles: worldObstacles,
        level: level,
      );

      segments.add(segment);

      coveredDistance += segment.lengthMeters;

      distanceSinceCheckpoint = forceCheckpoint
          ? 0
          : distanceSinceCheckpoint + segment.lengthMeters;
    }

    // -----------------------------------------------------------------------
    // LEVEL 2 ONLY
    // -----------------------------------------------------------------------
    // Preserve all original segment generation above.
    // Add the required energy cans afterwards so the existing obstacles,
    // coins, power-ups and segment weighting remain untouched.
    if (level.id == 2) {
      _addRequiredCans(
        segments,
        requiredCount: _level2RequiredCans,
        trackLength: level.distanceMeters,
      );
    }

    return segments;
  }

  List<TrackSegmentType> _expandWeights(
    Map<TrackSegmentType, int> weights,
  ) {
    final expanded = <TrackSegmentType>[];

    weights.forEach((type, weight) {
      for (int i = 0; i < weight; i++) {
        expanded.add(type);
      }
    });

    if (expanded.isEmpty) {
      expanded.add(TrackSegmentType.straight);
    }

    return expanded;
  }

  TrackSegment _buildSegment({
    required TrackSegmentType type,
    required List<ObstacleType> worldObstacles,
    required LevelModel level,
  }) {
    final obstacles = <ObstacleInstance>[];
    final items = <ItemInstance>[];

    double length = _segmentBaseLength;
    bool hasCheckpoint = false;

    switch (type) {
      case TrackSegmentType.straight:
        _scatterCoins(
          items,
          count: 2,
          length: length,
        );
        break;

      case TrackSegmentType.leftPattern:
        obstacles.add(
          _randomObstacle(
            worldObstacles,
            lane: 1,
            distance: length * 0.5,
          ),
        );

        _scatterCoins(
          items,
          count: 3,
          length: length,
          preferredLane: 0,
        );
        break;

      case TrackSegmentType.rightPattern:
        obstacles.add(
          _randomObstacle(
            worldObstacles,
            lane: 1,
            distance: length * 0.5,
          ),
        );

        _scatterCoins(
          items,
          count: 3,
          length: length,
          preferredLane: 2,
        );
        break;

      case TrackSegmentType.jumpSection:
        for (final lane in [0, 1, 2]) {
          if (_random.nextDouble() < 0.7) {
            obstacles.add(
              ObstacleInstance(
                type: _jumpObstacleFrom(worldObstacles),
                lane: lane,
                distance:
                    length * (0.3 + _random.nextDouble() * 0.4),
              ),
            );
          }
        }
        break;

      case TrackSegmentType.slideSection:
        for (final lane in [0, 1, 2]) {
          if (_random.nextDouble() < 0.6) {
            obstacles.add(
              ObstacleInstance(
                type: _slideObstacleFrom(worldObstacles),
                lane: lane,
                distance:
                    length * (0.3 + _random.nextDouble() * 0.4),
              ),
            );
          }
        }
        break;

      case TrackSegmentType.trafficSection:
        length = _segmentBaseLength * 1.5;

        for (int i = 0; i < 3; i++) {
          obstacles.add(
            _randomObstacle(
              worldObstacles,
              lane: _random.nextInt(3),
              distance: length * (i + 1) / 4,
            ),
          );
        }
        break;

      case TrackSegmentType.coinSection:
        _scatterCoins(
          items,
          count: 6,
          length: length,
        );

        if (_random.nextDouble() < level.powerUpChance) {
          items.add(_randomPowerUp(length));
        }
        break;

      case TrackSegmentType.speedSection:
        length = _segmentBaseLength * 1.2;

        _scatterCoins(
          items,
          count: 4,
          length: length,
        );
        break;

      case TrackSegmentType.checkpointSection:
        hasCheckpoint = true;

        _scatterCoins(
          items,
          count: 2,
          length: length,
        );
        break;
    }

    return TrackSegment(
      type: type,
      lengthMeters: length,
      obstacles: obstacles,
      items: items,
      hasCheckpoint: hasCheckpoint,
    );
  }

  // ---------------------------------------------------------------------------
  // LEVEL 2 CAN GENERATION
  // ---------------------------------------------------------------------------

  void _addRequiredCans(
    List<TrackSegment> segments, {
    required int requiredCount,
    required double trackLength,
  }) {
    if (segments.isEmpty || requiredCount <= 0) {
      return;
    }

    final spacing = trackLength / (requiredCount + 1);

    for (int i = 0; i < requiredCount; i++) {
      final targetDistance = spacing * (i + 1);

      double accumulated = 0;

      for (final segment in segments) {
        final segmentStart = accumulated;
        final segmentEnd = accumulated + segment.lengthMeters;

        if (targetDistance > segmentStart &&
            targetDistance < segmentEnd) {
          final localDistance = targetDistance - segmentStart;

          final lane = _findSafeCanLane(
            segment,
            localDistance,
          );

          segment.items.add(
            ItemInstance(
              type: ItemType.energyCan,
              lane: lane,
              distance: localDistance,
            ),
          );

          break;
        }

        accumulated = segmentEnd;
      }
    }
  }

  int _findSafeCanLane(
    TrackSegment segment,
    double distance,
  ) {
    final lanes = [0, 1, 2];

    lanes.shuffle(_random);

    for (final lane in lanes) {
      final blocked = segment.obstacles.any(
        (obstacle) =>
            obstacle.lane == lane &&
            (obstacle.distance - distance).abs() < 3.0,
      );

      if (!blocked) {
        return lane;
      }
    }

    // If every lane is occupied near this exact point,
    // choose a deterministic fallback lane.
    return 1;
  }

  // ---------------------------------------------------------------------------
  // ORIGINAL HELPERS
  // ---------------------------------------------------------------------------

  ObstacleInstance _randomObstacle(
    List<ObstacleType> pool, {
    required int lane,
    required double distance,
  }) {
    final type = pool[_random.nextInt(pool.length)];

    return ObstacleInstance(
      type: type,
      lane: lane,
      distance: distance,
    );
  }

  ObstacleType _jumpObstacleFrom(
    List<ObstacleType> pool,
  ) {
    final jumpTypes = pool.where((t) {
      final action = ObstacleData.all[t]!.requiredAction;
      return action == ObstacleAction.jump;
    }).toList();

    if (jumpTypes.isEmpty) {
      return ObstacleType.cone;
    }

    return jumpTypes[_random.nextInt(jumpTypes.length)];
  }

  ObstacleType _slideObstacleFrom(
    List<ObstacleType> pool,
  ) {
    final slideTypes = pool.where((t) {
      final action = ObstacleData.all[t]!.requiredAction;
      return action == ObstacleAction.slide;
    }).toList();

    if (slideTypes.isEmpty) {
      return ObstacleType.gate;
    }

    return slideTypes[_random.nextInt(slideTypes.length)];
  }

  void _scatterCoins(
    List<ItemInstance> items, {
    required int count,
    required double length,
    int? preferredLane,
  }) {
    for (int i = 0; i < count; i++) {
      final lane = preferredLane ?? _random.nextInt(3);

      final distance =
          length * (i + 1) / (count + 1);

      items.add(
        ItemInstance(
          type: ItemType.coin,
          lane: lane,
          distance: distance,
        ),
      );
    }
  }

  ItemInstance _randomPowerUp(
    double length,
  ) {
    const powerUps = [
      ItemType.magnet,
      ItemType.shield,
      ItemType.speedBoost,
      ItemType.invincibility,
    ];

    final type =
        powerUps[_random.nextInt(powerUps.length)];

    return ItemInstance(
      type: type,
      lane: _random.nextInt(3),
      distance: length * 0.5,
    );
  }
}