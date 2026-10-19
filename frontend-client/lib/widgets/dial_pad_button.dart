import 'package:flutter/material.dart';

/// Reusable circular dial pad keypad-button widget scaffold.
class DialPadButton extends StatelessWidget {
  final String digit;
  final String? subtext;
  final VoidCallback? onTap;
  final double size;
  final Color backgroundColor;
  final Color foregroundColor;

  const DialPadButton({
    super.key,
    required this.digit,
    this.subtext,
    this.onTap,
    this.size = 72.0,
    this.backgroundColor = const Color(0x33FFFFFF),
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white24,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                digit,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  height: 1.1,
                ),
              ),
              if (subtext != null && subtext!.isNotEmpty)
                Text(
                  subtext!,
                  style: TextStyle(
                    color: foregroundColor.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
