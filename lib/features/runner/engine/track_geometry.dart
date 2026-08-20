import '../../../core/constants/game_constants.dart';

/// Single source of truth for the road's perspective geometry.
///
/// Depth:
///   t = 0.0 -> horizon / far distance
///   t = 1.0 -> runner / near camera
class TrackGeometry {
  TrackGeometry._();

  static double _lerp(
    double a,
    double b,
    double t,
  ) {
    return a + (b - a) * t;
  }

  static double _clampT(double t) {
    return t.clamp(0.0, 1.0);
  }

  /// Smooth S-curve used only for horizontal lane transition through depth.
  ///
  /// This keeps the road visually stable while making the expansion toward
  /// the camera feel less mechanically linear.
  static double _smoothStep(double t) {
    final x = _clampT(t);

    return x * x * (3.0 - 2.0 * x);
  }

  /// Left edge of the road at depth [t].
  static double roadLeftX(
    double screenWidth,
    double t,
  ) {
    final depth = _clampT(t);

    return _lerp(
      screenWidth *
          GameConstants.trackTopLeftXFraction,
      screenWidth *
          GameConstants.trackBottomLeftXFraction,
      depth,
    );
  }

  /// Right edge of the road at depth [t].
  static double roadRightX(
    double screenWidth,
    double t,
  ) {
    final depth = _clampT(t);

    return _lerp(
      screenWidth *
          GameConstants.trackTopRightXFraction,
      screenWidth *
          GameConstants.trackBottomRightXFraction,
      depth,
    );
  }

  /// Horizontal center of a lane.
  ///
  /// lanePosition:
  ///   0 = left
  ///   1 = center
  ///   2 = right
  ///
  /// Fractional values are supported during lane switching.
  static double laneX(
    double screenWidth,
    double lanePosition,
    double t,
  ) {
    final depth = _clampT(t);

    final left = roadLeftX(
      screenWidth,
      depth,
    );

    final right = roadRightX(
      screenWidth,
      depth,
    );

    final laneFraction =
        (lanePosition / 2.0)
            .clamp(0.0, 1.0);

    return _lerp(
      left,
      right,
      laneFraction,
    );
  }

  /// Vertical screen position at depth [t].
  ///
  /// The road begins visually near 42% of the screen and reaches the
  /// player's feet at 85%.
  static double depthY(
    double screenHeight,
    double t,
  ) {
    final depth = _clampT(t);

    return _lerp(
      screenHeight *
          GameConstants.trackHorizonYFraction,
      screenHeight *
          GameConstants.trackGroundYFraction,
      depth,
    );
  }

  /// Y coordinate of the runner's feet.
  static double groundY(
    double screenHeight,
  ) {
    return screenHeight *
        GameConstants.trackGroundYFraction;
  }

  /// Perspective scale for an object.
  ///
  /// Far:
  ///   ~0.05
  ///
  /// Middle:
  ///   ~0.17
  ///
  /// Near:
  ///   ~0.54
  ///
  /// Player:
  ///   1.00
  static double perspectiveScale(
    double t,
  ) {
    final depth = _clampT(t);

    final curvedDepth =
        depth ==
                0.0 ||
            depth ==
                1.0
            ? depth
            : _powDepth(depth);

    return _lerp(
      GameConstants.obstacleMinScale,
      GameConstants.obstacleMaxScale,
      curvedDepth,
    );
  }

  static double _powDepth(
    double depth,
  ) {
    // Manual exponentiation without importing dart:math.
    //
    // The exponent is currently 3.0, which gives the desired strong
    // perspective growth near the player.
    final exponent =
        GameConstants
            .obstaclePerspectiveExponent;

    if (exponent == 3.0) {
      return depth * depth * depth;
    }

    if (exponent == 2.0) {
      return depth * depth;
    }

    // Fallback for future tuning.
    //
    // Current production value is 3.0.
    return depth * depth * depth;
  }

  /// Smooth lane movement factor.
  ///
  /// Useful for future lane-switch animation without changing the physical
  /// lane positions.
  static double smoothLaneProgress(
    double progress,
  ) {
    return _smoothStep(progress);
  }
}