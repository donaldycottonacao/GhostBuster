import 'package:flutter/material.dart';

const callScreenBackground = Color(0xFF0A0D0C);
const callScreenSurface = Color(0xFF191D20);
const callScreenBorder = Color(0xFF353B40);
const callScreenMuted = Color(0xFFA7AFB7);
const callScreenGreen = Color(0xFF36CF5A);
const callScreenRed = Color(0xFFE8393B);

class CallAvatar extends StatelessWidget {
  const CallAvatar({
    super.key,
    this.diameter = 180,
  });

  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: const Color(0xFF30353B),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Icon(
        Icons.person_rounded,
        size: diameter * 0.56,
        color: const Color(0xFFE2E4E6),
      ),
    );
  }
}

class CallControlButton extends StatelessWidget {
  const CallControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 76,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFFE8EAEC) : callScreenSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: callScreenBorder),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.black : Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmergencyScriptCard extends StatelessWidget {
  const EmergencyScriptCard({
    super.key,
    required this.script,
  });

  final String script;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 16),
      decoration: BoxDecoration(
        color: callScreenSurface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: callScreenBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EMERGENCY SCRIPT',
            style: TextStyle(
              color: callScreenMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.mode_comment_rounded,
                color: Colors.white70,
                size: 28,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  '“$script”',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
