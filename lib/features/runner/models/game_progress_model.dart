enum GameState {
  loading,
  menu,
  worldMap,
  levelSelect,
  playing,
  paused,
  victory,
  gameOver,
  finalVictory,
}

/// Persisted player progress across all worlds/levels.
class GameProgressModel {
  int currentWorld;
  int currentLevel;
  Set<int> unlockedWorlds;
  Set<int> unlockedLevels;
  Map<int, int> starsByLevel; // levelId -> stars (0-3)
  Map<int, int> bestScoreByLevel; // levelId -> best score
  int totalCoins;
  int totalCans;

  GameProgressModel({
    this.currentWorld = 1,
    this.currentLevel = 1,
    Set<int>? unlockedWorlds,
    Set<int>? unlockedLevels,
    Map<int, int>? starsByLevel,
    Map<int, int>? bestScoreByLevel,
    this.totalCoins = 0,
    this.totalCans = 0,
  })  : unlockedWorlds = unlockedWorlds ?? {1},
        unlockedLevels = unlockedLevels ?? {1},
        starsByLevel = starsByLevel ?? {},
        bestScoreByLevel = bestScoreByLevel ?? {};

  int totalStars() => starsByLevel.values.fold(0, (a, b) => a + b);

  Map<String, dynamic> toJson() => {
        'currentWorld': currentWorld,
        'currentLevel': currentLevel,
        'unlockedWorlds': unlockedWorlds.toList(),
        'unlockedLevels': unlockedLevels.toList(),
        'starsByLevel': starsByLevel.map((k, v) => MapEntry(k.toString(), v)),
        'bestScoreByLevel': bestScoreByLevel.map((k, v) => MapEntry(k.toString(), v)),
        'totalCoins': totalCoins,
        'totalCans': totalCans,
      };

  factory GameProgressModel.fromJson(Map<String, dynamic> json) {
    return GameProgressModel(
      currentWorld: json['currentWorld'] as int? ?? 1,
      currentLevel: json['currentLevel'] as int? ?? 1,
      unlockedWorlds: ((json['unlockedWorlds'] as List?)?.cast<int>().toSet()) ?? {1},
      unlockedLevels: ((json['unlockedLevels'] as List?)?.cast<int>().toSet()) ?? {1},
      starsByLevel: ((json['starsByLevel'] as Map?)?.map(
            (k, v) => MapEntry(int.parse(k as String), v as int),
          )) ??
          {},
      bestScoreByLevel: ((json['bestScoreByLevel'] as Map?)?.map(
            (k, v) => MapEntry(int.parse(k as String), v as int),
          )) ??
          {},
      totalCoins: json['totalCoins'] as int? ?? 0,
      totalCans: json['totalCans'] as int? ?? 0,
    );
  }
}
