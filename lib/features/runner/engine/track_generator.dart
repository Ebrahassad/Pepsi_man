import '../../../core/constants/game_constants.dart';

/// The single source of truth for the track's perspective geometry.
///
/// Previously `TrackPainter` computed its own road trapezoid (for drawing)
/// while `RunnerGameScreen._laneToX` computed a completely separate, flat
/// (non-perspective) lane mapping for positioning obstacles/items/runner.
/// The two never matched, and neither was tied to where the road is
/// actually painted in each world's background artwork.
///
/// `TrackGeometry` replaces both: it's pure math (no drawing), used by
/// every screen/widget that needs to know "where is lane X at depth t on
/// screen". Tune the fractions in [GameConstants] to line this up with the
/// artwork's painted road.
///
/// Depth convention: `t = 0` is far away (at the horizon), `t = 1` is at
/// the player's feet (nearest). This matches the `t` already computed in
/// `RunnerGameScreen` from `relative / visibilityWindow`.
class TrackGeometry {
  TrackGeometry._();

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  /// X (in pixels) of the road's left edge at depth [t].
  static double roadLeftX(double screenWidth, double t) => _lerp(
        screenWidth * GameConstants.trackTopLeftXFraction,
        screenWidth * GameConstants.trackBottomLeftXFraction,
        t,
      );

  /// X (in pixels) of the road's right edge at depth [t].
  static double roadRightX(double screenWidth, double t) => _lerp(
        screenWidth * GameConstants.trackTopRightXFraction,
        screenWidth * GameConstants.trackBottomRightXFraction,
        t,
      );

  /// Horizontal center-X (in pixels) of a lane position at depth [t].
  /// [lanePosition] is 0 (left) .. 2 (right); fractional values (e.g. 0.5)
  /// are valid mid lane-switch.
  static double laneX(double screenWidth, double lanePosition, double t) {
    final left = roadLeftX(screenWidth, t);
    final right = roadRightX(screenWidth, t);
    final laneFraction = (lanePosition / 2).clamp(0.0, 1.0);
    return _lerp(left, right, laneFraction);
  }

  /// Vertical Y (in pixels) at depth [t] — from the horizon to the ground.
  static double depthY(double screenHeight, double t) => _lerp(
        screenHeight * GameConstants.trackHorizonYFraction,
        screenHeight * GameConstants.trackGroundYFraction,
        t,
      );

  /// The ground line (t = 1) — where the runner's feet sit.
  static double groundY(double screenHeight) =>
      screenHeight * GameConstants.trackGroundYFraction;
}