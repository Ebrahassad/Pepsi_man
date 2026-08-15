import 'package:flutter/foundation.dart';

import '../engine/runner_engine.dart';
import '../models/level_model.dart';

/// Drives one gameplay run and exposes it to the widget tree. The screen
/// owns a `Ticker` (via SingleTickerProviderStateMixin) and calls [tick]
/// every frame — this class does not create its own Ticker so it stays
/// easily unit-testable.
class RunnerController extends ChangeNotifier {
  late RunnerEngine engine;
  bool isPaused = false;
  Duration? _lastElapsed;

  RunnerController({required LevelModel level, int? seed}) {
    engine = RunnerEngine(level: level, seed: seed);
  }

  void tick(Duration elapsed) {
    if (isPaused) {
      _lastElapsed = elapsed;
      return;
    }
    final last = _lastElapsed ?? elapsed;
    final dtMs = (elapsed - last).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;

    // Clamp dt to avoid huge jumps after a dropped frame or app resume.
    final dt = dtMs.clamp(0.0, 0.05);
    if (dt <= 0) return;

    engine.update(dt);
    notifyListeners();
  }

  void handleInput(RunnerInputAction action) {
    if (isPaused) return;
    engine.handleInput(action);
  }

  void pause() {
    isPaused = true;
    notifyListeners();
  }

  void resume() {
    isPaused = false;
    _lastElapsed = null; // avoid a big dt jump on resume
    notifyListeners();
  }

  void restart(LevelModel level, {int? seed}) {
    engine = RunnerEngine(level: level, seed: seed);
    isPaused = false;
    _lastElapsed = null;
    notifyListeners();
  }

  RunEndReason get endReason => engine.endReason;
  bool get isRunning => engine.endReason == RunEndReason.none && !isPaused;
}
