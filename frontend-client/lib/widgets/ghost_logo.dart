import 'package:flutter/material.dart';

/// Decorative ghost mark drawn with a [CustomPainter] (Material has no ghost
/// icon). Static on purpose: no animation, so it never blocks pumpAndSettle.
class GhostLogo extends StatelessWidget {
  const GhostLogo({
    super.key,
    this.width = 72,
    this.color = const Color(0xFF8BC49A),
    this.eyeColor = const Color(0xFF080B09),
  });

  final double width;
  final Color color;
  final Color eyeColor;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: width * 1.15,
        child: CustomPaint(
          painter: _GhostPainter(color: color, eyeColor: eyeColor),
        ),
      ),
    );
  }
}

class _GhostPainter extends CustomPainter {
  _GhostPainter({required this.color, required this.eyeColor});

  final Color color;
  final Color eyeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = w / 2;
    final baseY = h * 0.84;
    final bump = w / 3;

    // Body: rounded head, straight sides, three scalloped hem bumps.
    final body = Path()
      ..moveTo(0, r)
      ..arcTo(Rect.fromLTWH(0, 0, w, w), 3.141592653589793, 3.141592653589793,
          false)
      ..lineTo(w, baseY);
    for (var i = 0; i < 3; i++) {
      final startX = w - i * bump;
      body.quadraticBezierTo(startX - bump / 2, h * 1.12, startX - bump, baseY);
    }
    body.close();

    // Soft glow behind the body.
    canvas.drawPath(
      body,
      Paint()
        ..color = color.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Body fill: light top fading into the accent color.
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.95), color],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Eyes and mouth.
    final face = Paint()..color = eyeColor;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.34, w * 0.46),
          width: w * 0.13,
          height: w * 0.19),
      face,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.66, w * 0.46),
          width: w * 0.13,
          height: w * 0.19),
      face,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.5, w * 0.68), width: w * 0.11, height: w * 0.15),
      face,
    );
  }

  @override
  bool shouldRepaint(_GhostPainter old) =>
      old.color != color || old.eyeColor != eyeColor;
}
