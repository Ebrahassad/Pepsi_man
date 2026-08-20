import 'package:flutter/material.dart';

import '../data/obstacle_data.dart';
import '../models/obstacle_model.dart';

/// Renders one obstacle using its native configured dimensions.
///
/// Perspective scaling is applied exactly once here.
///
/// The caller is responsible for determining:
///   - lane X
///   - ground Y
///   - perspective scale
class ObstacleWidget extends StatelessWidget {
  final ObstacleInstance instance;
  final double scale;

  const ObstacleWidget({
    super.key,
    required this.instance,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final config =
        ObstacleData.all[instance.type];

    final width =
        (config?.width ?? 80.0) *
            scale;

    final height =
        (config?.height ?? 80.0) *
            scale;

    return Opacity(
      opacity:
          instance.isHit
              ? 0.4
              : 1.0,

      child: SizedBox(
        width: width,
        height: height,

        child: Image.asset(
          config?.assetPath ?? '',
          width: width,
          height: height,
          fit: BoxFit.contain,

          errorBuilder:
              (context, error, stackTrace) {
            return CustomPaint(
              size: Size(
                width,
                height,
              ),
              painter:
                  _ObstacleFallbackPainter(
                type: instance.type,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// FALLBACK
// ============================================================================

class _ObstacleFallbackPainter
    extends CustomPainter {
  final ObstacleType type;

  _ObstacleFallbackPainter({
    required this.type,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint =
        Paint()
          ..color =
              _colorFor(type);

    final rect =
        Rect.fromLTWH(
      0,
      size.height * 0.1,
      size.width,
      size.height * 0.9,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(8),
      ),
      paint,
    );

    final outline =
        Paint()
          ..color =
              Colors.black.withOpacity(
            0.35,
          )
          ..style =
              PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(8),
      ),
      outline,
    );
  }

  Color _colorFor(
    ObstacleType type,
  ) {
    switch (type) {
      case ObstacleType.car:
      case ObstacleType.movingVehicle:
        return const Color(
          0xFFE53935,
        );

      case ObstacleType.truck:
        return const Color(
          0xFF6D4C41,
        );

      case ObstacleType.bus:
        return const Color(
          0xFFFB8C00,
        );

      case ObstacleType.cone:
        return const Color(
          0xFFFF7043,
        );

      case ObstacleType.barrier:
      case ObstacleType.lowBarrier:
      case ObstacleType.constructionBarrier:
      case ObstacleType.roadBlock:
        return const Color(
          0xFFFFC107,
        );

      case ObstacleType.gate:
      case ObstacleType.highBarrier:
        return const Color(
          0xFF546E7A,
        );

      case ObstacleType.container:
        return const Color(
          0xFF37474F,
        );

      case ObstacleType.trashBin:
        return const Color(
          0xFF616161,
        );
    }
  }

  @override
  bool shouldRepaint(
    covariant _ObstacleFallbackPainter oldDelegate,
  ) {
    return oldDelegate.type != type;
  }
}