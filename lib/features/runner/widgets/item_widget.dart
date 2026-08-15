import 'package:flutter/material.dart';

import '../models/item_model.dart';
import '../data/item_data.dart';

/// Renders a single collectible/power-up on the track.
class ItemWidget extends StatelessWidget {
  final ItemInstance instance;
  final double scale;

  const ItemWidget({super.key, required this.instance, this.scale = 1.0});

  @override
  Widget build(BuildContext context) {
    final config = ItemData.collectibles[instance.type];
    final size = 44.0 * scale;

    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        config?.assetPath ?? '',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => CustomPaint(
          size: Size(size, size),
          painter: _ItemFallbackPainter(type: instance.type),
        ),
      ),
    );
  }
}

class _ItemFallbackPainter extends CustomPainter {
  final ItemType type;

  _ItemFallbackPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _colorFor(type);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    if (type == ItemType.coin) {
      canvas.drawCircle(center, radius, paint);
      final ring = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, radius, ring);
    } else if (type == ItemType.energyCan || type == ItemType.bonusCan) {
      final rect = Rect.fromCenter(
        center: center,
        width: size.width * 0.5,
        height: size.height * 0.85,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6)), paint);
    } else {
      // Power-ups: diamond shape
      final path = Path()
        ..moveTo(center.dx, center.dy - radius)
        ..lineTo(center.dx + radius, center.dy)
        ..lineTo(center.dx, center.dy + radius)
        ..lineTo(center.dx - radius, center.dy)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  Color _colorFor(ItemType type) {
    switch (type) {
      case ItemType.coin:
        return const Color(0xFFFFC107);
      case ItemType.energyCan:
        return const Color(0xFF43A047);
      case ItemType.bonusCan:
        return const Color(0xFF1E88E5);
      case ItemType.magnet:
        return const Color(0xFFE91E63);
      case ItemType.shield:
        return const Color(0xFF00BCD4);
      case ItemType.speedBoost:
        return const Color(0xFFFF6D00);
      case ItemType.invincibility:
        return const Color(0xFFFFD700);
    }
  }

  @override
  bool shouldRepaint(covariant _ItemFallbackPainter oldDelegate) => oldDelegate.type != type;
}
