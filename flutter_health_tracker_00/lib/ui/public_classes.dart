// Description: Public Classes
// Code
// Put public class that are used a lot, in this file for easier access

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
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), // Replace with your theme color
      ],
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ?
