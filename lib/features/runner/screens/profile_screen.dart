import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/language/app_language_manager.dart';
import '../../../core/theme/app_theme.dart';
import '../data/game_config.dart';
import '../managers/game_progress_manager.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguageManager>();
    final progress = context.watch<GameProgressManager>();
    final totalStars = progress.progress.totalStars();
    final maxStars = GameConfig.totalLevels * 3;

    return Scaffold(
      appBar: AppBar(title: Text(language.text(ar: 'الملف الشخصي', en: 'Profile'))),
      backgroundColor: AppTheme.background,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 48,
            backgroundColor: AppTheme.surface,
            child: Icon(Icons.directions_run, size: 54, color: AppTheme.secondary),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text('RunnerHero', style: Theme.of(context).textTheme.headlineMedium),
          ),
          const SizedBox(height: 24),
          _StatTile(
            icon: Icons.star,
            label: language.text(ar: 'إجمالي النجوم', en: 'Total Stars'),
            value: '$totalStars / $maxStars',
          ),
          _StatTile(
            icon: Icons.monetization_on,
            label: language.text(ar: 'العملات', en: 'Coins'),
            value: '${progress.progress.totalCoins}',
          ),
          _StatTile(
            icon: Icons.local_drink,
            label: language.text(ar: 'العلب المجمّعة', en: 'Cans Collected'),
            value: '${progress.progress.totalCans}',
          ),
          _StatTile(
            icon: Icons.public,
            label: language.text(ar: 'العوالم المفتوحة', en: 'Worlds Unlocked'),
            value: '${progress.progress.unlockedWorlds.length} / ${GameConfig.worldCount}',
          ),
          _StatTile(
            icon: Icons.flag,
            label: language.text(ar: 'المراحل المفتوحة', en: 'Levels Unlocked'),
            value: '${progress.progress.unlockedLevels.length} / ${GameConfig.totalLevels}',
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.surface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.accent),
        title: Text(label, style: const TextStyle(color: Colors.white)),
        trailing: Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
