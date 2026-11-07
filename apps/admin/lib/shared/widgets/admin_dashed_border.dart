import 'package:flutter/material.dart';

class AdminDashedBorder extends CustomPainter {
  const AdminDashedBorder({this.radius = 8});
  final double radius;
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 2 || size.height <= 2) return;
    final paint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
          Radius.circular(radius),
        ),
      );
    for (final metric in path.computeMetrics()) {
      for (double distance = 0; distance < metric.length; distance += 10) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant AdminDashedBorder oldDelegate) =>
      oldDelegate.radius != radius;
}
