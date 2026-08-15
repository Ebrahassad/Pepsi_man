import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Draws a 2.5D perspective road: lanes converge toward a vanishing point
/// near the top, and horizontal "rung" lines scroll toward the viewer to
/// sell a sense of forward speed — built entirely with Canvas/Transform,
/// no 3D engine involved.
class TrackPainter extends CustomPainter {
  final double depthScroll; // meters scrolled, drives the rung animation
  final double speedFactor; // 0..1+, scales rung density/animation speed
  final Color roadColor;
  final Color laneLineColor;

  TrackPainter({
    required this.depthScroll,
    this.speedFactor = 1.0,
    this.roadColor = const Color(0xFF2B2B2B),
    this.laneLineColor = Colors.white70,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final vanishingPoint = Offset(size.width / 2, size.height * 0.28);
    final roadBottomLeft = Offset(size.width * 0.02, size.height);
    final roadBottomRight = Offset(size.width * 0.98, size.height);
    final roadTopLeft = Offset(size.width * 0.42, vanishingPoint.dy);
    final roadTopRight = Offset(size.width * 0.58, vanishingPoint.dy);

    // Road surface (trapezoid toward the vanishing point).
    final roadPath = Path()
      ..moveTo(roadBottomLeft.dx, roadBottomLeft.dy)
      ..lineTo(roadTopLeft.dx, roadTopLeft.dy)
      ..lineTo(roadTopRight.dx, roadTopRight.dy)
      ..lineTo(roadBottomRight.dx, roadBottomRight.dy)
      ..close();
    canvas.drawPath(roadPath, Paint()..color = roadColor);

    // Lane divider lines (2 lines splitting 3 lanes), scrolling "rungs".
    _drawLaneDivider(canvas, size, laneT: 1 / 3, vanishingPoint: vanishingPoint);
    _drawLaneDivider(canvas, size, laneT: 2 / 3, vanishingPoint: vanishingPoint);

    // Scrolling road rungs for a sense of forward motion.
    final rungPaint = Paint()
      ..color = laneLineColor.withOpacity(0.5)
      ..strokeWidth = 3;

    const rungCount = 10;
    final scrollOffset = (depthScroll * speedFactor) % (size.height / rungCount);
    for (int i = 0; i < rungCount; i++) {
      final t = (i / rungCount) + (scrollOffset / size.height);
      if (t > 1) continue;
      final y = lerpDouble(vanishingPoint.dy, size.height, t);
      final leftX = lerpDouble(roadTopLeft.dx, roadBottomLeft.dx, t);
      final rightX = lerpDouble(roadTopRight.dx, roadBottomRight.dx, t);
      canvas.drawLine(Offset(leftX, y), Offset(rightX, y), rungPaint);
    }

    // Side "buildings" silhouette strips for extra depth cue.
    final sidePaint = Paint()..color = AppTheme.surface;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.28), sidePaint);
  }

  void _drawLaneDivider(
    Canvas canvas,
    Size size, {
    required double laneT,
    required Offset vanishingPoint,
  }) {
    final bottomX = lerpDouble(size.width * 0.02, size.width * 0.98, laneT);
    final topX = lerpDouble(size.width * 0.42, size.width * 0.58, laneT);

    final paint = Paint()
      ..color = laneLineColor.withOpacity(0.6)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(bottomX, size.height),
      Offset(topX, vanishingPoint.dy),
      paint,
    );
  }

  double lerpDouble(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(covariant TrackPainter oldDelegate) =>
      oldDelegate.depthScroll != depthScroll || oldDelegate.speedFactor != speedFactor;
}
