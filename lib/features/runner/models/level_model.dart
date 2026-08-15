import 'track_segment.dart';

enum LevelGoalType {
  reachDistance,
  collectCanCount,
  collectCoinCount,
  surviveTime,
  finishWithoutDeath,
}

class LevelGoal {
  final LevelGoalType type;
  final num value;

  const LevelGoal({required this.type, required this.value});
}

class StarRequirements {
  /// Reference/target score used by StarCalculator to derive 1–3 stars.
  final int targetScore;

  const StarRequirements({required this.targetScore});
}

/// A single, fully data-driven level. No level has its own screen — all
/// 50 levels are generated/played through `LevelEngine` + `TrackGenerator`
/// reading these values.
class LevelModel {
  final int id; // global id 1..50
  final int worldId; // 1..5
  final int indexInWorld; // 1..10
  final int difficulty; // 1..10
  final double distanceMeters;
  final double baseSpeed;
  final double maxSpeed;
  final double acceleration;
  final LevelGoal goal;
  final StarRequirements starRequirements;
  final Map<TrackSegmentType, int> segmentWeights;
  final double powerUpChance; // 0..1 chance per eligible segment
  final double checkpointIntervalMeters;

  const LevelModel({
    required this.id,
    required this.worldId,
    required this.indexInWorld,
    required this.difficulty,
    required this.distanceMeters,
    required this.baseSpeed,
    required this.maxSpeed,
    required this.acceleration,
    required this.goal,
    required this.starRequirements,
    required this.segmentWeights,
    this.powerUpChance = 0.12,
    this.checkpointIntervalMeters = 250,
  });
}
