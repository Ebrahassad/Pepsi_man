import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/language/app_language_manager.dart';
import '../../../core/theme/app_theme.dart';
import '../data/item_data.dart';
import '../managers/game_progress_manager.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguageManager>();
    final progress = context.watch<GameProgressManager>();

    final items = [
      (
        'extra_life',
        Icons.favorite,
        language.text(ar: 'حياة إضافية', en: 'Extra Life'),
        'assets/images/ui/life_icon.webp',
      ),
      (
        'shield',
        Icons.shield,
        language.text(ar: 'درع', en: 'Shield'),
        'assets/images/items/shield.webp',
      ),
      (
        'magnet',
        Icons.attractions,
        language.text(ar: 'مغناطيس', en: 'Magnet'),
        'assets/images/items/magnet.webp',
      ),
      (
        'speed_boost',
        Icons.speed,
        language.text(ar: 'تعزيز السرعة', en: 'Speed Boost'),
        'assets/images/items/speed_boost.webp',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(language.text(ar: 'المتجر', en: 'Shop')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: AppTheme.accent, size: 20),
                  const SizedBox(width: 4),
                  Text('${progress.progress.totalCoins}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.background,
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final (id, icon, title, asset) = items[index];
          final price = ItemData.shopPrices[id] ?? 0;

          return Card(
            color: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: Image.asset(
                asset,
                width: 36,
                height: 36,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(icon, color: AppTheme.secondary, size: 32),
              ),
              title: Text(title, style: const TextStyle(color: Colors.white)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accent),
                onPressed: () async {
                  final success = await context.read<GameProgressManager>().spendCoins(price);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? language.text(ar: 'تم الشراء!', en: 'Purchased!')
                              : language.text(ar: 'عملات غير كافية', en: 'Not enough coins'),
                        ),
                      ),
                    );
                  }
                },
                child: Text('$price 🪙'),
              ),
            ),
          );
        },
      ),
    );
  }
}
