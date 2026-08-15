import 'package:flutter_test/flutter_test.dart';
import 'package:pepsi_runner/features/runner/data/level_data.dart';
import 'package:pepsi_runner/features/runner/engine/level_engine.dart';
import 'package:pepsi_runner/features/runner/models/level_model.dart';

void main() {
  group('LevelData', () {
    test('generates exactly 50 levels across 5 worlds', () {
      expect(LevelData.levels.length, 50);
    });

    test('each world has exactly 10 levels', () {
      for (int worldId = 1; worldId <= 5; worldId++) {
        expect(LevelData.byWorld(worldId).length, 10);
      }
    });

    test('global level ids are unique and sequential 1..50', () {
      final ids = LevelData.levels.map((l) => l.id).toList()..sort();
      expect(ids, List.generate(50, (i) => i + 1));
    });

    test('byId retrieves the matching level', () {
      final level = LevelData.byId(25);
      expect(level.id, 25);
    });
  });

  group('LevelEngine', () {
    test('reachDistance goal completes once distance target is met', () {
      final level = LevelData.levels.firstWhere(
        (l) => l.goal.type == LevelGoalType.reachDistance,
      );
      final engine = LevelEngine(level: level, seed: 1);

      engine.update(0.1, level.goal.value.toDouble());
      expect(engine.progress.isComplete, isTrue);
    });

    test('collectCanCount goal completes once enough cans are registered', () {
      final level = LevelData.levels.firstWhere(
        (l) => l.goal.type == LevelGoalType.collectCanCount,
      );
      final engine = LevelEngine(level: level, seed: 1);

      for (int i = 0; i < level.goal.value; i++) {
        engine.registerCan();
      }
      engine.update(0.1, 0);
      expect(engine.progress.isComplete, isTrue);
    });

    test('checkpoints are recorded as the runner passes them', () {
      final level = LevelData.byId(1);
      final engine = LevelEngine(level: level, seed: 1);

      if (engine.checkpoints.isNotEmpty) {
        final firstCheckpoint = engine.checkpoints.first;
        engine.update(0.1, firstCheckpoint.distance);
        expect(engine.lastReachedCheckpoint, isNotNull);
        expect(engine.lastReachedCheckpoint!.id, firstCheckpoint.id);
      }
    });

    test('generated track covers at least the level distance', () {
      final level = LevelData.byId(10);
      final engine = LevelEngine(level: level, seed: 1);
      final totalLength = engine.segments.fold<double>(0, (sum, s) => sum + s.lengthMeters);
      expect(totalLength, greaterThanOrEqualTo(level.distanceMeters));
    });
  });
}
