import '../models/level_model.dart';
import '../models/checkpoint_model.dart';
import '../models/track_segment.dart';
import 'track_generator.dart';
import 'collision_engine.dart';

class LevelProgress {
  double distanceMeters = 0;
  int cansCollected = 0;
  int coinsCollected = 0;
  double survivalSeconds = 0;
  bool tookHit = false;
  bool isComplete = false;
}

/// Owns the current level's generated track, checkpoints, and goal
/// progress. `RunnerEngine` feeds it distance/time/collection events;
/// it reports back whether the level's goal has been met.
class LevelEngine {
  final LevelModel level;
  final TrackGenerator _generator;
  final CollisionEngine _collisionEngine = CollisionEngine();
  late final List<TrackSegment> segments;
  final List<CheckpointModel> checkpoints = [];
  final LevelProgress progress = LevelProgress();

  int _lastCheckpointIndex = -1;
  double _cumulativeDistance = 0;

  LevelEngine({required this.level, int? seed})
      : _generator = TrackGenerator(seed: seed) {
    segments = _generator.generate(level);
    _buildCheckpoints();
  }

  void _buildCheckpoints() {
    double distance = 0;
    int id = 0;
    for (final segment in segments) {
      if (segment.hasCheckpoint) {
        id += 1;
        checkpoints.add(CheckpointModel(id: id, distance: distance));
      }
      distance += segment.lengthMeters;
    }
  }

  /// Returns the start distance for each segment (precomputed once).
  List<double> get segmentStartDistances {
    final starts = <double>[];
    double d = 0;
    for (final s in segments) {
      starts.add(d);
      d += s.lengthMeters;
    }
    return starts;
  }

  void update(double dt, double runnerDistance) {
    progress.distanceMeters = runnerDistance;
    progress.survivalSeconds += dt;

    for (int i = 0; i < checkpoints.length; i++) {
      if (i <= _lastCheckpointIndex) continue;
      if (_collisionEngine.checkCheckpointReached(
        checkpoint: checkpoints[i],
        runnerDistance: runnerDistance,
      )) {
        _lastCheckpointIndex = i;
      }
    }

    _checkGoal();
  }

  CheckpointModel? get lastReachedCheckpoint =>
      _lastCheckpointIndex >= 0 ? checkpoints[_lastCheckpointIndex] : null;

  void registerCan() => progress.cansCollected += 1;
  void registerCoin() => progress.coinsCollected += 1;
  void registerHit() => progress.tookHit = true;

  void _checkGoal() {
    switch (level.goal.type) {
      case LevelGoalType.reachDistance:
        if (progress.distanceMeters >= level.goal.value) {
          progress.isComplete = true;
        }
        break;
      case LevelGoalType.collectCanCount:
        if (progress.cansCollected >= level.goal.value) {
          progress.isComplete = true;
        }
        break;
      case LevelGoalType.collectCoinCount:
        if (progress.coinsCollected >= level.goal.value) {
          progress.isComplete = true;
        }
        break;
      case LevelGoalType.surviveTime:
        if (progress.survivalSeconds >= level.goal.value) {
          progress.isComplete = true;
        }
        break;
      case LevelGoalType.finishWithoutDeath:
        if (progress.distanceMeters >= level.distanceMeters) {
          progress.isComplete = !progress.tookHit;
        }
        break;
    }
  }

  double get goalProgressRatio {
    switch (level.goal.type) {
      case LevelGoalType.reachDistance:
      case LevelGoalType.finishWithoutDeath:
        return (progress.distanceMeters / level.goal.value).clamp(0, 1);
      case LevelGoalType.collectCanCount:
        return (progress.cansCollected / level.goal.value).clamp(0, 1);
      case LevelGoalType.collectCoinCount:
        return (progress.coinsCollected / level.goal.value).clamp(0, 1);
      case LevelGoalType.surviveTime:
        return (progress.survivalSeconds / level.goal.value).clamp(0, 1);
    }
  }
}
