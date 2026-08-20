import 'package:flutter/material.dart';

import '../models/runner_model.dart';

/// Renders the runner using exactly one animation state at a time.
///
/// Important:
/// - A state change completely replaces the previous animation.
/// - Falling never uses Hit sprites.
/// - Hit has its own animation.
/// - The animation is not allowed to keep an old frame after a state change.
/// - Only one Image.asset is mounted at any moment.
class RunnerWidget extends StatefulWidget {
  final RunnerState state;
  final double size;
  final bool facingRight;

  const RunnerWidget({
    super.key,
    required this.state,
    this.size = 90,
    this.facingRight = true,
  });

  @override
  State<RunnerWidget> createState() => _RunnerWidgetState();
}

class _RunnerWidgetState extends State<RunnerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  int _frameIndex = 0;

  /// Used to identify the currently active animation state.
  ///
  /// This prevents an old animation callback from changing the frame
  /// after the state has already changed.
  int _animationGeneration = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: _durationForState(widget.state),
    );

    _controller.addListener(_onTick);

    _configureAnimation(widget.state);
  }

  // ---------------------------------------------------------------------------
  // ANIMATION CONFIGURATION
  // ---------------------------------------------------------------------------

  Duration _durationForState(RunnerState state) {
    switch (state) {
      case RunnerState.running:
        return const Duration(milliseconds: 480);

      case RunnerState.jumping:
        return const Duration(milliseconds: 420);

      case RunnerState.sliding:
        return const Duration(milliseconds: 360);

      case RunnerState.hit:
        return const Duration(milliseconds: 360);

      case RunnerState.falling:
        // Falling uses the last jump frame as a stable pose.
        //
        // No animation is required here because there is no dedicated
        // falling sprite set in the current asset list.
        return const Duration(milliseconds: 420);

      case RunnerState.celebrating:
        return const Duration(milliseconds: 600);

      case RunnerState.idle:
        return const Duration(milliseconds: 320);
    }
  }

  List<String> _framesForState(RunnerState state) {
    switch (state) {
      case RunnerState.running:
        return RunnerModel.runCycleAssets;

      case RunnerState.jumping:
        return RunnerModel.jumpCycleAssets;

      case RunnerState.sliding:
        return RunnerModel.slideCycleAssets;

      case RunnerState.hit:
        return RunnerModel.hitCycleAssets;

      case RunnerState.celebrating:
        return RunnerModel.celebrateCycleAssets;

      case RunnerState.falling:
        // IMPORTANT:
        //
        // There are no dedicated falling assets in the current project.
        // Previously this returned hitCycleAssets, which caused the runner
        // to visually switch from jump -> HIT while simply descending.
        //
        // Instead, use the final jump pose as a stable falling pose.
        return <String>[
          RunnerModel.jumpCycleAssets.last,
        ];

      case RunnerState.idle:
        return const <String>[
          'assets/images/characters/runner/runner_run_01.webp',
        ];
    }
  }

  bool _shouldAnimate(RunnerState state) {
    switch (state) {
      case RunnerState.running:
      case RunnerState.jumping:
      case RunnerState.sliding:
      case RunnerState.hit:
      case RunnerState.celebrating:
        return true;

      case RunnerState.falling:
      case RunnerState.idle:
        return false;
    }
  }

  void _configureAnimation(RunnerState state) {
    final generation = ++_animationGeneration;

    _controller
      ..stop()
      ..reset()
      ..duration = _durationForState(state);

    _frameIndex = 0;

    if (_shouldAnimate(state)) {
      _controller.repeat();
    }

    // Make sure no stale animation callback from a previous state
    // can modify the current widget.
    if (generation != _animationGeneration) {
      return;
    }
  }

  // ---------------------------------------------------------------------------
  // FRAME UPDATE
  // ---------------------------------------------------------------------------

  void _onTick() {
    if (!mounted) return;

    final frames = _framesForState(widget.state);

    if (frames.length <= 1) {
      if (_frameIndex != 0) {
        setState(() {
          _frameIndex = 0;
        });
      }

      return;
    }

    final newFrame =
        (_controller.value * frames.length).floor() % frames.length;

    if (newFrame == _frameIndex) {
      return;
    }

    setState(() {
      _frameIndex = newFrame;
    });
  }

  // ---------------------------------------------------------------------------
  // STATE CHANGE
  // ---------------------------------------------------------------------------

  @override
  void didUpdateWidget(covariant RunnerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state == widget.state) {
      return;
    }

    // Completely terminate the previous state's animation before starting
    // the new one.
    _configureAnimation(widget.state);

    if (mounted) {
      setState(() {});
    }
  }

  // ---------------------------------------------------------------------------
  // CURRENT ASSET
  // ---------------------------------------------------------------------------

  String get _assetPath {
    final frames = _framesForState(widget.state);

    if (frames.isEmpty) {
      return RunnerModel.assetByState[RunnerState.idle]!;
    }

    if (_frameIndex >= frames.length) {
      return frames.first;
    }

    return frames[_frameIndex];
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: !widget.facingRight,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Image.asset(
          _assetPath,
          key: ValueKey<String>(_assetPath),
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return _FallbackRunnerPainter(
              state: widget.state,
              size: widget.size,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();

    super.dispose();
  }
}

// =============================================================================
// FALLBACK
// =============================================================================

/// Fallback used only if an actual sprite is missing.
class _FallbackRunnerPainter extends StatelessWidget {
  final RunnerState state;
  final double size;

  const _FallbackRunnerPainter({
    required this.state,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RunnerPainter(
        state: state,
      ),
    );
  }
}

class _RunnerPainter extends CustomPainter {
  final RunnerState state;

  _RunnerPainter({
    required this.state,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final bodyPaint = Paint()
      ..color = _colorForState(state);

    final headPaint = Paint()
      ..color = const Color(0xFFFFCCA0);

    double bodyHeight = size.height * 0.55;
    double bodyTop = size.height * 0.25;

    if (state == RunnerState.sliding) {
      bodyHeight = size.height * 0.3;
      bodyTop = size.height * 0.55;
    } else if (
        state == RunnerState.jumping ||
        state == RunnerState.falling) {
      bodyTop = size.height * 0.1;
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.3,
          bodyTop,
          size.width * 0.4,
          bodyHeight,
        ),
        const Radius.circular(10),
      ),
      bodyPaint,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.5,
        bodyTop - size.height * 0.08,
      ),
      size.width * 0.14,
      headPaint,
    );
  }

  Color _colorForState(RunnerState state) {
    switch (state) {
      case RunnerState.hit:
        return const Color(0xFFE53935);

      case RunnerState.falling:
      case RunnerState.jumping:
        return const Color(0xFF1E88E5);

      case RunnerState.celebrating:
        return const Color(0xFFFFC107);

      case RunnerState.sliding:
        return const Color(0xFF43A047);

      default:
        return const Color(0xFF1E88E5);
    }
  }

  @override
  bool shouldRepaint(
    covariant _RunnerPainter oldDelegate,
  ) {
    return oldDelegate.state != state;
  }
}