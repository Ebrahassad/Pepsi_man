import '../models/world_model.dart';

class WorldData {
  WorldData._();

  static const List<WorldModel> worlds = [
    WorldModel(
      id: 1,
      type: WorldType.cityStreets,
      nameAr: 'شوارع المدينة',
      nameEn: 'City Streets',
      backgroundAsset: 'assets/images/backgrounds/city_background.png',
      thumbnailAsset: 'assets/images/worlds/world_01.png',
      musicAsset: 'world_01_music.mp3',
    ),
    WorldModel(
      id: 2,
      type: WorldType.highway,
      nameAr: 'الطريق السريع',
      nameEn: 'Highway',
      backgroundAsset: 'assets/images/backgrounds/highway_background.png',
      thumbnailAsset: 'assets/images/worlds/world_02.png',
      musicAsset: 'world_02_music.mp3',
    ),
    WorldModel(
      id: 3,
      type: WorldType.downtown,
      nameAr: 'وسط المدينة',
      nameEn: 'Downtown',
      backgroundAsset: 'assets/images/backgrounds/downtown_background.png',
      thumbnailAsset: 'assets/images/worlds/world_03.png',
      musicAsset: 'world_03_music.mp3',
    ),
    WorldModel(
      id: 4,
      type: WorldType.industrialZone,
      nameAr: 'المنطقة الصناعية',
      nameEn: 'Industrial Zone',
      backgroundAsset: 'assets/images/backgrounds/industrial_background.png',
      thumbnailAsset: 'assets/images/worlds/world_04.png',
      musicAsset: 'world_04_music.mp3',
    ),
    WorldModel(
      id: 5,
      type: WorldType.extremeCity,
      nameAr: 'المدينة القصوى',
      nameEn: 'Extreme City',
      backgroundAsset: 'assets/images/backgrounds/extreme_city_background.png',
      thumbnailAsset: 'assets/images/worlds/world_05.png',
      musicAsset: 'world_05_music.mp3',
    ),
  ];

  static WorldModel byId(int id) => worlds.firstWhere((w) => w.id == id);
}
