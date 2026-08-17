import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/audio/audio_manager.dart';
import '../../../core/language/app_language_manager.dart';
import '../../../core/theme/app_theme.dart';
import 'main_menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    AudioManager.instance.playMusic('menu_music.mp3');
    Future.delayed(const Duration(milliseconds: 1800), _goToMenu);
  }

  void _goToMenu() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainMenuScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguageManager>();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/backgrounds/splash_background.webp',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppTheme.background,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.35)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/ui/game_logo.webp',
                  width: 220,
                  errorBuilder: (context, error, stackTrace) => Text(
                    language.text(ar: 'بيبسي رانر', en: 'Pepsi Runner'),
                    style: Theme.of(context).textTheme.displayLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                const CircularProgressIndicator(color: AppTheme.secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
