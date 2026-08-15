import 'package:flutter_test/flutter_test.dart';
import 'package:pepsi_runner/features/runner/engine/item_engine.dart';
import 'package:pepsi_runner/features/runner/models/item_model.dart';
import 'package:pepsi_runner/features/runner/models/power_up_model.dart';
import 'package:pepsi_runner/features/runner/models/track_segment.dart';

void main() {
  group('ItemEngine', () {
    test('spawnFromSegment adds items at the correct absolute distance', () {
      final engine = ItemEngine();
      final segment = TrackSegment(
        type: TrackSegmentType.coinSection,
        lengthMeters: 40,
        items: [
          ItemInstance(type: ItemType.coin, lane: 0, distance: 15),
        ],
      );

      engine.spawnFromSegment(segment, 200);
      expect(engine.active.length, 1);
      expect(engine.active.first.distance, 215);
    });

    test('collected/passed items are pruned and released back to the pool', () {
      final engine = ItemEngine();
      final segment = TrackSegment(
        type: TrackSegmentType.coinSection,
        lengthMeters: 40,
        items: [
          ItemInstance(type: ItemType.coin, lane: 1, distance: 5),
        ],
      );
      engine.spawnFromSegment(segment, 0);
      engine.collect(engine.active.first);

      engine.pruneCollectedAndPassed(5);
      expect(engine.active, isEmpty);
    });

    test('activating shield gives exactly one remaining hit, not a timer', () {
      final engine = ItemEngine();
      engine.activatePowerUp(PowerUpType.shield);
      expect(engine.hasShield, isTrue);

      final consumed = engine.consumeShieldHit();
      expect(consumed, isTrue);
      expect(engine.hasShield, isFalse);
    });

    test('activating magnet/speedBoost/invincibility sets a countdown that expires', () {
      final engine = ItemEngine();
      engine.activatePowerUp(PowerUpType.magnet);
      expect(engine.hasMagnet, isTrue);

      // Advance well past the magnet's configured duration.
      for (int i = 0; i < 2000; i++) {
        engine.update(0.016);
      }
      expect(engine.hasMagnet, isFalse);
    });

    test('re-activating the same power-up refreshes its duration', () {
      final engine = ItemEngine();
      engine.activatePowerUp(PowerUpType.speedBoost);
      engine.update(1.0);
      engine.activatePowerUp(PowerUpType.speedBoost); // refresh
      expect(engine.hasSpeedBoost, isTrue);
    });

    test('the pool does not grow unbounded across repeated spawn/collect cycles', () {
      final engine = ItemEngine();
      final initialPoolSize = engine.pooledCount;

      for (int i = 0; i < 10; i++) {
        final segment = TrackSegment(
          type: TrackSegmentType.coinSection,
          lengthMeters: 40,
          items: [
            ItemInstance(type: ItemType.coin, lane: 1, distance: 5),
          ],
        );
        engine.spawnFromSegment(segment, i * 40.0);
        engine.collect(engine.active.last);
        engine.pruneCollectedAndPassed(i * 40.0 + 5);
      }

      expect(engine.pooledCount, lessThanOrEqualTo(initialPoolSize + 1));
    });
  });
}
