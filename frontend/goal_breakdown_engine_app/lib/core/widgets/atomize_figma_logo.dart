import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:goal_breakdown_engine_app/core/theme/app_colors.dart';

/// Hexagon + trailing “pixel” particles (Figma-style), drawn with [CustomPaint].
class AtomizeLogoPainter extends CustomPainter {
  AtomizeLogoPainter({
    this.hexBlue = AppColors.figmaHeadingBlue,
    this.particleGreen = AppColors.figmaParticleGreen,
  });

  final Color hexBlue;
  final Color particleGreen;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.34;
    final cy = size.height * 0.5;
    final radius = math.min(size.width, size.height) * 0.26;

    final hexPath = _hexagonPath(Offset(cx, cy), radius);
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = hexBlue;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, radius * 0.06)
      ..color = hexBlue.withValues(alpha: 0.95);
    canvas.drawPath(hexPath, fill);
    canvas.drawPath(hexPath, stroke);

    const particleCount = 10;
    for (var i = 0; i < particleCount; i++) {
      final t = i / (particleCount - 1);
      final px = cx + radius * 1.15 + t * size.width * 0.42;
      final py = cy + math.sin(i * 1.7) * radius * 0.22;
      final s = 3.0 + (i % 4) * 2.2;
      final o = 0.95 - t * 0.45;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(px, py), width: s, height: s),
        const Radius.circular(1.5),
      );
      canvas.drawRRect(
        rrect,
        Paint()..color = particleGreen.withValues(alpha: o),
      );
    }
  }

  static Path _hexagonPath(Offset c, double r) {
    final path = Path();
    for (var i = 0; i < 6; i++) {
      final a = (i * 60 - 90) * math.pi / 180;
      final x = c.dx + r * math.cos(a);
      final y = c.dy + r * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant AtomizeLogoPainter oldDelegate) =>
      oldDelegate.hexBlue != hexBlue ||
      oldDelegate.particleGreen != particleGreen;
}

class AtomizeFigmaLogoMark extends StatelessWidget {
  const AtomizeFigmaLogoMark({
    super.key,
    required this.size,
    this.hexBlue,
    this.particleGreen,
  });

  final double size;
  final Color? hexBlue;
  final Color? particleGreen;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: AtomizeLogoPainter(
            hexBlue: hexBlue ?? AppColors.figmaHeadingBlue,
            particleGreen: particleGreen ?? AppColors.figmaParticleGreen,
          ),
        ),
      ),
    );
  }
}

/// Centered splash block: mark, wordmark, tagline.
class AtomizeFigmaSplashBlock extends StatelessWidget {
  const AtomizeFigmaSplashBlock({
    super.key,
    required this.markSize,
    required this.titleColor,
    required this.taglineColor,
    this.tagline = 'BIG GOALS, BROKEN DOWN.',
    this.hexBlue,
    this.particleGreen,
  });

  final double markSize;
  final Color titleColor;
  final Color taglineColor;
  final String tagline;
  final Color? hexBlue;
  final Color? particleGreen;

  static const String wordmark = 'ATOMIZE';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AtomizeFigmaLogoMark(
          size: markSize,
          hexBlue: hexBlue,
          particleGreen: particleGreen,
        ),
        const SizedBox(height: 28),
        Text(
          wordmark,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: titleColor,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: 3.2,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          tagline,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: taglineColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

/// Top-left onboarding header: compact mark + wordmark.
class AtomizeFigmaHeaderRow extends StatelessWidget {
  const AtomizeFigmaHeaderRow({
    super.key,
    this.markSize = 40,
    this.titleColor,
    this.logoHexBlue,
    this.logoParticleGreen,
  });

  final double markSize;
  final Color? titleColor;
  final Color? logoHexBlue;
  final Color? logoParticleGreen;

  @override
  Widget build(BuildContext context) {
    final c = titleColor ?? AppColors.figmaHeadingBlue;
    return Row(
      children: [
        AtomizeFigmaLogoMark(
          size: markSize,
          hexBlue: logoHexBlue,
          particleGreen: logoParticleGreen,
        ),
        const SizedBox(width: 12),
        Text(
          AtomizeFigmaSplashBlock.wordmark,
          style: TextStyle(
            color: c,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.4,
          ),
        ),
      ],
    );
  }
}
