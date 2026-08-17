import '../models/level_model.dart';
import '../models/track_segment.dart';
import '../../../core/constants/game_constants.dart';

/// All 50 levels (5 worlds x 10 levels) generated from formulas — this is
/// intentionally NOT 50 hand-authored entries. Difficulty, distance, speed
/// and goals scale smoothly with world + index, per the request's rule
/// that levels must be data-driven rather than 50 separate screens.
class LevelData {
  LevelData._();

  static final List<LevelModel> levels = _generateLevels();

  static LevelModel byId(int id) => levels.firstWhere((l) => l.id == id);

  static List<LevelModel> byWorld(int worldId) =>
      levels.where((l) => l.worldId == worldId).toList();

  static List<LevelModel> _generateLevels() {
    final result = <LevelModel>[];

    for (int worldId = 1; worldId <= GameConstants.worldCount; worldId++) {
      for (int index = 1; index <= GameConstants.levelsPerWorld; index++) {
        final globalId = (worldId - 1) * GameConstants.levelsPerWorld + index;
        final difficulty = (((worldId - 1) * 2) + (index / 5).ceil()).clamp(1, 10);

        // Base distance grows with world and level index.
        final distance = 400.0 +
            (worldId - 1) * 300.0 +
            (index - 1) * 60.0;

final baseSpeed = GameConstants.defaultBaseSpeed +
    (worldId - 1) * 25.0 +
    (index - 1) * 3.0;

final maxSpeed = GameConstants.defaultMaxSpeed +
    (worldId - 1) * 35.0 +
    (index - 1) * 4.0;

final acceleration = GameConstants.defaultAcceleration +
    (worldId - 1) * 0.4;

        // Cycle through goal types so variety matches the request's examples
        // (reach distance / collect cans / collect coins / survive / no-death).
        final goal = _goalForLevel(worldId, index, distance);

        final targetScore = (distance * 1.2).round() +
            (index * 40) +
            (worldId * 100);

        result.add(
          LevelModel(
            id: globalId,
            worldId: worldId,
            indexInWorld: index,
            difficulty: difficulty.toInt(),
            distanceMeters: distance,
            baseSpeed: baseSpeed,
            maxSpeed: maxSpeed,
            acceleration: acceleration,
            goal: goal,
            starRequirements: StarRequirements(targetScore: targetScore),
            segmentWeights: _segmentWeightsForWorld(worldId, index),
            powerUpChance: (0.08 + worldId * 0.01).clamp(0.05, 0.2),
            checkpointIntervalMeters: distance / 4,
          ),
        );
      }
    }

    return result;
  }

  static LevelGoal _goalForLevel(int worldId, int index, double distance) {
    final cycle = index % 5;
    switch (cycle) {
      case 1:
        return LevelGoal(type: LevelGoalType.reachDistance, value: distance);
      case 2:
        return LevelGoal(type: LevelGoalType.collectCanCount, value: 60 + worldId * 15);
      case 3:
        return LevelGoal(type: LevelGoalType.reachDistance, value: distance);
      case 4:
        return LevelGoal(type: LevelGoalType.collectCoinCount, value: 30 + worldId * 8);
      case 0:
        // Every 5th level in a world is a tougher survive/no-death challenge.
        return index == 10
            ? LevelGoal(type: LevelGoalType.finishWithoutDeath, value: 1)
            : LevelGoal(type: LevelGoalType.surviveTime, value: 45 + worldId * 5);
      default:
        return LevelGoal(type: LevelGoalType.reachDistance, value: distance);
    }
  }

  static Map<TrackSegmentType, int> _segmentWeightsForWorld(int worldId, int index) {
    // Later worlds/levels lean more on jump/slide/speed/traffic sections.
    final intensity = worldId + (index / 3).floor();
    return {
      TrackSegmentType.straight: 10,
      TrackSegmentType.leftPattern: 6,
      TrackSegmentType.rightPattern: 6,
      TrackSegmentType.jumpSection: 5 + intensity,
      TrackSegmentType.slideSection: 4 + intensity,
      TrackSegmentType.trafficSection: 5 + intensity,
      TrackSegmentType.coinSection: 7,
      TrackSegmentType.speedSection: 2 + (worldId >= 4 ? intensity : 0),
      TrackSegmentType.checkpointSection: 3,
    };
  }
}
