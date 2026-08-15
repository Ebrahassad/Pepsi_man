import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/audio/audio_manager.dart';
import 'core/language/app_language_manager.dart';
import 'core/theme/app_theme.dart';
import 'features/runner/managers/game_progress_manager.dart';
import 'features/runner/managers/settings_manager.dart';
import 'features/runner/managers/reward_manager.dart';
import 'features/runner/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PepsiRunnerApp());
}

/// Root widget. Wires up the app-wide managers (language, audio, progress,
/// settings, rewards) via Provider and boots straight into SplashScreen.
class PepsiRunnerApp extends StatefulWidget {
  const PepsiRunnerApp({super.key});

  @override
  State<PepsiRunnerApp> createState() => _PepsiRunnerAppState();
}

class _PepsiRunnerAppState extends State<PepsiRunnerApp> {
  final AppLanguageManager _languageManager = AppLanguageManager();
  final GameProgressManager _progressManager = GameProgressManager();
  final SettingsManager _settingsManager = SettingsManager();
  final RewardManager _rewardManager = RewardManager();

  bool _bootstrapped = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await AudioManager.instance.init();
    await _languageManager.load();
    await _settingsManager.load();
    await _progressManager.load();
    await _rewardManager.load();

    AudioManager.instance.setMusicEnabled(_settingsManager.musicEnabled);
    AudioManager.instance.setSfxEnabled(_settingsManager.soundEnabled);

    if (mounted) {
      setState(() => _bootstrapped = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_bootstrapped) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeData,
        home: const Scaffold(
          backgroundColor: AppTheme.background,
          body: Center(
            child: CircularProgressIndicator(color: AppTheme.secondary),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppLanguageManager>.value(value: _languageManager),
        ChangeNotifierProvider<GameProgressManager>.value(value: _progressManager),
        ChangeNotifierProvider<SettingsManager>.value(value: _settingsManager),
        ChangeNotifierProvider<RewardManager>.value(value: _rewardManager),
      ],
      child: Consumer<AppLanguageManager>(
        builder: (context, language, _) {
          return MaterialApp(
            title: 'Pepsi Runner',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.themeData,
            locale: language.locale,
            builder: (context, child) {
              return Directionality(
                textDirection: language.textDirection,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
