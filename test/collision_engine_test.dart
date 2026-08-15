import 'package:flutter_test/flutter_test.dart';
import 'package:pepsi_runner/features/runner/engine/collision_engine.dart';
import 'package:pepsi_runner/features/runner/engine/runner_physics.dart';
import 'package:pepsi_runner/features/runner/models/obstacle_model.dart';
import 'package:pepsi_runner/features/runner/models/item_model.dart';
import 'package:pepsi_runner/features/runner/models/checkpoint_model.dart';
import 'package:pepsi_runner/features/runner/models/runner_model.dart';

void main() {
  group('CollisionEngine', () {
    late CollisionEngine engine;

    setUp(() {
      engine = CollisionEngine();
    });

    test('jump obstacle is a hit when grounded in the same lane', () {
      final physics = RunnerPhysics(startLane: 1);
      final obstacle = ObstacleInstance(type: ObstacleType.cone, lane: 1, distance: 10);

      final hit = engine.checkObstacleHit(
        obstacle: obstacle,
        physics: physics,
        runnerDistance: 10,
      );

      expect(hit, isTrue);
    });

    test('jump obstacle is avoided when airborne', () {
      final physics = RunnerPhysics(startLane: 1);
      physics.jump();
      final obstacle = ObstacleInstance(type: ObstacleType.cone, lane: 1, distance: 10);

      final hit = engine.checkObstacleHit(
        obstacle: obstacle,
        physics: physics,
        runnerDistance: 10,
      );

      expect(hit, isFalse);
    });

    test('slide obstacle is a hit when not sliding', () {
      final physics = RunnerPhysics(startLane: 0);
      final obstacle = ObstacleInstance(type: ObstacleType.gate, lane: 0, distance: 5);

      final hit = engine.checkObstacleHit(
        obstacle: obstacle,
        physics: physics,
        runnerDistance: 5,
      );

      expect(hit, isTrue);
    });

    test('slide obstacle is avoided while sliding', () {
      final physics = RunnerPhysics(startLane: 0);
      physics.slide();
      final obstacle = ObstacleInstance(type: ObstacleType.gate, lane: 0, distance: 5);

      final hit = engine.checkObstacleHit(
        obstacle: obstacle,
        physics: physics,
        runnerDistance: 5,
      );

      expect(hit, isFalse);
    });

    test('obstacle in a different lane never counts as a hit', () {
      final physics = RunnerPhysics(startLane: 2);
      final obstacle = ObstacleInstance(type: ObstacleType.car, lane: 0, distance: 10);

      final hit = engine.checkObstacleHit(
        obstacle: obstacle,
        physics: physics,
        runnerDistance: 10,
      );

      expect(hit, isFalse);
    });

    test('item is collected when in range and same lane', () {
      final physics = RunnerPhysics(startLane: 1);
      final item = ItemInstance(type: ItemType.coin, lane: 1, distance: 10);

      final collected = engine.checkItemCollected(
        item: item,
        physics: physics,
        runnerDistance: 10,
      );

      expect(collected, isTrue);
    });

    test('magnet radius collects items outside the normal lane check', () {
      final physics = RunnerPhysics(startLane: 1);
      final item = ItemInstance(type: ItemType.coin, lane: 0, distance: 12);

      final collected = engine.checkItemCollected(
        item: item,
        physics: physics,
        runnerDistance: 10,
        magnetRadius: 5,
      );

      expect(collected, isTrue);
    });

    test('checkpoint is reached once runner distance passes it', () {
      const checkpoint = CheckpointModel(id: 1, distance: 100);
      expect(
        engine.checkCheckpointReached(checkpoint: checkpoint, runnerDistance: 99),
        isFalse,
      );
      expect(
        engine.checkCheckpointReached(checkpoint: checkpoint, runnerDistance: 100),
        isTrue,
      );
    });

    test('shield absorbs a hit without losing a life', () {
      final runner = RunnerModel(lives: 3, hasShield: true);
      final lostLife = engine.applyHit(runner);
      expect(lostLife, isFalse);
      expect(runner.hasShield, isFalse);
      expect(runner.lives, 3);
    });

    test('invincible runner never loses a life', () {
      final runner = RunnerModel(lives: 3, isInvincible: true);
      final lostLife = engine.applyHit(runner);
      expect(lostLife, isFalse);
      expect(runner.lives, 3);
    });

    test('normal hit reduces lives by one', () {
      final runner = RunnerModel(lives: 3);
      final lostLife = engine.applyHit(runner);
      expect(lostLife, isTrue);
      expect(runner.lives, 2);
    });
  });
}
