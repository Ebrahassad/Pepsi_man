import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/language/app_language_manager.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import 'world_map_screen.dart';
import 'shop_screen.dart';
import 'achievements_screen.dart';
import 'daily_reward_screen.dart';
import 'settings_screen.dart';
import 'how_to_play_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguageManager>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/backgrounds/main_menu_background.webp',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppTheme.background,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Image.asset(
                    'assets/images/ui/game_logo.webp',
                    height: 120,
                    errorBuilder: (context, error, stackTrace) => Text(
                      language.text(ar: 'بيبسي رانر', en: 'Pepsi Runner'),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                  const Spacer(),
                  AppButton(
                    label: language.text(ar: 'ابدأ اللعب', en: 'PLAY'),
                    icon: Icons.play_arrow,
                    width: 260,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WorldMapScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: language.text(ar: 'المتجر', en: 'SHOP'),
                    icon: Icons.storefront,
                    width: 260,
                    color: AppTheme.primary,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ShopScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: language.text(ar: 'الإنجازات', en: 'ACHIEVEMENTS'),
                    icon: Icons.emoji_events,
                    width: 260,
                    color: AppTheme.primary,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: language.text(ar: 'المكافأة اليومية', en: 'DAILY REWARD'),
                    icon: Icons.card_giftcard,
                    width: 260,
                    color: AppTheme.primary,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DailyRewardScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppButton(
                        label: language.text(ar: 'الإعدادات', en: 'SETTINGS'),
                        icon: Icons.settings,
                        color: AppTheme.surface,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AppButton(
                        label: language.text(ar: 'طريقة اللعب', en: 'HOW TO PLAY'),
                        icon: Icons.help_outline,
                        color: AppTheme.surface,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const HowToPlayScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
