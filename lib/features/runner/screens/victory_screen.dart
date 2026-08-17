import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/audio/audio_manager.dart';
import '../../../core/language/app_language_manager.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/star_calculator.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/star_row.dart';
import '../data/game_config.dart';
import '../engine/runner_engine.dart';
import '../managers/game_progress_manager.dart';
import '../models/level_model.dart';
import 'final_victory_screen.dart';
import 'level_select_screen.dart';
import 'runner_game_screen.dart';
import 'world_map_screen.dart';

class VictoryScreen extends StatefulWidget {
  final LevelModel level;
  final RunnerEngine engine;

  const VictoryScreen({super.key, required this.level, required this.engine});

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen> {
  late final int _stars;
  bool _recorded = false;

  @override
  void initState() {
    super.initState();
    AudioManager.instance.playMusic('victory_music.mp3');

    final score = widget.engine.scoreEngine.score;
    _stars = StarCalculator.calculateStars(
      score: score.score,
      targetScore: widget.level.starRequirements.targetScore,
      finished: true,
      perfect: !widget.engine.levelEngine.progress.tookHit,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _recordResult());
  }

  Future<void> _recordResult() async {
    if (_recorded) return;
    _recorded = true;
    final score = widget.engine.scoreEngine.score;
    final perfect = !widget.engine.levelEngine.progress.tookHit;
    final reachedMaxSpeed =
        widget.engine.physics.forwardSpeed >= widget.engine.physics.maxSpeed * 0.98;

    await context.read<GameProgressManager>().recordLevelResult(
          levelId: widget.level.id,
          worldId: widget.level.worldId,
          indexInWorld: widget.level.indexInWorld,
          score: score.score,
          stars: _stars,
          completed: true,
          coinsEarned: score.coins,
          cansEarned: score.cans,
          perfect: perfect,
          reachedMaxSpeed: reachedMaxSpeed,
        );
  }

  void _goNext() {
    final isLastInWorld = GameConfig.isLastLevelOfWorld(widget.level.indexInWorld);
    final isFinalWorld = GameConfig.isFinalWorld(widget.level.worldId);

    if (isLastInWorld && isFinalWorld) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const FinalVictoryScreen()),
      );
      return;
    }

    final nextWorldId = isLastInWorld ? widget.level.worldId + 1 : widget.level.worldId;
    final nextIndex = isLastInWorld ? 1 : widget.level.indexInWorld + 1;
    final nextLevel = GameConfig.levelsForWorld(nextWorldId)
        .firstWhere((l) => l.indexInWorld == nextIndex);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => RunnerGameScreen(level: nextLevel)),
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
            'assets/images/backgrounds/victory_background.webp',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: AppTheme.background),
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      language.text(ar: 'اكتملت المرحلة!', en: 'LEVEL COMPLETE'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    StarRow(filled: _stars, size: 40),
                    const SizedBox(height: 24),
                    _ResultRow(
                      label: language.text(ar: 'النقاط', en: 'Score'),
                      value: '${score.score}',
                    ),
                    _ResultRow(
                      label: language.text(ar: 'العلب', en: 'Cans'),
                      value: '${score.cans}',
                    ),
                    _ResultRow(
                      label: language.text(ar: 'العملات', en: 'Coins'),
                      value: '${score.coins}',
                    ),
                    _ResultRow(
                      label: language.text(ar: 'المسافة', en: 'Distance'),
                      value: '${score.distanceMeters.toInt()}m',
                    ),
                    _ResultRow(
                      label: language.text(ar: 'أفضل نتيجة', en: 'Best Score'),
                      value: '$bestScore',
                    ),
                    const SizedBox(height: 28),
                    AppButton(
                      label: language.text(ar: 'المرحلة التالية', en: 'NEXT LEVEL'),
                      icon: Icons.arrow_forward,
                      width: 260,
                      onPressed: _goNext,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: language.text(ar: 'إعادة', en: 'REPLAY'),
                      icon: Icons.replay,
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
                      label: language.text(ar: 'خريطة العوالم', en: 'WORLD MAP'),
                      icon: Icons.map,
                      width: 260,
                      color: AppTheme.surface,
                      onPressed: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const WorldMapScreen()),
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
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
