import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/language/app_language_manager.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../managers/game_progress_manager.dart';
import '../managers/reward_manager.dart';

class DailyRewardScreen extends StatelessWidget {
  const DailyRewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguageManager>();
    final rewards = context.watch<RewardManager>();
    final nextTier = rewards.nextTier;

    return Scaffold(
      appBar: AppBar(title: Text(language.text(ar: 'المكافأة اليومية', en: 'Daily Reward'))),
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.card_giftcard, size: 80, color: AppTheme.accent),
            const SizedBox(height: 16),
            Text(
              language.text(ar: 'اليوم ${nextTier.day}', en: 'Day ${nextTier.day}'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${nextTier.coins} ${language.text(ar: 'عملة', en: 'Coins')} · '
              '${nextTier.cans} ${language.text(ar: 'علبة', en: 'Cans')}',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: rewards.canClaimToday
                  ? language.text(ar: 'المطالبة', en: 'CLAIM')
                  : language.text(ar: 'تمت المطالبة اليوم', en: 'CLAIMED TODAY'),
              icon: Icons.redeem,
              width: 240,
              onPressed: rewards.canClaimToday
                  ? () async {
                      final tier = await context.read<RewardManager>().claim();
                      if (tier != null && context.mounted) {
                        await context.read<GameProgressManager>().addCoins(tier.coins);
                      }
                    }
                  : () {},
            ),
          ],
        ),
      ),
    );
  }
}
