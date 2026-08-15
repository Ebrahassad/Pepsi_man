import 'package:flutter/material.dart';
import '../engine/runner_engine.dart';
import '../models/settings_model.dart';

/// Converts raw swipe gestures (or button taps, depending on
/// [ControlType]) into [RunnerInputAction]s. Kept separate from
/// RunnerController so input handling can be unit tested without a
/// running game loop.
class InputController {
  static const double _swipeVelocityThreshold = 250.0;
  static const double _swipeDistanceThreshold = 24.0;

  Offset _dragStart = Offset.zero;
  ControlType controlType;

  InputController({this.controlType = ControlType.swipe});

  void onPanStart(DragStartDetails details) {
    _dragStart = details.globalPosition;
  }

  RunnerInputAction? onPanEnd(DragEndDetails details, Offset currentPosition) {
    if (controlType != ControlType.swipe) return null;

    final delta = currentPosition - _dragStart;
    final velocity = details.velocity.pixelsPerSecond;

    final isFastEnough = velocity.distance > _swipeVelocityThreshold;
    final isFarEnough = delta.distance > _swipeDistanceThreshold;
    if (!isFastEnough && !isFarEnough) return null;

    if (delta.dx.abs() > delta.dy.abs()) {
      return delta.dx > 0 ? RunnerInputAction.laneRight : RunnerInputAction.laneLeft;
    } else {
      return delta.dy > 0 ? RunnerInputAction.slide : RunnerInputAction.jump;
    }
  }

  // Button-based input (always available regardless of controlType, since
  // the spec requires optional on-screen buttons too).
  RunnerInputAction onButtonLeft() => RunnerInputAction.laneLeft;
  RunnerInputAction onButtonRight() => RunnerInputAction.laneRight;
  RunnerInputAction onButtonJump() => RunnerInputAction.jump;
  RunnerInputAction onButtonSlide() => RunnerInputAction.slide;
}
