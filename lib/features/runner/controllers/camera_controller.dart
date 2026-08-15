import '../engine/camera_engine.dart';

/// Thin adapter between [CameraEngine] and the widget layer. Exists so
/// screens depend on a stable controller API even if the underlying
/// camera engine's internals change.
class CameraController {
  final CameraEngine engine;

  CameraController({CameraEngine? engine}) : engine = engine ?? CameraEngine();

  double get offsetX => engine.offsetX;
  double get offsetY => engine.offsetY;
  double get depthScroll => engine.depthScroll;

  void triggerShake({double durationSeconds = 0.25, double magnitude = 10}) {
    engine.shake(durationSeconds: durationSeconds, magnitude: magnitude);
  }

  void reset() => engine.reset();
}
