import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/language/app_language_manager.dart';
import '../../../core/theme/app_theme.dart';
import '../managers/game_progress_manager.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguageManager>();
    final progress = context.watch<GameProgressManager>();

    final achievements = [
      ('first_run', language.text(ar: 'أول جري', en: 'First Run')),
      ('cans_100', language.text(ar: '100 علبة', en: '100 Cans')),
      ('cans_500', language.text(ar: '500 علبة', en: '500 Cans')),
      ('cans_1000', language.text(ar: '1000 علبة', en: '1000 Cans')),
      ('perfect_level', language.text(ar: 'مرحلة مثالية', en: 'Perfect Level')),
      ('no_hit', language.text(ar: 'بدون اصطدام', en: 'No Hit')),
      ('speed_runner', language.text(ar: 'عداء سريع', en: 'Speed Runner')),
      ('world_complete', language.text(ar: 'إكمال عالم', en: 'World Complete')),
      ('all_worlds_complete', language.text(ar: 'إكمال كل العوالم', en: 'All Worlds Complete')),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(language.text(ar: 'الإنجازات', en: 'Achievements'))),
      backgroundColor: AppTheme.background,
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: achievements.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final (id, title) = achievements[index];
          final unlocked = progress.unlockedAchievements.contains(id);

          return Card(
            color: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: Icon(
                unlocked ? Icons.emoji_events : Icons.emoji_events_outlined,
                color: unlocked ? AppTheme.accent : Colors.white24,
                size: 30,
              ),
              title: Text(
                title,
                style: TextStyle(color: unlocked ? Colors.white : Colors.white38),
              ),
              trailing: unlocked
                  ? const Icon(Icons.check_circle, color: AppTheme.success)
                  : const Icon(Icons.lock, color: Colors.white24),
            ),
          );
        },
      ),
    );
  }
}
