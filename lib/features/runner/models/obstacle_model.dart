enum ObstacleType {
  car,
  truck,
  bus,
  barrier,
  cone,
  trashBin,
  constructionBarrier,
  container,
  gate,
  lowBarrier,
  highBarrier,
  movingVehicle,
  roadBlock,
}

/// How the player must react to an obstacle.
enum ObstacleAction { jump, slide, avoidLane, any }

/// How the obstacle behaves in the world (static vs moving in traffic).
enum ObstacleMotion { static_, movingLaneChange, movingTowardPlayer, crossLane, sideAppear }

/// Static configuration for a single obstacle type — asset, required
/// player action, and default motion behavior. Per-placement data
/// (which lane, at what distance) lives in `LevelModel`/`TrackSegment`.
class ObstacleModel {
  final ObstacleType type;
  final String assetPath;
  final ObstacleAction requiredAction;
  final ObstacleMotion motion;
  final double width;
  final double height;

  const ObstacleModel({
    required this.type,
    required this.assetPath,
    required this.requiredAction,
    required this.motion,
    required this.width,
    required this.height,
  });
}

/// A concrete obstacle placed on the track at runtime. `type` is mutable
/// (not final) so instances can be recycled by `ObjectPool` instead of
/// reallocated every time a new obstacle spawns.
class ObstacleInstance {
  ObstacleType type;
  int lane;
  double distance; // meters from level start
  bool isHit;
  bool isPassed;

  /// Internal timer used by movingLaneChange/crossLane motion behaviors.
  double motionTimer;

  /// For `ObstacleMotion.sideAppear`: false until the obstacle is close
  /// enough to "appear" from the side — invisible and non-collidable
  /// before that.
  bool hasAppeared;

  ObstacleInstance({
    required this.type,
    required this.lane,
    required this.distance,
    this.isHit = false,
    this.isPassed = false,
    this.motionTimer = 0,
    this.hasAppeared = true,
  });
}
