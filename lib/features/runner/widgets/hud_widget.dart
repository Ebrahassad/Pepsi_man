import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../engine/runner_engine.dart';
import '../models/power_up_model.dart';

/// Heads-up display shown during gameplay: score, cans, coins, lives,
/// distance, combo, and the active power-up (if any), plus a pause button.
class HudWidget extends StatelessWidget {
  final RunnerEngine engine;
  final VoidCallback onPause;

  const HudWidget({super.key, required this.engine, required this.onPause});

  @override
  Widget build(BuildContext context) {
    final score = engine.scoreEngine.score;
    final runner = engine.runner;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatChip(
                  icon: Icons.emoji_events,
                  iconAsset: '',
                  value: '${score.score}',
                  color: AppTheme.accent,
                ),
                _LivesRow(lives: runner.lives),
                IconButton(
                  onPressed: onPause,
                  icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 32),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatChip(
                  icon: Icons.local_drink,
                  iconAsset: 'assets/images/ui/can_icon.png',
                  value: '${score.cans}',
                  color: AppTheme.success,
                ),
                _StatChip(
                  icon: Icons.monetization_on,
                  iconAsset: 'assets/images/ui/coin_icon.png',
                  value: '${score.coins}',
                  color: AppTheme.accent,
                ),
                _StatChip(
                  icon: Icons.directions_run,
                  iconAsset: '',
                  value: '${score.distanceMeters.toInt()}m',
                  color: Colors.white,
                ),
                if (score.combo > 0)
                  _StatChip(
                    icon: Icons.bolt,
                    iconAsset: '',
                    value: 'x${score.comboTier + 1}',
                    color: AppTheme.secondary,
                  ),
              ],
            ),
            if (engine.itemEngine.activePowerUps.isNotEmpty) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: engine.itemEngine.activePowerUps.keys
                      .map((type) => _PowerUpBadge(type: type))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String iconAsset;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.iconAsset,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconAsset.isEmpty
              ? Icon(icon, color: color, size: 18)
              : Image.asset(
                  iconAsset,
                  width: 18,
                  height: 18,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(icon, color: color, size: 18),
                ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _LivesRow extends StatelessWidget {
  final int lives;

  const _LivesRow({required this.lives});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (i) {
        final filled = i < lives;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            filled ? Icons.favorite : Icons.favorite_border,
            color: AppTheme.danger,
            size: 20,
          ),
        );
      }),
    );
  }
}

class _PowerUpBadge extends StatelessWidget {
  final PowerUpType type;

  const _PowerUpBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (type) {
      case PowerUpType.magnet:
        icon = Icons.attractions;
        break;
      case PowerUpType.shield:
        icon = Icons.shield;
        break;
      case PowerUpType.speedBoost:
        icon = Icons.speed;
        break;
      case PowerUpType.invincibility:
        icon = Icons.star;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withOpacity(0.85),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }
}
