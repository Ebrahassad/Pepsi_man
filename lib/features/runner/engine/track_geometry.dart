import '../../../core/constants/game_constants.dart';

/// Single source of truth for the visual perspective of the running track.
///
/// Depth:
/// t = 0.0 -> horizon / very far
/// t = 1.0 -> player / near camera
class TrackGeometry {
  TrackGeometry._();

  static double _lerp(
    double a,
    double b,
    double t,
  ) {
    return a + (b - a) * t;
  }

  // ===========================================================================
  // ROAD EDGES
  // ===========================================================================

  /// Left edge of the road at depth [t].
  static double roadLeftX(
    double screenWidth,
    double t,
  ) {
    final depth = t.clamp(0.0, 1.0);

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
    final depth = t.clamp(0.0, 1.0);

    return _lerp(
      screenWidth *
          GameConstants.trackTopRightXFraction,
      screenWidth *
          GameConstants.trackBottomRightXFraction,
      depth,
    );
  }

  // ===========================================================================
  // LANES
  // ===========================================================================

  /// Returns the X coordinate of a lane at depth [t].
  ///
  /// lanePosition:
  /// 0 = left
  /// 1 = center
  /// 2 = right
  ///
  /// Fractional values are supported during lane switching.
  static double laneX(
    double screenWidth,
    double lanePosition,
    double t,
  ) {
    final depth = t.clamp(0.0, 1.0);

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

  // ===========================================================================
  // VERTICAL PERSPECTIVE
  // ===========================================================================

  /// Returns the screen Y coordinate for depth [t].
  ///
  /// The interpolation is intentionally nonlinear.
  ///
  /// Far objects stay visually close to the horizon for longer and then
  /// travel through the lower part of the road much faster.
  static double depthY(
    double screenHeight,
    double t,
  ) {
    final depth = t.clamp(0.0, 1.0);

    // Smooth perspective curve.
    //
    // This is deliberately stronger than a simple linear interpolation
    // because the artwork has a long road extending toward the horizon.
    final curvedDepth =
        depth * depth;

    return _lerp(
      screenHeight *
          GameConstants.trackHorizonYFraction,
      screenHeight *
          GameConstants.trackGroundYFraction,
      curvedDepth,
    );
  }

  /// Ground Y at the player's feet.
  static double groundY(
    double screenHeight,
  ) {
    return screenHeight *
        GameConstants.trackGroundYFraction;
  }

  // ===========================================================================
  // OBJECT SCALE
  // ===========================================================================

  /// Perspective scale for obstacles/items.
  ///
  /// t = 0.0 -> very far -> tiny
  /// t = 0.5 -> still relatively small
  /// t = 0.8 -> noticeably large
  /// t = 1.0 -> full size
  ///
  /// Uses the configured exponent from GameConstants.
  static double perspectiveScale(
    double t,
  ) {
    final depth = t.clamp(0.0, 1.0);

    final exponent =
        GameConstants
            .obstaclePerspectiveExponent;

    final normalized =
        depth == 0.0
            ? 0.0
            : _pow(
                depth,
                exponent,
            );

    return _lerp(
      GameConstants.obstacleMinScale,
      GameConstants.obstacleMaxScale,
      normalized,
    );
  }

  /// Small local power implementation.
  ///
  /// Avoids introducing another dependency into the geometry class.
  static double _pow(
    double value,
    double exponent,
  ) {
    if (value <= 0) {
      return 0.0;
    }

    if (exponent == 1.0) {
      return value;
    }

    if (exponent == 2.0) {
      return value * value;
    }

    if (exponent == 3.0) {
      return value * value * value;
    }

    // Fallback for future tuning values.
    //
    // For the current configuration exponent = 3.0, so this branch
    // normally isn't used.
    double result = 1.0;
    int whole =
        exponent.floor();

    for (int i = 0; i < whole; i++) {
      result *= value;
    }

    final fractional =
        exponent - whole;

    if (fractional > 0) {
      result *=
          value == 0
              ? 0
              : value;
    }

    return result;
  }
}