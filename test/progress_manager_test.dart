import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pepsi_runner/features/runner/managers/game_progress_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GameProgressManager', () {
    test('starts with world 1 and level 1 unlocked only', () async {
      final manager = GameProgressManager();
      await manager.load();

      expect(manager.isWorldUnlocked(1), isTrue);
      expect(manager.isWorldUnlocked(2), isFalse);
      expect(manager.isLevelUnlocked(1), isTrue);
      expect(manager.isLevelUnlocked(2), isFalse);
    });

    test('completing a level unlocks the next level in the same world', () async {
      final manager = GameProgressManager();
      await manager.load();

      await manager.recordLevelResult(
        levelId: 1,
        worldId: 1,
        indexInWorld: 1,
        score: 500,
        stars: 3,
        completed: true,
        coinsEarned: 10,
        cansEarned: 5,
      );

      expect(manager.isLevelUnlocked(2), isTrue);
      expect(manager.starsFor(1), 3);
      expect(manager.bestScoreFor(1), 500);
    });

    test('completing the last level of a world unlocks the next world', () async {
      final manager = GameProgressManager();
      await manager.load();

      await manager.recordLevelResult(
        levelId: 10,
        worldId: 1,
        indexInWorld: 10,
        score: 900,
        stars: 3,
        completed: true,
        coinsEarned: 20,
        cansEarned: 10,
      );

      expect(manager.isWorldUnlocked(2), isTrue);
      expect(manager.isLevelUnlocked(11), isTrue);
    });

    test('failing a level does not unlock the next one', () async {
      final manager = GameProgressManager();
      await manager.load();

      await manager.recordLevelResult(
        levelId: 1,
        worldId: 1,
        indexInWorld: 1,
        score: 50,
        stars: 0,
        completed: false,
        coinsEarned: 2,
        cansEarned: 1,
      );

      expect(manager.isLevelUnlocked(2), isFalse);
    });

    test('bestScoreFor keeps the higher of two scores', () async {
      final manager = GameProgressManager();
      await manager.load();

      await manager.recordLevelResult(
        levelId: 1,
        worldId: 1,
        indexInWorld: 1,
        score: 300,
        stars: 1,
        completed: true,
        coinsEarned: 0,
        cansEarned: 0,
      );
      await manager.recordLevelResult(
        levelId: 1,
        worldId: 1,
        indexInWorld: 1,
        score: 200,
        stars: 1,
        completed: true,
        coinsEarned: 0,
        cansEarned: 0,
      );

      expect(manager.bestScoreFor(1), 300);
    });

    test('spendCoins fails when balance is insufficient', () async {
      final manager = GameProgressManager();
      await manager.load();

      final success = await manager.spendCoins(100);
      expect(success, isFalse);
    });

    test('spendCoins succeeds and deducts balance when sufficient', () async {
      final manager = GameProgressManager();
      await manager.load();
      await manager.addCoins(150);

      final success = await manager.spendCoins(100);
      expect(success, isTrue);
      expect(manager.progress.totalCoins, 50);
    });

    test('resetProgress restores default state', () async {
      final manager = GameProgressManager();
      await manager.load();
      await manager.addCoins(500);

      await manager.resetProgress();

      expect(manager.progress.totalCoins, 0);
      expect(manager.isWorldUnlocked(1), isTrue);
      expect(manager.isWorldUnlocked(2), isFalse);
    });
  });
}
