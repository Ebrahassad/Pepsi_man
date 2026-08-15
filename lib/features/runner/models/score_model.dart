class ScoreModel {
  int score;
  int cans;
  int coins;
  double distanceMeters;
  int combo;
  int comboTier; // index into GameConstants.comboMultipliers

  ScoreModel({
    this.score = 0,
    this.cans = 0,
    this.coins = 0,
    this.distanceMeters = 0,
    this.combo = 0,
    this.comboTier = 0,
  });

  void reset() {
    score = 0;
    cans = 0;
    coins = 0;
    distanceMeters = 0;
    combo = 0;
    comboTier = 0;
  }
}
