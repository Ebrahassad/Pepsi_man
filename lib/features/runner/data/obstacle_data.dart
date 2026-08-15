import '../models/obstacle_model.dart';

/// Static per-type obstacle configuration. Placement (lane/distance) is
/// generated at runtime by `TrackGenerator` / `LevelEngine`.
class ObstacleData {
  ObstacleData._();

  static const Map<ObstacleType, ObstacleModel> all = {
    ObstacleType.car: ObstacleModel(
      type: ObstacleType.car,
      assetPath: 'assets/images/obstacles/car.png',
      requiredAction: ObstacleAction.avoidLane,
      motion: ObstacleMotion.static_,
      width: 90,
      height: 110,
    ),
    ObstacleType.truck: ObstacleModel(
      type: ObstacleType.truck,
      assetPath: 'assets/images/obstacles/truck.png',
      requiredAction: ObstacleAction.avoidLane,
      motion: ObstacleMotion.movingLaneChange,
      width: 110,
      height: 140,
    ),
    ObstacleType.bus: ObstacleModel(
      type: ObstacleType.bus,
      assetPath: 'assets/images/obstacles/bus.png',
      requiredAction: ObstacleAction.avoidLane,
      motion: ObstacleMotion.crossLane,
      width: 120,
      height: 150,
    ),
    ObstacleType.barrier: ObstacleModel(
      type: ObstacleType.barrier,
      assetPath: 'assets/images/obstacles/barrier.png',
      requiredAction: ObstacleAction.jump,
      motion: ObstacleMotion.static_,
      width: 80,
      height: 60,
    ),
    ObstacleType.cone: ObstacleModel(
      type: ObstacleType.cone,
      assetPath: 'assets/images/obstacles/cone.png',
      requiredAction: ObstacleAction.jump,
      motion: ObstacleMotion.static_,
      width: 40,
      height: 45,
    ),
    ObstacleType.trashBin: ObstacleModel(
      type: ObstacleType.trashBin,
      assetPath: 'assets/images/obstacles/trash_bin.png',
      requiredAction: ObstacleAction.avoidLane,
      motion: ObstacleMotion.sideAppear,
      width: 55,
      height: 65,
    ),
    ObstacleType.constructionBarrier: ObstacleModel(
      type: ObstacleType.constructionBarrier,
      assetPath: 'assets/images/obstacles/construction_barrier.png',
      requiredAction: ObstacleAction.jump,
      motion: ObstacleMotion.static_,
      width: 90,
      height: 60,
    ),
    ObstacleType.container: ObstacleModel(
      type: ObstacleType.container,
      assetPath: 'assets/images/obstacles/container.png',
      requiredAction: ObstacleAction.avoidLane,
      motion: ObstacleMotion.static_,
      width: 130,
      height: 130,
    ),
    ObstacleType.gate: ObstacleModel(
      type: ObstacleType.gate,
      assetPath: 'assets/images/obstacles/gate.png',
      requiredAction: ObstacleAction.slide,
      motion: ObstacleMotion.static_,
      width: 140,
      height: 100,
    ),
    ObstacleType.lowBarrier: ObstacleModel(
      type: ObstacleType.lowBarrier,
      assetPath: 'assets/images/obstacles/barrier.png',
      requiredAction: ObstacleAction.jump,
      motion: ObstacleMotion.static_,
      width: 80,
      height: 45,
    ),
    ObstacleType.highBarrier: ObstacleModel(
      type: ObstacleType.highBarrier,
      assetPath: 'assets/images/obstacles/gate.png',
      requiredAction: ObstacleAction.slide,
      motion: ObstacleMotion.static_,
      width: 90,
      height: 120,
    ),
    ObstacleType.movingVehicle: ObstacleModel(
      type: ObstacleType.movingVehicle,
      assetPath: 'assets/images/obstacles/car.png',
      requiredAction: ObstacleAction.avoidLane,
      motion: ObstacleMotion.movingTowardPlayer,
      width: 90,
      height: 110,
    ),
    ObstacleType.roadBlock: ObstacleModel(
      type: ObstacleType.roadBlock,
      assetPath: 'assets/images/obstacles/road_block.png',
      requiredAction: ObstacleAction.jump,
      motion: ObstacleMotion.static_,
      width: 100,
      height: 55,
    ),
  };

  /// Obstacle sets grouped by world, matching the request's per-world lists.
  static const Map<int, List<ObstacleType>> byWorld = {
    1: [
      ObstacleType.car,
      ObstacleType.cone,
      ObstacleType.barrier,
      ObstacleType.trashBin,
      ObstacleType.roadBlock,
    ],
    2: [
      ObstacleType.movingVehicle,
      ObstacleType.truck,
      ObstacleType.barrier,
      ObstacleType.cone,
      ObstacleType.constructionBarrier,
    ],
    3: [
      ObstacleType.bus,
      ObstacleType.car,
      ObstacleType.constructionBarrier,
      ObstacleType.cone,
    ],
    4: [
      ObstacleType.container,
      ObstacleType.truck,
      ObstacleType.gate,
      ObstacleType.roadBlock,
      ObstacleType.barrier,
    ],
    5: [
      ObstacleType.movingVehicle,
      ObstacleType.truck,
      ObstacleType.bus,
      ObstacleType.gate,
      ObstacleType.roadBlock,
      ObstacleType.cone,
    ],
  };
}
