import '../../../core/constants/game_constants.dart';
import '../models/score_model.dart';
import '../models/item_model.dart';

/// Handles score accumulation, combo tracking, and item-value lookups.
/// Kept separate from CollisionEngine so scoring rules can change without
/// touching collision detection.
class ScoreEngine {
  final ScoreModel score;
  double _timeSinceLastPickup = 0;

  ScoreEngine({ScoreModel? initial}) : score = initial ?? ScoreModel();

  void update(double dt) {
    if (score.combo > 0) {
      _timeSinceLastPickup += dt;
      if (_timeSinceLastPickup > GameConstants.comboWindowSeconds) {
        _resetCombo();
      }
    }
  }

  void registerItem(ItemType type) {
    _timeSinceLastPickup = 0;

    switch (type) {
      case ItemType.coin:
        _addScore(GameConstants.scoreCoin);
        score.coins += 1;
        _bumpCombo();
        break;
      case ItemType.energyCan:
        _addScore(GameConstants.scoreCan);
        score.cans += 1;
        _bumpCombo();
        break;
      case ItemType.bonusCan:
        _addScore(GameConstants.scoreBonusCan);
        score.cans += 1;
        _bumpCombo();
        break;
      case ItemType.magnet:
      case ItemType.shield:
      case ItemType.speedBoost:
      case ItemType.invincibility:
        // Power-ups don't directly add score or affect combo.
        break;
    }
  }

  void registerObstacleAvoided() {
    _addScore(GameConstants.scoreObstacleAvoided);
  }

  void registerLevelCompletion() {
    _addScore(GameConstants.scoreLevelCompletion);
  }

  void _bumpCombo() {
    score.combo += 1;
    if (score.combo % GameConstants.comboThreshold == 0) {
      score.comboTier = (score.comboTier + 1).clamp(
        0,
        GameConstants.comboMultipliers.length - 1,
      );
    }
  }

  void _resetCombo() {
    score.combo = 0;
    score.comboTier = 0;
    _timeSinceLastPickup = 0;
  }

  void _addScore(int base) {
    final multiplier = GameConstants.comboMultipliers[score.comboTier];
    score.score += (base * multiplier).round();
  }

  void updateDistance(double distanceMeters) {
    score.distanceMeters = distanceMeters;
  }

  void reset() {
    score.reset();
    _timeSinceLastPickup = 0;
  }
}
