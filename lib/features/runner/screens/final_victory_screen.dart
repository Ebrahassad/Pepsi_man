import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/audio/audio_manager.dart';
import '../../../core/language/app_language_manager.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import 'main_menu_screen.dart';
import 'world_map_screen.dart';

/// Shown after completing Level 10 of World 5 — the last level in the game.
class FinalVictoryScreen extends StatefulWidget {
  const FinalVictoryScreen({super.key});

  @override
  State<FinalVictoryScreen> createState() => _FinalVictoryScreenState();
}

class _FinalVictoryScreenState extends State<FinalVictoryScreen> {
  @override
  void initState() {
    super.initState();
    AudioManager.instance.playMusic('victory_music.mp3');
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguageManager>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/backgrounds/victory_background.webp',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: AppTheme.background),
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events, color: AppTheme.accent, size: 90),
                const SizedBox(height: 16),
                Text(
                  language.text(ar: 'أنهيت جميع العوالم!', en: 'ALL WORLDS COMPLETE!'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  language.text(
                    ar: 'RunnerHero أصبح بطل الشوارع الأول!',
                    en: 'RunnerHero is now the ultimate street champion!',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: language.text(ar: 'العب مجددًا', en: 'PLAY AGAIN'),
                  icon: Icons.replay,
                  width: 260,
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const WorldMapScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: language.text(ar: 'خريطة العوالم', en: 'WORLD MAP'),
                  icon: Icons.map,
                  width: 260,
                  color: AppTheme.primary,
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const WorldMapScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: language.text(ar: 'القائمة الرئيسية', en: 'MAIN MENU'),
                  icon: Icons.home,
                  width: 260,
                  color: AppTheme.surface,
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MainMenuScreen()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
