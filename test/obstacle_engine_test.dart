import 'package:flutter_test/flutter_test.dart';
import 'package:pepsi_runner/features/runner/engine/obstacle_engine.dart';
import 'package:pepsi_runner/features/runner/models/obstacle_model.dart';
import 'package:pepsi_runner/features/runner/models/track_segment.dart';

void main() {
  group('ObstacleEngine', () {
    test('spawnFromSegment adds obstacles at the correct absolute distance', () {
      final engine = ObstacleEngine();
      final segment = TrackSegment(
        type: TrackSegmentType.jumpSection,
        lengthMeters: 40,
        obstacles: [
          ObstacleInstance(type: ObstacleType.cone, lane: 1, distance: 10),
        ],
      );

      engine.spawnFromSegment(segment, 100);
      expect(engine.active.length, 1);
      expect(engine.active.first.distance, 110);
    });

    test('obstacles behind the player are released back to the pool', () {
      final engine = ObstacleEngine();
      final segment = TrackSegment(
        type: TrackSegmentType.straight,
        lengthMeters: 40,
        obstacles: [
          ObstacleInstance(type: ObstacleType.car, lane: 0, distance: 5),
        ],
      );
      engine.spawnFromSegment(segment, 0);
      expect(engine.active.length, 1);

      // Runner is now far ahead of the obstacle -> should be pruned.
      engine.update(0.016, 100, 300);
      expect(engine.active.length, 0);
    });

    test('the pool does not grow unbounded across repeated spawn/prune cycles', () {
      final engine = ObstacleEngine();
      final initialPoolSize = engine.pooledCount;

      for (int i = 0; i < 5; i++) {
        final segment = TrackSegment(
          type: TrackSegmentType.straight,
          lengthMeters: 40,
          obstacles: [
            ObstacleInstance(type: ObstacleType.car, lane: 1, distance: 5),
          ],
        );
        engine.spawnFromSegment(segment, i * 40.0);
        // Push the runner far ahead so the obstacle is pruned and its slot
        // returned to the pool before the next spawn.
        engine.update(0.016, i * 40.0 + 100, 300);
      }

      expect(engine.pooledCount, lessThanOrEqualTo(initialPoolSize + 1));
    });

    test('movingLaneChange obstacles change lane over time', () {
      final engine = ObstacleEngine();
      final segment = TrackSegment(
        type: TrackSegmentType.trafficSection,
        lengthMeters: 60,
        obstacles: [
          ObstacleInstance(type: ObstacleType.truck, lane: 1, distance: 10),
        ],
      );
      engine.spawnFromSegment(segment, 0);

      // Advance well past the 1.8s lane-change interval.
      for (int i = 0; i < 200; i++) {
        engine.update(0.016, 0, 0);
      }

      // Lane must remain a valid, in-bounds lane after repeated changes.
      expect(engine.active.first.lane, inInclusiveRange(0, 2));
    });

    test('sideAppear obstacles (trash bin) are hidden until the player is close', () {
      final engine = ObstacleEngine();
      final segment = TrackSegment(
        type: TrackSegmentType.straight,
        lengthMeters: 40,
        obstacles: [
          ObstacleInstance(type: ObstacleType.trashBin, lane: 1, distance: 30),
        ],
      );
      engine.spawnFromSegment(segment, 0);

      // Far away: should not be marked as appeared.
      expect(engine.active.first.hasAppeared, isFalse);

      // Move the runner close enough (< 12m) to trigger appearance.
      engine.update(0.016, 22, 0);
      expect(engine.active.first.hasAppeared, isTrue);

      // obstaclesNear should also now include it.
      final near = engine.obstaclesNear(22, range: 20);
      expect(near, isNotEmpty);
    });
  });
}
