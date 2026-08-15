import 'dart:math';

/// Drives the forward-motion / depth illusion and camera shake. Pure
/// logic — a widget reads `offsetX/offsetY/zoom` each frame to render.
class CameraEngine {
  double shakeTimeRemaining = 0;
  double shakeMagnitude = 0;
  double offsetX = 0;
  double offsetY = 0;
  double depthScroll = 0; // used to animate background parallax layers

  final Random _random = Random();

  void update(double dt, double forwardSpeed) {
    depthScroll += forwardSpeed * dt;

    if (shakeTimeRemaining > 0) {
      shakeTimeRemaining -= dt;
      final intensity = shakeMagnitude * (shakeTimeRemaining.clamp(0, 1));
      offsetX = (_random.nextDouble() * 2 - 1) * intensity;
      offsetY = (_random.nextDouble() * 2 - 1) * intensity;
      if (shakeTimeRemaining <= 0) {
        shakeTimeRemaining = 0;
        offsetX = 0;
        offsetY = 0;
      }
    }
  }

  void shake({double durationSeconds = 0.25, double magnitude = 10}) {
    shakeTimeRemaining = durationSeconds;
    shakeMagnitude = magnitude;
  }

  void reset() {
    shakeTimeRemaining = 0;
    shakeMagnitude = 0;
    offsetX = 0;
    offsetY = 0;
    depthScroll = 0;
  }
}
