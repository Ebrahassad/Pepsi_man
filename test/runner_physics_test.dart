import 'package:flutter_test/flutter_test.dart';
import 'package:pepsi_runner/features/runner/engine/runner_physics.dart';

void main() {
  group('RunnerPhysics', () {
    test('starts grounded and not sliding', () {
      final physics = RunnerPhysics();
      expect(physics.isGrounded, isTrue);
      expect(physics.isSliding, isFalse);
    });

    test('jump leaves the ground and applies upward velocity', () {
      final physics = RunnerPhysics();
      physics.jump();
      expect(physics.isGrounded, isFalse);
      expect(physics.verticalVelocity, lessThan(0));
    });

    test('jump has no effect while already airborne', () {
      final physics = RunnerPhysics();
      physics.jump();
      final velocityAfterFirstJump = physics.verticalVelocity;
      physics.jump();
      expect(physics.verticalVelocity, velocityAfterFirstJump);
    });

    test('gravity eventually returns the runner to the ground', () {
      final physics = RunnerPhysics();
      physics.jump();
      for (int i = 0; i < 200; i++) {
        physics.update(0.016);
        if (physics.isGrounded) break;
      }
      expect(physics.isGrounded, isTrue);
      expect(physics.verticalPosition, 0);
    });

    test('slide sets isSliding and clears itself after slideDuration', () {
      final physics = RunnerPhysics(baseSpeed: 300);
      physics.slide();
      expect(physics.isSliding, isTrue);
      physics.update(physics.slideDuration + 0.05);
      expect(physics.isSliding, isFalse);
    });

    test('cannot slide while airborne', () {
      final physics = RunnerPhysics();
      physics.jump();
      physics.slide();
      expect(physics.isSliding, isFalse);
    });

    test('lane change moves target lane and clamps at bounds', () {
      final physics = RunnerPhysics(startLane: 1);
      physics.requestLaneChange(-1);
      expect(physics.targetLane, 0);
      physics.requestLaneChange(-1); // already at left, should clamp
      expect(physics.targetLane, 0);
      physics.requestLaneChange(1);
      physics.requestLaneChange(1);
      expect(physics.targetLane, 2);
      physics.requestLaneChange(1); // already at right, should clamp
      expect(physics.targetLane, 2);
    });

    test('forward speed ramps toward maxSpeed via acceleration', () {
      final physics = RunnerPhysics(
        baseSpeed: 100,
        maxSpeedOverride: 200,
        accelerationOverride: 100,
      );
      physics.update(1.0);
      expect(physics.forwardSpeed, closeTo(200, 0.01));
      physics.update(1.0);
      expect(physics.forwardSpeed, lessThanOrEqualTo(200));
    });
  });
}
