import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/language/app_language_manager.dart';
import '../../../core/theme/app_theme.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguageManager>();

    final items = [
      (
        Icons.swipe,
        language.text(ar: 'اسحب يسار / يمين', en: 'Swipe Left / Right'),
        language.text(ar: 'لتغيير المسار', en: 'Change lane'),
      ),
      (
        Icons.swipe_up,
        language.text(ar: 'اسحب لأعلى', en: 'Swipe Up'),
        language.text(ar: 'للقفز فوق العوائق', en: 'Jump over obstacles'),
      ),
      (
        Icons.swipe_down,
        language.text(ar: 'اسحب لأسفل', en: 'Swipe Down'),
        language.text(ar: 'للانزلاق تحت العوائق', en: 'Slide under obstacles'),
      ),
      (
        Icons.local_drink,
        language.text(ar: 'اجمع العلب', en: 'Collect Cans'),
        language.text(ar: 'لزيادة نقاطك', en: 'Boost your score'),
      ),
      (
        Icons.directions_car,
        language.text(ar: 'تجنب السيارات', en: 'Avoid Cars & Barriers'),
        language.text(ar: 'أو ستخسر حياة', en: 'Or you lose a life'),
      ),
      (
        Icons.bolt,
        language.text(ar: 'استخدم القوى الخاصة', en: 'Use Power-Ups'),
        language.text(
          ar: 'مغناطيس، درع، سرعة، حصانة',
          en: 'Magnet, Shield, Speed Boost, Invincibility',
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(language.text(ar: 'طريقة اللعب', en: 'How To Play'))),
      backgroundColor: AppTheme.background,
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final (icon, title, subtitle) = items[index];
          return Card(
            color: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: Icon(icon, color: AppTheme.secondary, size: 32),
              title: Text(title, style: const TextStyle(color: Colors.white)),
              subtitle: Text(subtitle, style: const TextStyle(color: Colors.white60)),
            ),
          );
        },
      ),
    );
  }
}
