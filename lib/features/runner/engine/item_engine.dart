import '../../../core/constants/game_constants.dart';
import '../models/item_model.dart';
import '../models/track_segment.dart';
import '../models/power_up_model.dart';
import '../data/item_data.dart';
import 'object_pool.dart';

/// Manages active collectible/power-up instances for the current run.
/// Backed by a real [ObjectPool] so items are recycled instead of
/// reallocated every spawn (rule 47).
class ItemEngine {
  final List<ItemInstance> active = [];
  final Map<PowerUpType, ActivePowerUp> activePowerUps = {};

  late final ObjectPool<ItemInstance> _pool = ObjectPool<ItemInstance>(
    size: GameConstants.itemPoolSize,
    factory: () => ItemInstance(type: ItemType.coin, lane: 1, distance: 0),
    reset: (i) {
      i.isCollected = false;
    },
  );

  void spawnFromSegment(TrackSegment segment, double segmentStartDistance) {
    for (final template in segment.items) {
      final instance = _pool.acquire();
      instance.type = template.type;
      instance.lane = template.lane;
      instance.distance = segmentStartDistance + template.distance;
      instance.isCollected = false;
      active.add(instance);
    }
  }

  void update(double dt) {
    activePowerUps.removeWhere((type, active) {
      if (active.remainingSeconds > 0) {
        active.remainingSeconds -= dt;
      }
      return active.remainingSeconds <= 0 && active.remainingHits <= 0;
    });
  }

  void activatePowerUp(PowerUpType type) {
    final config = ItemData.powerUps[type];
    if (config == null) return;

    if (type == PowerUpType.shield) {
      activePowerUps[type] = ActivePowerUp(type: type, remainingHits: 1);
    } else {
      activePowerUps[type] = ActivePowerUp(
        type: type,
        remainingSeconds: config.durationSeconds,
      );
    }
  }

  bool consumeShieldHit() {
    final shield = activePowerUps[PowerUpType.shield];
    if (shield == null || shield.remainingHits <= 0) return false;
    activePowerUps.remove(PowerUpType.shield);
    return true;
  }

  bool get hasMagnet => activePowerUps.containsKey(PowerUpType.magnet);
  bool get hasSpeedBoost => activePowerUps.containsKey(PowerUpType.speedBoost);
  bool get hasInvincibility => activePowerUps.containsKey(PowerUpType.invincibility);
  bool get hasShield => activePowerUps.containsKey(PowerUpType.shield);

  void collect(ItemInstance item) {
    item.isCollected = true;
  }

  List<ItemInstance> itemsNear(double runnerDistance, {double range = 15}) {
    return active
        .where((i) => !i.isCollected && (i.distance - runnerDistance).abs() <= range)
        .toList();
  }

  void pruneCollectedAndPassed(double runnerDistance) {
    final toRelease = active
        .where((i) => i.isCollected || i.distance < runnerDistance - 20)
        .toList();
    for (final item in toRelease) {
      active.remove(item);
      _pool.release(item);
    }
  }

  void reset() {
    for (final item in active) {
      _pool.release(item);
    }
    active.clear();
    activePowerUps.clear();
  }

  int get pooledCount => _pool.totalCount;
  int get activePoolUsage => _pool.activeCount;
}
