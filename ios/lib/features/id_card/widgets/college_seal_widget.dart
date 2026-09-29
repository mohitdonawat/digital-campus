import 'package:flutter/material.dart';

/// Authentic Circular College Seal & Registrar Signature for Official College Documents
class CollegeSealWidget extends StatelessWidget {
  final double size;
  final Color sealColor;

  const CollegeSealWidget({
    super.key,
    this.size = 75,
    this.sealColor = const Color(0xFF991B1B), // Deep maroon red official stamp ink
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CollegeSealPainter(color: sealColor),
      ),
    );
  }
}

class _CollegeSealPainter extends CustomPainter {
  final Color color;

  _CollegeSealPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final outerPaint = Paint()
      ..color = color.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final innerPaint = Paint()
      ..color = color.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Outer double circles
    canvas.drawCircle(center, radius - 2, outerPaint);
    canvas.drawCircle(center, radius - 5.5, innerPaint);
    canvas.drawCircle(center, radius - 15, innerPaint);

    // Center star / emblem
    final centerFill = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 15, centerFill);

    // Draw circular text approximation / stamp details
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Top text: IES COLLEGE
    textPainter.text = TextSpan(
      text: '★ IES UNIVERSITY ★',
      style: TextStyle(
        color: color.withOpacity(0.9),
        fontSize: size.width * 0.085,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.5,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - radius + 7),
    );

    // Center emblem: VERIFIED
    textPainter.text = TextSpan(
      text: 'OFFICIAL\nSEAL',
      style: TextStyle(
        color: color.withOpacity(0.9),
        fontSize: size.width * 0.11,
        fontWeight: FontWeight.w900,
        height: 1.1,
        letterSpacing: 0.8,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );

    // Bottom text: BHOPAL
    textPainter.text = TextSpan(
      text: '• BHOPAL (M.P.) •',
      style: TextStyle(
        color: color.withOpacity(0.9),
        fontSize: size.width * 0.075,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy + radius - 16),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Official Registrar / Principal Signature with Stamp Line
class RegistrarSignatureWidget extends StatelessWidget {
  final double width;
  final String title;

  const RegistrarSignatureWidget({
    super.key,
    this.width = 95,
    this.title = 'Registrar / Director',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Cursive signature stroke representation
          CustomPaint(
            size: Size(width, 24),
            painter: _SignaturePainter(),
          ),
          const SizedBox(height: 2),
          Container(
            height: 1.2,
            width: width,
            color: const Color(0xFF1E3A8A),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E3A8A),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E3A8A).withOpacity(0.85)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.1, size.width * 0.4, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.9, size.width * 0.65, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.1, size.width * 0.85, size.height * 0.7);
    path.lineTo(size.width * 0.95, size.height * 0.6);

    // Loop
    path.moveTo(size.width * 0.35, size.height * 0.4);
    path.cubicTo(
      size.width * 0.45, size.height * 0.1,
      size.width * 0.55, size.height * 0.1,
      size.width * 0.6, size.height * 0.5,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
