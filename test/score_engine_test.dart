import 'package:flutter_test/flutter_test.dart';
import 'package:pepsi_runner/core/constants/game_constants.dart';
import 'package:pepsi_runner/features/runner/engine/score_engine.dart';
import 'package:pepsi_runner/features/runner/models/item_model.dart';
import 'package:pepsi_runner/core/utils/star_calculator.dart';

void main() {
  group('ScoreEngine', () {
    test('collecting a coin adds coin score and increments coin count', () {
      final engine = ScoreEngine();
      engine.registerItem(ItemType.coin);
      expect(engine.score.score, GameConstants.scoreCoin);
      expect(engine.score.coins, 1);
    });

    test('collecting a can adds can score and increments can count', () {
      final engine = ScoreEngine();
      engine.registerItem(ItemType.energyCan);
      expect(engine.score.score, GameConstants.scoreCan);
      expect(engine.score.cans, 1);
    });

    test('bonus can awards the bonus score value', () {
      final engine = ScoreEngine();
      engine.registerItem(ItemType.bonusCan);
      expect(engine.score.score, GameConstants.scoreBonusCan);
    });

    test('power-up items do not add score or affect combo', () {
      final engine = ScoreEngine();
      engine.registerItem(ItemType.shield);
      expect(engine.score.score, 0);
      expect(engine.score.combo, 0);
    });

    test('combo increases with consecutive pickups', () {
      final engine = ScoreEngine();
      for (int i = 0; i < GameConstants.comboThreshold; i++) {
        engine.registerItem(ItemType.coin);
      }
      expect(engine.score.combo, GameConstants.comboThreshold);
      expect(engine.score.comboTier, 1);
    });

    test('combo resets after the combo window elapses with no pickups', () {
      final engine = ScoreEngine();
      engine.registerItem(ItemType.coin);
      expect(engine.score.combo, 1);
      engine.update(GameConstants.comboWindowSeconds + 0.1);
      expect(engine.score.combo, 0);
      expect(engine.score.comboTier, 0);
    });

    test('registerLevelCompletion adds the completion bonus', () {
      final engine = ScoreEngine();
      engine.registerLevelCompletion();
      expect(engine.score.score, GameConstants.scoreLevelCompletion);
    });

    test('reset clears score, combo, and collected counts', () {
      final engine = ScoreEngine();
      engine.registerItem(ItemType.coin);
      engine.registerItem(ItemType.energyCan);
      engine.reset();
      expect(engine.score.score, 0);
      expect(engine.score.coins, 0);
      expect(engine.score.cans, 0);
      expect(engine.score.combo, 0);
    });
  });

  group('StarCalculator', () {
    test('unfinished level always gets 0 stars', () {
      final stars = StarCalculator.calculateStars(
        score: 1000,
        targetScore: 500,
        finished: false,
      );
      expect(stars, 0);
    });

    test('finishing with a low score gets 1 star', () {
      final stars = StarCalculator.calculateStars(score: 100, targetScore: 500);
      expect(stars, 1);
    });

    test('finishing with a good score gets 2 stars', () {
      final stars = StarCalculator.calculateStars(score: 350, targetScore: 500);
      expect(stars, 2);
    });

    test('finishing with an excellent score gets 3 stars', () {
      final stars = StarCalculator.calculateStars(score: 480, targetScore: 500);
      expect(stars, 3);
    });

    test('a perfect (no-hit) run always gets 3 stars', () {
      final stars = StarCalculator.calculateStars(
        score: 50,
        targetScore: 500,
        perfect: true,
      );
      expect(stars, 3);
    });
  });
}
