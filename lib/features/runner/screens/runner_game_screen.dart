import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../../core/audio/audio_manager.dart';
import '../controllers/input_controller.dart';
import '../controllers/runner_controller.dart';
import '../data/world_data.dart';
import '../engine/runner_engine.dart';
import '../engine/track_geometry.dart';
import '../managers/settings_manager.dart';
import '../models/level_model.dart';
import '../models/obstacle_model.dart';
import '../models/item_model.dart';
import '../widgets/hud_widget.dart';
import '../widgets/item_widget.dart';
import '../widgets/obstacle_widget.dart';
import '../widgets/runner_widget.dart';
import 'game_over_screen.dart';
import 'pause_screen.dart';
import 'victory_screen.dart';

class RunnerGameScreen extends StatefulWidget {
  final LevelModel level;

  const RunnerGameScreen({
    super.key,
    required this.level,
  });

  @override
  State<RunnerGameScreen> createState() =>
      _RunnerGameScreenState();
}

class _RunnerGameScreenState extends State<RunnerGameScreen>
    with SingleTickerProviderStateMixin {
  late final RunnerController _controller;
  late final InputController _input;
  late final Ticker _ticker;

  Offset _dragPosition = Offset.zero;

  bool _navigatedAway = false;

  // ---------------------------------------------------------------------------
  // VISUAL TRACK SETTINGS
  // ---------------------------------------------------------------------------
  //
  // This is ONLY the visual depth window.
  //
  // It does NOT change gameplay distance, collision distance,
  // obstacle spawning, or runner speed.
  //
  // Larger value = objects become visible farther away and approach
  // the player more gradually.
  //
  static const double _visibilityWindow = 180.0;

  static const double _minimumVisibleDistance = -8.0;

  @override
  void initState() {
    super.initState();

    _controller = RunnerController(
      level: widget.level,
    );

    final controlType =
        context.read<SettingsManager>().controlType;

    _input = InputController(
      controlType: controlType,
    );

    final world =
        WorldData.byId(widget.level.worldId);

    AudioManager.instance.playMusic(
      world.musicAsset,
    );

    AudioManager.instance.playLevelStart();

    _ticker = createTicker(
      _onTick,
    )..start();

    _controller.addListener(
      _onEngineUpdate,
    );
  }

  void _onTick(Duration elapsed) {
    _controller.tick(elapsed);
  }

  void _onEngineUpdate() {
    if (_navigatedAway) return;

    final reason =
        _controller.endReason;

    if (reason == RunEndReason.levelComplete) {
      _navigatedAway = true;

      _ticker.stop();

      _goToVictory();
    } else if (reason == RunEndReason.gameOver) {
      _navigatedAway = true;

      _ticker.stop();

      _goToGameOver();
    }
  }

  void _goToVictory() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => VictoryScreen(
            level: widget.level,
            engine: _controller.engine,
          ),
        ),
      );
    });
  }

  void _goToGameOver() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GameOverScreen(
            level: widget.level,
            engine: _controller.engine,
          ),
        ),
      );
    });
  }

  Future<void> _openPause() async {
    _controller.pause();

    _ticker.stop();

    final result =
        await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const PauseScreen(),
        fullscreenDialog: true,
      ),
    );

    if (!mounted) return;

    switch (result) {
      case 'restart':
        _controller.restart(
          widget.level,
        );

        _navigatedAway = false;

        _ticker.start();

        break;

      case null:
      case 'resume':
      default:
        _controller.resume();

        _ticker.start();

        break;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(
      _onEngineUpdate,
    );

    _ticker.dispose();

    _controller.dispose();

    super.dispose();
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final world =
        WorldData.byId(widget.level.worldId);

    return Scaffold(
      body: GestureDetector(
        onPanStart: _input.onPanStart,

        onPanUpdate: (details) {
          _dragPosition =
              details.globalPosition;
        },

        onPanEnd: (details) {
          final action =
              _input.onPanEnd(
            details,
            _dragPosition,
          );

          if (action != null) {
            _controller.handleInput(
              action,
            );
          }
        },

        child: AnimatedBuilder(
          animation: _controller,

          builder: (context, _) {
            final engine =
                _controller.engine;

            return Stack(
              fit: StackFit.expand,
              children: [
                // =============================================================
                // BACKGROUND
                // =============================================================

                Image.asset(
                  world.backgroundAsset,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) {
                    return Container(
                      color: Colors.black,
                    );
                  },
                ),

                // =============================================================
                // OBJECTS
                // =============================================================

                ..._buildTrackObjects(
                  context,
                  engine,
                ),

                // =============================================================
                // PLAYER
                // =============================================================

                _buildRunner(
                  context,
                  engine,
                ),

                // =============================================================
                // HUD
                // =============================================================

                HudWidget(
                  engine: engine,
                  onPause: _openPause,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // RUNNER
  // ===========================================================================

  Widget _buildRunner(
    BuildContext context,
    RunnerEngine engine,
  ) {
    final size =
        MediaQuery.of(context).size;

    final groundY =
        TrackGeometry.groundY(
      size.height,
    );

    final laneX =
        TrackGeometry.laneX(
      size.width,
      engine.physics.lanePosition,
      1.0,
    );

    final jumpOffset =
        engine.physics.verticalPosition *
            0.4;

    const runnerWidth = 90.0;
    const runnerHeight = 90.0;

    return Positioned(
      left:
          laneX -
              runnerWidth / 2,

      top:
          groundY +
              jumpOffset -
              runnerHeight,

      width:
          runnerWidth,

      height:
          runnerHeight,

      child: RunnerWidget(
        state: engine.runner.state,
      ),
    );
  }

  // ===========================================================================
  // TRACK OBJECTS
  // ===========================================================================

  List<Widget> _buildTrackObjects(
    BuildContext context,
    RunnerEngine engine,
  ) {
    final size =
        MediaQuery.of(context).size;

    final widgets =
        <Widget>[];

    // -------------------------------------------------------------------------
    // OBSTACLES
    // -------------------------------------------------------------------------

    for (
      final ObstacleInstance obstacle
          in engine.obstacleEngine.active
    ) {
      if (!obstacle.hasAppeared) {
        continue;
      }

      final relative =
          obstacle.distance -
              engine.distanceMeters;

      // Objects behind the runner are removed visually.
      //
      // Objects farther than the visual window are not drawn yet.
      if (relative < _minimumVisibleDistance ||
          relative > _visibilityWindow) {
        continue;
      }

      final t =
          (1.0 -
                  (relative /
                      _visibilityWindow))
              .clamp(0.0, 1.0);

      final laneX =
          TrackGeometry.laneX(
        size.width,
        obstacle.lane.toDouble(),
        t,
      );

      final y =
          TrackGeometry.depthY(
        size.height,
        t,
      );

      // Smaller in the distance, larger near the player.
      final scale =
          0.20 +
              (0.90 * t);

      final objectSize =
          80.0 * scale;

      widgets.add(
        Positioned(
          left:
              laneX -
                  objectSize / 2,

          top:
              y -
                  objectSize / 2,

          width:
              objectSize,

          height:
              objectSize,

          child:
              ObstacleWidget(
            instance: obstacle,
            scale: scale,
          ),
        ),
      );
    }

    // -------------------------------------------------------------------------
    // ITEMS
    // -------------------------------------------------------------------------

    for (
      final ItemInstance item
          in engine.itemEngine.active
    ) {
      if (item.isCollected) {
        continue;
      }

      final relative =
          item.distance -
              engine.distanceMeters;

      if (relative < _minimumVisibleDistance ||
          relative > _visibilityWindow) {
        continue;
      }

      final t =
          (1.0 -
                  (relative /
                      _visibilityWindow))
              .clamp(0.0, 1.0);

      final laneX =
          TrackGeometry.laneX(
        size.width,
        item.lane.toDouble(),
        t,
      );

      final y =
          TrackGeometry.depthY(
        size.height,
        t,
      );

      final scale =
          0.20 +
              (0.90 * t);

      final objectSize =
          44.0 * scale;

      widgets.add(
        Positioned(
          left:
              laneX -
                  objectSize / 2,

          top:
              y -
                  objectSize / 2,

          width:
              objectSize,

          height:
              objectSize,

          child:
              ItemWidget(
            instance: item,
            scale: scale,
          ),
        ),
      );
    }

    return widgets;
  }
}