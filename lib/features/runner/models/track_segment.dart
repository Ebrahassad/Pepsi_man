import 'obstacle_model.dart';
import 'item_model.dart';

enum TrackSegmentType {
  straight,
  leftPattern,
  rightPattern,
  jumpSection,
  slideSection,
  trafficSection,
  coinSection,
  speedSection,
  checkpointSection,
}

/// A short, reusable chunk of track. `LevelEngine`/`TrackGenerator` stitch
/// many segments together to build a level's full length without needing
/// a hand-authored screen per level.
class TrackSegment {
  final TrackSegmentType type;
  final double lengthMeters;
  final List<ObstacleInstance> obstacles;
  final List<ItemInstance> items;
  final bool hasCheckpoint;

  const TrackSegment({
    required this.type,
    required this.lengthMeters,
    this.obstacles = const [],
    this.items = const [],
    this.hasCheckpoint = false,
  });
}
