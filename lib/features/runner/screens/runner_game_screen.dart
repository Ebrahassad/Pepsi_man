import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../../core/audio/audio_manager.dart';
import '../../../core/constants/game_constants.dart';
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

class _RunnerGameScreenState
    extends State<RunnerGameScreen>
    with SingleTickerProviderStateMixin {
  late final RunnerController _controller;
  late final InputController _input;
  late final Ticker _ticker;

  Offset _dragPosition = Offset.zero;
  bool _navigatedAway = false;

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

    _ticker = createTicker(_onTick)
      ..start();

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

    if (reason ==
        RunEndReason.levelComplete) {
      _navigatedAway = true;
      _ticker.stop();
      _goToVictory();
    } else if (reason ==
        RunEndReason.gameOver) {
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
        _controller.restart(widget.level);
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
                // -----------------------------------------------------------
                // BACKGROUND
                // -----------------------------------------------------------
                //
                // The background artwork is now the visible road/environment.
                // No procedural road is painted over it.
                //
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

                // -----------------------------------------------------------
                // TRACK OBJECTS + RUNNER
                // -----------------------------------------------------------
                //
                // Camera shake affects gameplay objects only.
                // The background remains stable.
                //
                Transform.translate(
                  offset: Offset(
                    engine.cameraEngine.offsetX,
                    engine.cameraEngine.offsetY,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ..._buildTrackObjects(
                        context,
                        engine,
                      ),
                      _buildRunner(
                        context,
                        engine,
                      ),
                    ],
                  ),
                ),

                // -----------------------------------------------------------
                // HUD
                // -----------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // RUNNER
  // ---------------------------------------------------------------------------

  Widget _buildRunner(
    BuildContext context,
    RunnerEngine engine,
  ) {
    final size =
        MediaQuery.of(context).size;

    const double runnerWidth = 90.0;
    const double runnerHeight = 90.0;

    final t = 1.0;

    final laneX = TrackGeometry.laneX(
      size.width,
      engine.physics.lanePosition,
      t,
    );

    final groundY =
        TrackGeometry.groundY(
      size.height,
    );

    final jumpOffset =
        engine.physics.verticalPosition *
            0.4;

    return Positioned(
      left: laneX -
          runnerWidth / 2,
      top: groundY +
          jumpOffset -
          runnerHeight,
      width: runnerWidth,
      height: runnerHeight,
      child: RunnerWidget(
        state: engine.runner.state,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TRACK OBJECTS
  // ---------------------------------------------------------------------------

  List<Widget> _buildTrackObjects(
    BuildContext context,
    RunnerEngine engine,
  ) {
    final size =
        MediaQuery.of(context).size;

    final widgets = <Widget>[];

    final speed =
        engine.physics.forwardSpeed;

    // ---------------------------------------------------------
    // Dynamic visibility window.
    // ---------------------------------------------------------
    //
    // The old value was fixed at 45 units.
    // At higher speeds that made objects appear too late.
    //
    const double visibilityTimeSeconds = 2.2;

    final visibilityWindow =
        (speed * visibilityTimeSeconds)
            .clamp(180.0, 1400.0);

    // ---------------------------------------------------------
    // OBSTACLES
    // ---------------------------------------------------------

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

      if (relative < -20 ||
          relative > visibilityWindow) {
        continue;
      }

      final t = _depthForRelative(
        relative,
        visibilityWindow,
      );

      final scale =
          _objectScale(t);

      final x =
          TrackGeometry.laneX(
            size.width,
            obstacle.lane.toDouble(),
            t,
          ) -
          (40 * scale);

      final y =
          TrackGeometry.depthY(
            size.height,
            t,
          ) -
          (40 * scale);

      widgets.add(
        Positioned(
          left: x,
          top: y,
          child: ObstacleWidget(
            instance: obstacle,
            scale: scale,
          ),
        ),
      );
    }

    // ---------------------------------------------------------
    // ITEMS
    // ---------------------------------------------------------

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

      if (relative < -20 ||
          relative > visibilityWindow) {
        continue;
      }

      final t = _depthForRelative(
        relative,
        visibilityWindow,
      );

      final scale =
          _objectScale(t);

      final x =
          TrackGeometry.laneX(
            size.width,
            item.lane.toDouble(),
            t,
          ) -
          (22 * scale);

      final y =
          TrackGeometry.depthY(
            size.height,
            t,
          ) -
          (22 * scale);

      widgets.add(
        Positioned(
          left: x,
          top: y,
          child: ItemWidget(
            instance: item,
            scale: scale,
          ),
        ),
      );
    }

    return widgets;
  }

  // ---------------------------------------------------------------------------
  // DEPTH
  // ---------------------------------------------------------------------------

  /// Converts world distance into perspective depth.
  ///
  /// t = 0 -> far / horizon
  /// t = 1 -> near / player
  double _depthForRelative(
    double relative,
    double visibilityWindow,
  ) {
    final normalized =
        1 -
            (relative /
                visibilityWindow);

    return normalized.clamp(
      0.0,
      1.0,
    );
  }

  // ---------------------------------------------------------------------------
  // OBJECT SCALE
  // ---------------------------------------------------------------------------

  double _objectScale(
    double t,
  ) {
    return 0.4 + t * 0.9;
  }
}