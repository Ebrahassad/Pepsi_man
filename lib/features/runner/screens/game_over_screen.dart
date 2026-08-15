import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/audio/audio_manager.dart';
import '../../../core/language/app_language_manager.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../engine/runner_engine.dart';
import '../managers/game_progress_manager.dart';
import '../models/level_model.dart';
import 'level_select_screen.dart';
import 'runner_game_screen.dart';

class GameOverScreen extends StatefulWidget {
  final LevelModel level;
  final RunnerEngine engine;

  const GameOverScreen({super.key, required this.level, required this.engine});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  bool _recorded = false;

  @override
  void initState() {
    super.initState();
    AudioManager.instance.playMusic('game_over_music.mp3');
    WidgetsBinding.instance.addPostFrameCallback((_) => _recordResult());
  }

  Future<void> _recordResult() async {
    if (_recorded) return;
    _recorded = true;
    final score = widget.engine.scoreEngine.score;
    await context.read<GameProgressManager>().recordLevelResult(
          levelId: widget.level.id,
          worldId: widget.level.worldId,
          indexInWorld: widget.level.indexInWorld,
          score: score.score,
          stars: 0,
          completed: false,
          coinsEarned: score.coins,
          cansEarned: score.cans,
        );
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<AppLanguageManager>();
    final score = widget.engine.scoreEngine.score;
    final progress = context.watch<GameProgressManager>();
    final bestScore = progress.bestScoreFor(widget.level.id);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/backgrounds/game_over_background.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: AppTheme.background),
          ),
          Container(color: Colors.black.withOpacity(0.55)),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    language.text(ar: 'انتهت اللعبة', en: 'GAME OVER'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.danger,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${language.text(ar: 'النقاط', en: 'Score')}: ${score.score}',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    '${language.text(ar: 'أفضل نتيجة', en: 'Best Score')}: $bestScore',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    '${language.text(ar: 'العلب', en: 'Cans')}: ${score.cans}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  Text(
                    '${language.text(ar: 'المسافة', en: 'Distance')}: ${score.distanceMeters.toInt()}m',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 28),
                  AppButton(
                    label: language.text(ar: 'إعادة المحاولة', en: 'RETRY'),
                    icon: Icons.replay,
                    width: 260,
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => RunnerGameScreen(level: widget.level),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: language.text(ar: 'من نقطة التفتيش', en: 'CHECKPOINT'),
                    icon: Icons.flag,
                    width: 260,
                    color: AppTheme.primary,
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => RunnerGameScreen(level: widget.level),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: language.text(ar: 'اختيار المرحلة', en: 'LEVEL SELECT'),
                    icon: Icons.grid_view,
                    width: 260,
                    color: AppTheme.surface,
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => LevelSelectScreen(worldId: widget.level.worldId),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: language.text(ar: 'القائمة الرئيسية', en: 'MAIN MENU'),
                    icon: Icons.home,
                    width: 260,
                    color: AppTheme.surface,
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
