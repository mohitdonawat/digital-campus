import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Renders a realistic vector barcode with enrollment/roll text
class IdCardBarcodeWidget extends StatelessWidget {
  final String code;
  final double width;
  final double height;
  final Color barColor;

  const IdCardBarcodeWidget({
    super.key,
    required this.code,
    this.width = 130,
    this.height = 36,
    this.barColor = const Color(0xFF0F172A),
  });

  @override
  Widget build(BuildContext context) {
    final displayText = code.isEmpty ? 'IES2024STU01' : code.toUpperCase();
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: width,
            height: height - 12,
            child: CustomPaint(
              painter: _BarcodePainter(seedString: displayText, barColor: barColor),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            displayText,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              letterSpacing: 1.2,
              color: barColor.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarcodePainter extends CustomPainter {
  final String seedString;
  final Color barColor;

  _BarcodePainter({required this.seedString, required this.barColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    // Generate pseudo-deterministic barcode patterns based on hash
    final int hash = seedString.hashCode.abs();
    final math.Random random = math.Random(hash);

    double currentX = 0;
    final double totalWidth = size.width;

    while (currentX < totalWidth) {
      final double barWidth = (random.nextInt(3) + 1).toDouble();
      final double spaceWidth = (random.nextInt(2) + 1).toDouble();

      if (currentX + barWidth <= totalWidth) {
        canvas.drawRect(
          Rect.fromLTWH(currentX, 0, barWidth, size.height),
          paint,
        );
      }
      currentX += barWidth + spaceWidth;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
