enum ItemType { coin, energyCan, bonusCan, magnet, shield, speedBoost, invincibility }

/// Whether an item is a plain collectible (adds score) or a power-up
/// (changes gameplay state for a duration).
bool isPowerUpItem(ItemType type) {
  return type == ItemType.magnet ||
      type == ItemType.shield ||
      type == ItemType.speedBoost ||
      type == ItemType.invincibility;
}

class ItemModel {
  final ItemType type;
  final String assetPath;
  final int scoreValue;

  const ItemModel({
    required this.type,
    required this.assetPath,
    required this.scoreValue,
  });
}

/// A concrete item placed on the track at runtime. `type` is mutable so
/// instances can be recycled by `ObjectPool` instead of reallocated.
class ItemInstance {
  ItemType type;
  int lane;
  double distance;
  bool isCollected;

  ItemInstance({
    required this.type,
    required this.lane,
    required this.distance,
    this.isCollected = false,
  });
}
