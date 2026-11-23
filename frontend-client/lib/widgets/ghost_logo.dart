import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Decorative ghost mark drawn with a [CustomPainter] (Material has no ghost
/// icon). Static on purpose: no animation, so it never blocks pumpAndSettle.
///
/// Colors follow the current [GhostPalette] (light or dark theme) unless
/// overridden.
class GhostLogo extends StatelessWidget {
  const GhostLogo({
    super.key,
    this.width = 72,
    this.color,
    this.eyeColor,
    this.glowColor,
  });

  final double width;

  /// Body color. Defaults to the palette accent.
  final Color? color;

  /// Eyes and mouth. Defaults to a color that contrasts with the body.
  final Color? eyeColor;

  /// Soft glow behind the body. Defaults to the palette logo glow.
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final palette = GhostPalette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ExcludeSemantics(
      child: SizedBox(
        width: width,
        height: width * 1.15,
        child: CustomPaint(
          painter: _GhostPainter(
            color: color ?? palette.accent,
            eyeColor: eyeColor ?? (isDark ? palette.background : Colors.white),
            glowColor: glowColor ?? palette.logoGlow,
          ),
        ),
      ),
    );
  }
}

class _GhostPainter extends CustomPainter {
  _GhostPainter({
    required this.color,
    required this.eyeColor,
    required this.glowColor,
  });

  final Color color;
  final Color eyeColor;
  final Color glowColor;

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
        ..color = glowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Body fill: a lighter tint of the body color at the top fading into it.
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(color, Colors.white, 0.55)!, color],
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
      old.color != color ||
      old.eyeColor != eyeColor ||
      old.glowColor != glowColor;
}
