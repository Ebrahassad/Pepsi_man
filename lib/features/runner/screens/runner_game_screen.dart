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

class _RunnerGameScreenState extends State<RunnerGameScreen>
    with SingleTickerProviderStateMixin {
  late final RunnerController _controller;
  late final InputController _input;
  late final Ticker _ticker;

  Offset _dragPosition = Offset.zero;

  bool _navigatedAway = false;

  // ===========================================================================
  // VISUAL DEPTH
  // ===========================================================================

  /// Visual depth is deliberately much longer than the old 180.
  ///
  /// This allows obstacles to appear near the horizon and travel through the
  /// entire visible road before reaching the player.
  ///
  /// This DOES NOT change gameplay distance, collision distance or runner speed.
  static const double _visibilityWindow =
      GameConstants.visualDepthWindow;

  static const double _minimumVisibleDistance =
      GameConstants.minimumVisibleDistance;

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
        WorldData.byId(
      widget.level.worldId,
    );

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

  // ===========================================================================
  // TICK
  // ===========================================================================

  void _onTick(
    Duration elapsed,
  ) {
    _controller.tick(elapsed);
  }

  // ===========================================================================
  // ENGINE STATE
  // ===========================================================================

  void _onEngineUpdate() {
    if (_navigatedAway) {
      return;
    }

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

  // ===========================================================================
  // NAVIGATION
  // ===========================================================================

  void _goToVictory() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

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
      if (!mounted) {
        return;
      }

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

  // ===========================================================================
  // PAUSE
  // ===========================================================================

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

    if (!mounted) {
      return;
    }

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

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

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
  Widget build(
    BuildContext context,
  ) {
    final world =
        WorldData.byId(
      widget.level.worldId,
    );

    return Scaffold(
      body: GestureDetector(
        onPanStart:
            _input.onPanStart,

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

          builder: (
            context,
            _,
          ) {
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
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Container(
                      color: Colors.black,
                    );
                  },
                ),

                // =============================================================
                // TRACK OBJECTS
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

    // Player feet are always located at the near-camera ground plane.
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

    // Physics verticalPosition:
    // 0     = ground
    // < 0   = jumping
    //
    // Negative values move the visual sprite upward.
    final jumpOffset =
        engine.physics.verticalPosition *
            0.40;

    // -------------------------------------------------------------------------
    // PLAYER SIZE
    // -------------------------------------------------------------------------

    final runnerHeight =
        size.height *
            GameConstants.runnerHeightFraction;

    final runnerWidth =
        runnerHeight *
            GameConstants.runnerWidthToHeight;

    // -------------------------------------------------------------------------
    // PLAYER POSITION
    // -------------------------------------------------------------------------

    final runnerTop =
        groundY +
            jumpOffset -
            runnerHeight;

    return Positioned(
      left:
          laneX -
              runnerWidth / 2,

      top:
          runnerTop,

      width:
          runnerWidth,

      height:
          runnerHeight,

      child: RunnerWidget(
        state:
            engine.runner.state,
        size:
            runnerHeight,
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

    // =========================================================================
    // OBSTACLES
    // =========================================================================

    for (
      final ObstacleInstance obstacle
          in engine.obstacleEngine.active
    ) {
      if (!obstacle.hasAppeared) {
        continue;
      }

      // Distance between the obstacle and the runner.
      //
      // Large positive value = obstacle is far ahead.
      // Near zero = obstacle is at the player.
      // Negative = obstacle has passed the player.
      final relative =
          obstacle.distance -
              engine.distanceMeters;

      // Do not render objects behind the player or beyond the visual horizon.
      if (relative <
              _minimumVisibleDistance ||
          relative >
              _visibilityWindow) {
        continue;
      }

      // -----------------------------------------------------------------------
      // DEPTH
      // -----------------------------------------------------------------------
      //
      // relative = visibilityWindow -> t = 0
      // relative = 0                -> t = 1
      //
      // Therefore objects travel through the complete visible road.
      final t =
          (1.0 -
                  relative /
                      _visibilityWindow)
              .clamp(
        0.0,
        1.0,
      );

      // -----------------------------------------------------------------------
      // X POSITION
      // -----------------------------------------------------------------------

      final laneX =
          TrackGeometry.laneX(
        size.width,
        obstacle.lane.toDouble(),
        t,
      );

      // -----------------------------------------------------------------------
      // Y POSITION
      // -----------------------------------------------------------------------

      final groundY =
          TrackGeometry.depthY(
        size.height,
        t,
      );

      // -----------------------------------------------------------------------
      // PERSPECTIVE SCALE
      // -----------------------------------------------------------------------

      final scale =
          TrackGeometry.perspectiveScale(
        t,
      );

      // -----------------------------------------------------------------------
      // OBSTACLE
      // -----------------------------------------------------------------------
      //
      // ObstacleWidget receives the perspective scale only once.
      //
      // The obstacle is anchored:
      //
      // bottom center -> road
      //
      // This prevents it from appearing to float or sit above the road.
      widgets.add(
        Positioned(
          left: laneX,
          top: groundY,
          child: FractionalTranslation(
            translation:
                const Offset(
              -0.5,
              -1.0,
            ),
            child: ObstacleWidget(
              instance: obstacle,
              scale: scale,
            ),
          ),
        ),
      );
    }

    // =========================================================================
    // ITEMS
    // =========================================================================

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

      if (relative <
              _minimumVisibleDistance ||
          relative >
              _visibilityWindow) {
        continue;
      }

      // -----------------------------------------------------------------------
      // DEPTH
      // -----------------------------------------------------------------------

      final t =
          (1.0 -
                  relative /
                      _visibilityWindow)
              .clamp(
        0.0,
        1.0,
      );

      // -----------------------------------------------------------------------
      // X
      // -----------------------------------------------------------------------

      final laneX =
          TrackGeometry.laneX(
        size.width,
        item.lane.toDouble(),
        t,
      );

      // -----------------------------------------------------------------------
      // Y
      // -----------------------------------------------------------------------

      final groundY =
          TrackGeometry.depthY(
        size.height,
        t,
      );

      // -----------------------------------------------------------------------
      // SCALE
      // -----------------------------------------------------------------------

      final scale =
          TrackGeometry.perspectiveScale(
        t,
      );

      // Items are intentionally smaller than obstacles.
      final itemSize =
          44.0 * scale;

      widgets.add(
        Positioned(
          left:
              laneX -
                  itemSize / 2,

          // Keep the item slightly above the road.
          top:
              groundY -
                  itemSize * 1.05,

          width:
              itemSize,

          height:
              itemSize,

          child: ItemWidget(
            instance: item,
            scale: scale,
          ),
        ),
      );
    }

    return widgets;
  }
}