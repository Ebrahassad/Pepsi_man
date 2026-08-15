/// Computes the 1–3 star rating for a completed level.
///
/// Rules:
/// - 1 star: level finished at all.
/// - 2 stars: finished with a score >= [goodScoreThreshold] of the level's
///   target score (i.e. "Good Score").
/// - 3 stars: finished with a score >= [excellentScoreThreshold] of the
///   level's target score, AND without losing all checkpoints (no-death
///   bonus is handled by the caller passing `perfect: true`).
class StarCalculator {
  StarCalculator._();

  static const double goodScoreRatio = 0.6;
  static const double excellentScoreRatio = 0.9;

  /// [score] is the score achieved. [targetScore] is the level's reference
  /// score (e.g. `LevelModel.starRequirements` best-case score).
  /// [perfect] means the level was finished without any hit.
  static int calculateStars({
    required int score,
    required int targetScore,
    bool finished = true,
    bool perfect = false,
  }) {
    if (!finished || targetScore <= 0) return 0;

    final ratio = score / targetScore;

    if (perfect || ratio >= excellentScoreRatio) return 3;
    if (ratio >= goodScoreRatio) return 2;
    return 1;
  }
}
