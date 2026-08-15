import '../../../core/constants/game_constants.dart';
import '../models/runner_model.dart';

/// Independent physics system for RunnerHero. Holds no widget/UI
/// references — pure simulation, updated every frame via [update].
class RunnerPhysics {
  double verticalPosition; // 0 = ground, negative = up (screen-space style)
  double verticalVelocity;
  bool isGrounded;

  double slideTimeRemaining;
  bool isSliding;

  int currentLane;
  int targetLane;
  double laneProgress; // 0..1 progress of a lane switch animation
  double lanePosition; // interpolated x offset in "lane units"

  double forwardSpeed;
  final double maxSpeed;
  final double acceleration;

  final double gravity;
  final double jumpVelocity;
  final double slideDuration;
  final double laneSwitchDuration;

  RunnerPhysics({
    double startLane = 1,
    double baseSpeed = GameConstants.defaultBaseSpeed,
    double? maxSpeedOverride,
    double? accelerationOverride,
    double? gravityOverride,
    double? jumpVelocityOverride,
    double? slideDurationOverride,
  })  : verticalPosition = 0,
        verticalVelocity = 0,
        isGrounded = true,
        slideTimeRemaining = 0,
        isSliding = false,
        currentLane = startLane.toInt(),
        targetLane = startLane.toInt(),
        laneProgress = 1.0,
        lanePosition = startLane,
        forwardSpeed = baseSpeed,
        maxSpeed = maxSpeedOverride ?? GameConstants.defaultMaxSpeed,
        acceleration = accelerationOverride ?? GameConstants.defaultAcceleration,
        gravity = gravityOverride ?? GameConstants.gravity,
        jumpVelocity = jumpVelocityOverride ?? GameConstants.jumpVelocity,
        slideDuration = slideDurationOverride ?? GameConstants.slideDurationSeconds;

  bool get isJumping => !isGrounded && verticalVelocity < 0;
  bool get isFalling => !isGrounded && verticalVelocity >= 0;

  void jump() {
    if (!isGrounded || isSliding) return;
    verticalVelocity = jumpVelocity;
    isGrounded = false;
  }

  void slide() {
    if (!isGrounded || isSliding) return;
    isSliding = true;
    slideTimeRemaining = slideDuration;
  }

  void requestLaneChange(int direction) {
    // direction: -1 left, +1 right
    final next = (targetLane + direction).clamp(
      GameConstants.laneLeft,
      GameConstants.laneRight,
    );
    if (next == targetLane) return;
    currentLane = targetLane;
    targetLane = next;
    laneProgress = 0.0;
  }

  void applySpeedMultiplier(double multiplier) {
    forwardSpeed = (forwardSpeed * multiplier).clamp(0, maxSpeed * 2);
  }

  /// Advances the simulation by [dt] seconds.
  void update(double dt) {
    // Forward speed ramps toward maxSpeed.
    if (forwardSpeed < maxSpeed) {
      forwardSpeed = (forwardSpeed + acceleration * dt).clamp(0, maxSpeed);
    }

    // Vertical (jump/gravity)
    if (!isGrounded) {
      verticalVelocity += gravity * dt;
      verticalPosition += verticalVelocity * dt;
      if (verticalPosition >= GameConstants.groundY) {
        verticalPosition = GameConstants.groundY;
        verticalVelocity = 0;
        isGrounded = true;
      }
    }

    // Slide timer
    if (isSliding) {
      slideTimeRemaining -= dt;
      if (slideTimeRemaining <= 0) {
        isSliding = false;
        slideTimeRemaining = 0;
      }
    }

    // Lane switch interpolation
    if (laneProgress < 1.0) {
      final step = dt / laneSwitchDuration;
      laneProgress = (laneProgress + step).clamp(0.0, 1.0);
      lanePosition = currentLane + (targetLane - currentLane) * laneProgress;
      if (laneProgress >= 1.0) {
        currentLane = targetLane;
        lanePosition = targetLane.toDouble();
      }
    } else {
      lanePosition = targetLane.toDouble();
    }
  }

  RunnerState resolveState({bool isHit = false, bool isCelebrating = false}) {
    if (isHit) return RunnerState.hit;
    if (isCelebrating) return RunnerState.celebrating;
    if (isFalling) return RunnerState.falling;
    if (isJumping) return RunnerState.jumping;
    if (isSliding) return RunnerState.sliding;
    return RunnerState.running;
  }

  double get hitboxHeightMultiplier => isSliding ? 0.5 : 1.0;
}
