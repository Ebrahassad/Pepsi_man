enum WorldType { cityStreets, highway, downtown, industrialZone, extremeCity }

class WorldModel {
  final int id;
  final WorldType type;
  final String nameAr;
  final String nameEn;
  final String backgroundAsset;
  final String thumbnailAsset;
  final String musicAsset;

  const WorldModel({
    required this.id,
    required this.type,
    required this.nameAr,
    required this.nameEn,
    required this.backgroundAsset,
    required this.thumbnailAsset,
    required this.musicAsset,
  });
}
