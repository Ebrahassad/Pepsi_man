import 'package:flutter/material.dart';

import '../../core/audio/audio_manager.dart';
import '../../core/theme/app_theme.dart';

/// Reusable primary button used across menus/screens. Plays the standard
/// button-click SFX automatically unless [playSound] is false.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;
  final bool playSound;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.playSound = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppTheme.secondary,
        ),
        onPressed: () {
          if (playSound) {
            AudioManager.instance.playButtonClick();
          }
          onPressed();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      ),
    );
  }
}
