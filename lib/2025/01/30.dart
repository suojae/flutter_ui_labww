import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

final class AnimatedBlob extends StatefulWidget {
  final Color startColor;
  final Color endColor;
  final Alignment gradientDirection;

  const AnimatedBlob({
    super.key,
    required this.startColor,
    required this.endColor,
    required this.gradientDirection,
  });

  @override
  State<AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<AnimatedBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        painter: BlobPainter(
          value: _controller.value,
          startColor: widget.startColor,
          endColor: widget.endColor,
          gradientDirection: widget.gradientDirection,
        ),
        size: const Size(300, 300),
      ),
    );
  }
}

class BlobPainter extends CustomPainter {
  final double value;
  final Color startColor;
  final Color endColor;
  final Alignment gradientDirection;

  BlobPainter({
    required this.value,
    required this.startColor,
    required this.endColor,
    required this.gradientDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: gradientDirection,
        end: -gradientDirection,
        colors: [
          startColor,
          endColor,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    const int pointCount = 15;
    final center = Offset(size.width / 2, size.height / 2);
    final double amplitude = 8;
    final double baseRadius = size.width * 0.35;
    final double angleStep = (2.0 * pi) / pointCount;

    final List<Offset> points = [];
    final List<double> distortions =
        List.generate(pointCount, (i) => i.toDouble() % 12);

    for (int i = 0; i < pointCount; i++) {
      final angle = angleStep * i;
      final rawOffset = sin(value * 2 * pi + distortions[i]) * amplitude;

      final currentRadius = baseRadius + rawOffset;
      final dx = center.dx + currentRadius * cos(angle);
      final dy = center.dy + currentRadius * sin(angle);

      points.add(Offset(dx, dy));
    }

    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length; i++) {
        final currentPoint = points[i];
        final nextPoint = points[(i + 1) % points.length];

        Offset controlPoint;

        controlPoint = Offset(
          (currentPoint.dx + nextPoint.dx) / 2,
          (currentPoint.dy + nextPoint.dy) / 2,
        );

        path.quadraticBezierTo(
          currentPoint.dx,
          currentPoint.dy,
          controlPoint.dx,
          controlPoint.dy,
        );
      }

      final lastPoint = points[0];
      final firstPoint = points[1];

      Offset lastControlPoint = Offset(
        (lastPoint.dx + firstPoint.dx) / 2,
        (lastPoint.dy + firstPoint.dy) / 2,
      );

      path.quadraticBezierTo(
        lastPoint.dx,
        lastPoint.dy,
        lastControlPoint.dx,
        lastControlPoint.dy,
      );

      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BlobPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.startColor != startColor ||
        oldDelegate.endColor != endColor ||
        oldDelegate.gradientDirection != gradientDirection;
  }
}
