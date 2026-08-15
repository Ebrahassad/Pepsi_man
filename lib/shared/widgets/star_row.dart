import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Displays a row of 3 stars, [filled] of which are lit up. Used on
/// LevelSelectScreen cards and VictoryScreen.
class StarRow extends StatelessWidget {
  final int filled; // 0..3
  final double size;

  const StarRow({super.key, required this.filled, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final isFilled = i < filled;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Image.asset(
            isFilled ? 'assets/images/ui/star.png' : 'assets/images/ui/star_empty.png',
            width: size,
            height: size,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.star,
              size: size,
              color: isFilled ? AppTheme.accent : Colors.white24,
            ),
          ),
        );
      }),
    );
  }
}
