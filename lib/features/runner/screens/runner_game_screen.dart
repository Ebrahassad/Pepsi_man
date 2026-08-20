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

  /// Long visual distance so obstacles can be seen far down the road.
  ///
  /// This controls ONLY the visual representation.
  ///
  /// It does NOT change:
  /// - gameplay distance
  /// - collision distance
  /// - runner speed
  /// - obstacle spawn distance
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

    // -------------------------------------------------------------------------
    // GROUND POSITION
    // -------------------------------------------------------------------------
    //
    // The player's feet are placed exactly on the near-camera ground plane.
    //

    final groundY =
        TrackGeometry.groundY(
      size.height,
    );

    // -------------------------------------------------------------------------
    // LANE POSITION
    // -------------------------------------------------------------------------

    final laneX =
        TrackGeometry.laneX(
      size.width,
      engine.physics.lanePosition,
      1.0,
    );

    // -------------------------------------------------------------------------
    // JUMP OFFSET
    // -------------------------------------------------------------------------
    //
    // Physics verticalPosition:
    //  0     = ground
    //  < 0   = above ground
    //
    // Therefore multiplying it by a positive factor moves the sprite upward.
    //

    final jumpOffset =
        engine.physics.verticalPosition *
            0.40;

    // -------------------------------------------------------------------------
    // PLAYER SIZE
    // -------------------------------------------------------------------------
    //
    // Height = 20% of screen height.
    // Width  = 55% of height.
    //
    // These values come from GameConstants so the player scales correctly
    // across different screen sizes.
    //

    final runnerHeight =
        size.height *
            GameConstants.runnerHeightFraction;

    final runnerWidth =
        runnerHeight *
            GameConstants.runnerWidthToHeight;

    // -------------------------------------------------------------------------
    // PLAYER POSITION
    // -------------------------------------------------------------------------
    //
    // The bottom of the player's box is aligned with groundY.
    //
    // This means the feet stay on the road rather than the center of the
    // sprite being placed on the road.
    //

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
        state: engine.runner.state,
        size: runnerHeight,
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

    final objects =
        <_TrackRenderObject>[];

    // =========================================================================
    // OBSTACLES
    // =========================================================================

    for (
      final ObstacleInstance obstacle
          in engine.obstacleEngine.active
    ) {
      // Do not draw obstacles that have not entered their visual lifecycle.
      if (!obstacle.hasAppeared) {
        continue;
      }

      // -----------------------------------------------------------------------
      // RELATIVE DISTANCE
      // -----------------------------------------------------------------------

      final relative =
          obstacle.distance -
              engine.distanceMeters;

      // Behind the runner OR farther than the visual depth.
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
      // t = 0 → horizon / very far
      // t = 1 → player / near camera
      //

      final t =
          (1.0 -
                  relative /
                      _visibilityWindow)
              .clamp(0.0, 1.0);

      // -----------------------------------------------------------------------
      // HORIZONTAL PERSPECTIVE
      // -----------------------------------------------------------------------

      final laneX =
          TrackGeometry.laneX(
        size.width,
        obstacle.lane.toDouble(),
        t,
      );

      // -----------------------------------------------------------------------
      // VERTICAL PERSPECTIVE
      // -----------------------------------------------------------------------

      final groundY =
          TrackGeometry.depthY(
        size.height,
        t,
      );

      // -----------------------------------------------------------------------
      // OBJECT SCALE
      // -----------------------------------------------------------------------
      //
      // TrackGeometry handles the perspective curve.
      //
      // This replaces the old linear:
      //
      // 0.20 + (0.90 * t)
      //
      // which caused objects to grow too quickly.
      //

      final scale =
          TrackGeometry.perspectiveScale(
        t,
      );

      // -----------------------------------------------------------------------
      // ADD OBJECT
      // -----------------------------------------------------------------------
      //
      // ObstacleWidget receives the perspective scale.
      //
      // The object is anchored at:
      //
      // BOTTOM CENTER
      //
      // of the road position.
      //

      objects.add(
        _TrackRenderObject(
          depth: t,
          widget: Positioned(
            left: laneX,
            top: groundY,
            child: FractionalTranslation(
              translation: const Offset(
                -0.5,
                -1.0,
              ),
              child: ObstacleWidget(
                instance: obstacle,
                scale: scale,
              ),
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

      // -----------------------------------------------------------------------
      // RELATIVE DISTANCE
      // -----------------------------------------------------------------------

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
              .clamp(0.0, 1.0);

      // -----------------------------------------------------------------------
      // LANE
      // -----------------------------------------------------------------------

      final laneX =
          TrackGeometry.laneX(
        size.width,
        item.lane.toDouble(),
        t,
      );

      // -----------------------------------------------------------------------
      // GROUND
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

      // Items remain smaller than obstacles.
      final itemSize =
          44.0 * scale;

      // -----------------------------------------------------------------------
      // ADD ITEM
      // -----------------------------------------------------------------------

      objects.add(
        _TrackRenderObject(
          depth: t,
          widget: Positioned(
            left:
                laneX -
                    itemSize / 2,

            // Float slightly above the road.
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
        ),
      );
    }

    // =========================================================================
    // DEPTH SORTING
    // =========================================================================
    //
    // Far objects are rendered first.
    //
    // Near objects are rendered afterward.
    //
    // This keeps the visual layering consistent with the road perspective.
    //

    objects.sort(
      (a, b) =>
          a.depth.compareTo(
        b.depth,
      ),
    );

    return objects
        .map(
          (object) => object.widget,
        )
        .toList();
  }
}

// =============================================================================
// TRACK RENDER OBJECT
// =============================================================================

/// Small wrapper used only for depth sorting before the widgets are inserted
/// into the Stack.
class _TrackRenderObject {
  final double depth;
  final Widget widget;

  const _TrackRenderObject({
    required this.depth,
    required this.widget,
  });
}