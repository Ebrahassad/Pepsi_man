import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/language/app_language_manager.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/star_row.dart';
import '../data/game_config.dart';
import '../data/world_data.dart';
import '../managers/game_progress_manager.dart';
import 'runner_game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  final int worldId;

  const LevelSelectScreen({super.key, required this.worldId});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguageManager>();
    final progress = context.watch<GameProgressManager>();
    final world = WorldData.byId(worldId);
    final levels = GameConfig.levelsForWorld(worldId);

    return Scaffold(
      appBar: AppBar(
        title: Text(language.isArabic ? world.nameAr : world.nameEn),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            world.backgroundAsset,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: AppTheme.background),
          ),
          Container(color: Colors.black.withOpacity(0.45)),
          SafeArea(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.1,
              ),
              itemCount: levels.length,
              itemBuilder: (context, index) {
                final level = levels[index];
                final unlocked = progress.isLevelUnlocked(level.id);
                final stars = progress.starsFor(level.id);
                final bestScore = progress.bestScoreFor(level.id);

                return Card(
                  color: AppTheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: unlocked
                        ? () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RunnerGameScreen(level: level),
                              ),
                            )
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${level.indexInWorld}',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          unlocked
                              ? StarRow(filled: stars, size: 18)
                              : const Icon(Icons.lock, color: Colors.white38),
                          if (unlocked && bestScore > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              language.text(ar: 'أفضل: $bestScore', en: 'Best: $bestScore'),
                              style: const TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
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
