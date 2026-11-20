import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Light page background with the cosmoguru.net hero motif: soft orange
/// orbit rings slowly turning, a red planet travelling along one of them,
/// and a faint warm glow.
class CosmicBackground extends StatefulWidget {
  /// Draw the orbit rings (home hero) or just the plain page tone.
  final bool orbits;
  const CosmicBackground({super.key, this.orbits = true});

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 48))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFFFF), AppColors.bg, AppColors.bg],
              stops: [0, 0.35, 1],
            ),
          ),
        ),
        if (widget.orbits)
          RepaintBoundary(
            child: CustomPaint(painter: _OrbitPainter(_c), size: Size.infinite),
          ),
      ],
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final Animation<double> t;
  _OrbitPainter(this.t) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * 0.5, size.height * 0.2);
    final rx = size.width * 0.62, ry = size.width * 0.17;

    // Warm glow behind the rings.
    canvas.drawCircle(
      c,
      size.width * 0.55,
      Paint()
        ..shader = RadialGradient(colors: [
          AppColors.orange.withValues(alpha: 0.10),
          AppColors.orange.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: c, radius: size.width * 0.55)),
    );

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final v = t.value * math.pi * 2;
    for (var i = 0; i < 3; i++) {
      final angle = -0.35 + i * 0.35 + math.sin(v + i) * 0.04;
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(angle);
      final rect = Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2);
      ring.shader = SweepGradient(
        colors: [
          AppColors.orange.withValues(alpha: 0.05),
          AppColors.orange.withValues(alpha: 0.32),
          AppColors.orange.withValues(alpha: 0.05),
        ],
        transform: GradientRotation(v + i),
      ).createShader(rect);
      canvas.drawOval(rect, ring);
      if (i == 1) {
        // Planet on this ring.
        final a = v * 1.0;
        final p = Offset(rx * math.cos(a), ry * math.sin(a));
        canvas.drawCircle(
          p,
          7,
          Paint()
            ..shader = const RadialGradient(
              center: Alignment(-0.4, -0.4),
              colors: [Color(0xFFFF6B6B), AppColors.redDeep],
            ).createShader(Rect.fromCircle(center: p, radius: 7)),
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter old) => false;
}
