import 'package:flutter/material.dart';

import '../models/runner_model.dart';

/// Renders RunnerHero at the given animation state. Cycles through the
/// 3 running frames while `state == running`. If an asset file is
/// missing (not yet supplied by the user), falls back to a simple drawn
/// silhouette instead of crashing — see rule 64 in the spec.
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

class _RunnerWidgetState extends State<RunnerWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _frameIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(_onTick);
    if (widget.state == RunnerState.running) {
      _controller.repeat();
    }
  }

  void _onTick() {
    final newFrame = (_controller.value * RunnerModel.runCycleAssets.length).floor() %
        RunnerModel.runCycleAssets.length;
    if (newFrame != _frameIndex) {
      setState(() => _frameIndex = newFrame);
    }
  }

  @override
  void didUpdateWidget(covariant RunnerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == RunnerState.running && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.state != RunnerState.running && _controller.isAnimating) {
      _controller.stop();
      _frameIndex = 0;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  String get _assetPath {
    if (widget.state == RunnerState.running) {
      return RunnerModel.runCycleAssets[_frameIndex];
    }
    return RunnerModel.assetByState[widget.state] ??
        RunnerModel.assetByState[RunnerState.idle]!;
  }

  @override
  Widget build(BuildContext context) {
    return Transform.flip(
      flipX: !widget.facingRight,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Image.asset(
          _assetPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => _FallbackRunnerPainter(
            state: widget.state,
            size: widget.size,
          ),
        ),
      ),
    );
  }
}

/// Simple drawn placeholder used only when the real sprite asset hasn't
/// been added yet by the developer. Keeps the game fully playable/testable
/// with zero art.
class _FallbackRunnerPainter extends StatelessWidget {
  final RunnerState state;
  final double size;

  const _FallbackRunnerPainter({required this.state, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RunnerPainter(state: state),
    );
  }
}

class _RunnerPainter extends CustomPainter {
  final RunnerState state;

  _RunnerPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = _colorForState(state);
    final headPaint = Paint()..color = const Color(0xFFFFCCA0);

    double bodyHeight = size.height * 0.55;
    double bodyTop = size.height * 0.25;

    if (state == RunnerState.sliding) {
      bodyHeight = size.height * 0.3;
      bodyTop = size.height * 0.55;
    } else if (state == RunnerState.jumping || state == RunnerState.falling) {
      bodyTop = size.height * 0.1;
    }

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.3, bodyTop, size.width * 0.4, bodyHeight),
        const Radius.circular(10),
      ),
      bodyPaint,
    );

    // Head
    canvas.drawCircle(
      Offset(size.width * 0.5, bodyTop - size.height * 0.08),
      size.width * 0.14,
      headPaint,
    );
  }

  Color _colorForState(RunnerState state) {
    switch (state) {
      case RunnerState.hit:
      case RunnerState.falling:
        return const Color(0xFFE53935);
      case RunnerState.celebrating:
        return const Color(0xFFFFC107);
      case RunnerState.sliding:
        return const Color(0xFF43A047);
      default:
        return const Color(0xFF1E88E5);
    }
  }

  @override
  bool shouldRepaint(covariant _RunnerPainter oldDelegate) => oldDelegate.state != state;
}
