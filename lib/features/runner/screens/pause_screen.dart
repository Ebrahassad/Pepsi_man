import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/language/app_language_manager.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import 'settings_screen.dart';

/// Presented as a fullscreen dialog on top of RunnerGameScreen. Pops with
/// a result string: 'resume', 'restart', or navigates away entirely for
/// World Map / Main Menu.
class PauseScreen extends StatelessWidget {
  const PauseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguageManager>();

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              language.text(ar: 'إيقاف مؤقت', en: 'PAUSED'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            AppButton(
              label: language.text(ar: 'استئناف', en: 'RESUME'),
              icon: Icons.play_arrow,
              width: 240,
              onPressed: () => Navigator.of(context).pop('resume'),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: language.text(ar: 'إعادة المحاولة', en: 'RESTART'),
              icon: Icons.replay,
              width: 240,
              color: AppTheme.primary,
              onPressed: () => Navigator.of(context).pop('restart'),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: language.text(ar: 'الإعدادات', en: 'SETTINGS'),
              icon: Icons.settings,
              width: 240,
              color: AppTheme.surface,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: language.text(ar: 'خريطة العوالم', en: 'WORLD MAP'),
              icon: Icons.map,
              width: 240,
              color: AppTheme.surface,
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: language.text(ar: 'القائمة الرئيسية', en: 'MAIN MENU'),
              icon: Icons.home,
              width: 240,
              color: AppTheme.surface,
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }
}
