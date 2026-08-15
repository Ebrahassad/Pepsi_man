import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/language/app_language_manager.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../managers/game_progress_manager.dart';
import '../managers/settings_manager.dart';
import '../models/settings_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguageManager>();
    final settings = context.watch<SettingsManager>();

    return Scaffold(
      appBar: AppBar(title: Text(language.text(ar: 'الإعدادات', en: 'Settings'))),
      backgroundColor: AppTheme.background,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: Text(language.text(ar: 'الموسيقى', en: 'Music')),
            value: settings.musicEnabled,
            activeColor: AppTheme.secondary,
            onChanged: (value) => context.read<SettingsManager>().setMusicEnabled(value),
          ),
          SwitchListTile(
            title: Text(language.text(ar: 'الصوت', en: 'Sound')),
            value: settings.soundEnabled,
            activeColor: AppTheme.secondary,
            onChanged: (value) => context.read<SettingsManager>().setSoundEnabled(value),
          ),
          SwitchListTile(
            title: Text(language.text(ar: 'الاهتزاز', en: 'Vibration')),
            value: settings.vibrationEnabled,
            activeColor: AppTheme.secondary,
            onChanged: (value) => context.read<SettingsManager>().setVibrationEnabled(value),
          ),
          const SizedBox(height: 16),
          Text(
            language.text(ar: 'نوع التحكم', en: 'Control Type'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          RadioListTile<ControlType>(
            title: Text(language.text(ar: 'سحب', en: 'Swipe')),
            value: ControlType.swipe,
            groupValue: settings.controlType,
            activeColor: AppTheme.secondary,
            onChanged: (value) => context.read<SettingsManager>().setControlType(value!),
          ),
          RadioListTile<ControlType>(
            title: Text(language.text(ar: 'أزرار', en: 'Buttons')),
            value: ControlType.buttons,
            groupValue: settings.controlType,
            activeColor: AppTheme.secondary,
            onChanged: (value) => context.read<SettingsManager>().setControlType(value!),
          ),
          const SizedBox(height: 16),
          Text(
            language.text(ar: 'اللغة', en: 'Language'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          RadioListTile<AppLanguage>(
            title: const Text('English'),
            value: AppLanguage.english,
            groupValue: language.current,
            activeColor: AppTheme.secondary,
            onChanged: (value) => context.read<AppLanguageManager>().setLanguage(value!),
          ),
          RadioListTile<AppLanguage>(
            title: const Text('العربية'),
            value: AppLanguage.arabic,
            groupValue: language.current,
            activeColor: AppTheme.secondary,
            onChanged: (value) => context.read<AppLanguageManager>().setLanguage(value!),
          ),
          const SizedBox(height: 28),
          Center(
            child: AppButton(
              label: language.text(ar: 'إعادة ضبط التقدم', en: 'RESET PROGRESS'),
              icon: Icons.restart_alt,
              color: AppTheme.danger,
              onPressed: () => _confirmReset(context, language),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, AppLanguageManager language) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(language.text(ar: 'تأكيد', en: 'Confirm')),
        content: Text(
          language.text(
            ar: 'هل تريد حذف كل التقدم؟ لا يمكن التراجع.',
            en: 'Reset all progress? This cannot be undone.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(language.text(ar: 'إلغاء', en: 'Cancel')),
          ),
          TextButton(
            onPressed: () {
              context.read<GameProgressManager>().resetProgress();
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              language.text(ar: 'حذف', en: 'Reset'),
              style: const TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
  }
}
