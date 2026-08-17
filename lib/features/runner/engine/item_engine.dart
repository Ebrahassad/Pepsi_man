import '../../../core/constants/game_constants.dart';
import '../models/item_model.dart';
import '../models/track_segment.dart';
import '../models/power_up_model.dart';
import '../data/item_data.dart';
import 'object_pool.dart';

/// Manages active collectible/power-up instances for the current run.
///
/// Items are pooled and recycled. Lookup distance scales with runner speed
/// so fast levels do not miss collectibles between frames.
class ItemEngine {
  final List<ItemInstance> active = [];

  final Map<PowerUpType, ActivePowerUp>
      activePowerUps = {};

  late final ObjectPool<ItemInstance> _pool =
      ObjectPool<ItemInstance>(
    size: GameConstants.itemPoolSize,
    factory: () => ItemInstance(
      type: ItemType.coin,
      lane: 1,
      distance: 0,
    ),
    reset: (i) {
      i.isCollected = false;
    },
  );

  // ---------------------------------------------------------------------------
  // SPAWN
  // ---------------------------------------------------------------------------

  void spawnFromSegment(
    TrackSegment segment,
    double segmentStartDistance,
  ) {
    for (final template in segment.items) {
      final instance = _pool.acquire();

      instance.type = template.type;
      instance.lane = template.lane;
      instance.distance =
          segmentStartDistance +
              template.distance;

      instance.isCollected = false;

      active.add(instance);
    }
  }

  // ---------------------------------------------------------------------------
  // POWER UPS
  // ---------------------------------------------------------------------------

  void update(double dt) {
    if (dt <= 0) return;

    activePowerUps.removeWhere(
      (type, activePowerUp) {
        if (activePowerUp.remainingSeconds >
            0) {
          activePowerUp.remainingSeconds -= dt;
        }

        return activePowerUp.remainingSeconds <=
                0 &&
            activePowerUp.remainingHits <= 0;
      },
    );
  }

  void activatePowerUp(
    PowerUpType type,
  ) {
    final config =
        ItemData.powerUps[type];

    if (config == null) return;

    if (type == PowerUpType.shield) {
      activePowerUps[type] =
          ActivePowerUp(
        type: type,
        remainingHits: 1,
      );
    } else {
      activePowerUps[type] =
          ActivePowerUp(
        type: type,
        remainingSeconds:
            config.durationSeconds,
      );
    }
  }

  bool consumeShieldHit() {
    final shield =
        activePowerUps[
            PowerUpType.shield];

    if (shield == null ||
        shield.remainingHits <= 0) {
      return false;
    }

    activePowerUps.remove(
      PowerUpType.shield,
    );

    return true;
  }

  bool get hasMagnet =>
      activePowerUps.containsKey(
        PowerUpType.magnet,
      );

  bool get hasSpeedBoost =>
      activePowerUps.containsKey(
        PowerUpType.speedBoost,
      );

  bool get hasInvincibility =>
      activePowerUps.containsKey(
        PowerUpType.invincibility,
      );

  bool get hasShield =>
      activePowerUps.containsKey(
        PowerUpType.shield,
      );

  // ---------------------------------------------------------------------------
  // COLLECTION
  // ---------------------------------------------------------------------------

  void collect(ItemInstance item) {
    item.isCollected = true;
  }

  // ---------------------------------------------------------------------------
  // LOOKUP
  // ---------------------------------------------------------------------------

  List<ItemInstance> itemsNear(
    double runnerDistance, {
    double? range,
    double forwardSpeed =
        GameConstants.defaultBaseSpeed,
  }) {
    // The old lookup was fixed at 15 units.
    //
    // The lookup window now scales with speed.
    // This prevents collectibles from being skipped at high speed.
    final effectiveRange =
        (range ??
                (forwardSpeed * 0.35))
            .clamp(60.0, 300.0);

    return active
        .where(
          (i) =>
              !i.isCollected &&
              (i.distance -
                          runnerDistance)
                      .abs() <=
                  effectiveRange,
        )
        .toList();
  }

  // ---------------------------------------------------------------------------
  // CLEANUP
  // ---------------------------------------------------------------------------

  void pruneCollectedAndPassed(
    double runnerDistance,
  ) {
    final releaseDistance =
        runnerDistance - 80;

    final toRelease = active
        .where(
          (i) =>
              i.isCollected ||
              i.distance <
                  releaseDistance,
        )
        .toList();

    for (final item in toRelease) {
      active.remove(item);
      _pool.release(item);
    }
  }

  // ---------------------------------------------------------------------------
  // RESET
  // ---------------------------------------------------------------------------

  void reset() {
    for (final item in active) {
      _pool.release(item);
    }

    active.clear();
    activePowerUps.clear();
  }

  // ---------------------------------------------------------------------------
  // POOL INFO
  // ---------------------------------------------------------------------------

  int get pooledCount =>
      _pool.totalCount;

  int get activePoolUsage =>
      _pool.activeCount;
}