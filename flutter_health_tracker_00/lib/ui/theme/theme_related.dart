// Description: Theme Related Variable and Classes
// Code
// Text Style, Colors,...

import 'dart:ui';

import 'package:flutter/material.dart';

// Gradient Coloring in the Background
class GradientBackground extends CustomPainter {
  final BuildContext context;

  GradientBackground(this.context);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white,
        Colors.white,
        Theme.of(context).colorScheme.primary.withValues(
          alpha: 0.1,
        ), // Replace with your theme color
      ],
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Logo Blurred in the Background
class LogoBackground extends StatelessWidget {
  final double sigma;
  final double opaq;
  final double size;
  const LogoBackground({super.key, this.sigma = 10, this.opaq = 0.2, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Opacity(
          opacity: opaq,
          child: SizedBox(
            height: size,
            width: size,
            child: Image.asset(
              'asset/icon/app_icon_universal.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
