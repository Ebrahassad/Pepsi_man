import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/language/app_language_manager.dart';
import '../../../core/theme/app_theme.dart';
import '../data/world_data.dart';
import '../managers/game_progress_manager.dart';
import 'level_select_screen.dart';

class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguageManager>();
    final progress = context.watch<GameProgressManager>();

    return Scaffold(
      appBar: AppBar(title: Text(language.text(ar: 'خريطة العوالم', en: 'World Map'))),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/backgrounds/world_map_background.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: AppTheme.background),
          ),
          Container(color: Colors.black.withOpacity(0.35)),
          SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: WorldData.worlds.length,
              itemBuilder: (context, index) {
                final world = WorldData.worlds[index];
                final unlocked = progress.isWorldUnlocked(world.id);

                return Card(
                  color: AppTheme.surface,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: SizedBox(
                      width: 64,
                      height: 64,
                      child: Image.asset(
                        world.thumbnailAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.map, color: Colors.white),
                        ),
                      ),
                    ),
                    title: Text(
                      language.isArabic ? world.nameAr : world.nameEn,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    trailing: unlocked
                        ? const Icon(Icons.chevron_right, color: Colors.white)
                        : const Icon(Icons.lock, color: Colors.white38),
                    onTap: unlocked
                        ? () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => LevelSelectScreen(worldId: world.id),
                              ),
                            )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
