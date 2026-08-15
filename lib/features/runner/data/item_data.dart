import '../../../core/constants/game_constants.dart';
import '../models/item_model.dart';
import '../models/power_up_model.dart';

class ItemData {
  ItemData._();

  static const Map<ItemType, ItemModel> collectibles = {
    ItemType.coin: ItemModel(
      type: ItemType.coin,
      assetPath: 'assets/images/items/coin.png',
      scoreValue: GameConstants.scoreCoin,
    ),
    ItemType.energyCan: ItemModel(
      type: ItemType.energyCan,
      assetPath: 'assets/images/items/energy_can.png',
      scoreValue: GameConstants.scoreCan,
    ),
    ItemType.bonusCan: ItemModel(
      type: ItemType.bonusCan,
      assetPath: 'assets/images/items/bonus_can.png',
      scoreValue: GameConstants.scoreBonusCan,
    ),
    ItemType.magnet: ItemModel(
      type: ItemType.magnet,
      assetPath: 'assets/images/items/magnet.png',
      scoreValue: 0,
    ),
    ItemType.shield: ItemModel(
      type: ItemType.shield,
      assetPath: 'assets/images/items/shield.png',
      scoreValue: 0,
    ),
    ItemType.speedBoost: ItemModel(
      type: ItemType.speedBoost,
      assetPath: 'assets/images/items/speed_boost.png',
      scoreValue: 0,
    ),
    ItemType.invincibility: ItemModel(
      type: ItemType.invincibility,
      assetPath: 'assets/images/items/invincibility.png',
      scoreValue: 0,
    ),
  };

  static const Map<PowerUpType, PowerUpModel> powerUps = {
    PowerUpType.magnet: PowerUpModel(
      type: PowerUpType.magnet,
      assetPath: 'assets/images/items/magnet.png',
      durationSeconds: GameConstants.magnetDuration,
    ),
    PowerUpType.shield: PowerUpModel(
      type: PowerUpType.shield,
      assetPath: 'assets/images/items/shield.png',
      durationSeconds: 0,
    ),
    PowerUpType.speedBoost: PowerUpModel(
      type: PowerUpType.speedBoost,
      assetPath: 'assets/images/items/speed_boost.png',
      durationSeconds: GameConstants.speedBoostDuration,
    ),
    PowerUpType.invincibility: PowerUpModel(
      type: PowerUpType.invincibility,
      assetPath: 'assets/images/items/invincibility.png',
      durationSeconds: GameConstants.invincibilityDuration,
    ),
  };

  /// Shop prices (in coins) for consumables bought from ShopScreen.
  static const Map<String, int> shopPrices = {
    'extra_life': 150,
    'shield': 80,
    'magnet': 60,
    'speed_boost': 60,
  };
}
