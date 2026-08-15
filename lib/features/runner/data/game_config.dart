import '../../../core/constants/game_constants.dart';
import '../models/level_model.dart';
import 'level_data.dart';
import 'world_data.dart';

/// Single entry point for cross-cutting game configuration/lookups, so
/// screens never need to import data files directly for common queries.
class GameConfig {
  GameConfig._();

  static int get worldCount => GameConstants.worldCount;
  static int get levelsPerWorld => GameConstants.levelsPerWorld;
  static int get totalLevels => GameConstants.totalLevels;
  static int get startingLives => GameConstants.startingLives;

  static LevelModel levelById(int id) => LevelData.byId(id);

  static List<LevelModel> levelsForWorld(int worldId) => LevelData.byWorld(worldId);

  static String worldNameFor(int worldId, {required bool arabic}) {
    final world = WorldData.byId(worldId);
    return arabic ? world.nameAr : world.nameEn;
  }

  /// Global level id (1..50) from a world + in-world index (1..10).
  static int globalLevelId(int worldId, int indexInWorld) =>
      (worldId - 1) * levelsPerWorld + indexInWorld;

  static bool isLastLevelOfWorld(int indexInWorld) => indexInWorld == levelsPerWorld;

  static bool isFinalWorld(int worldId) => worldId == worldCount;
}
