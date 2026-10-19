import 'package:flutter/material.dart';

const _background = Color(0xFF101214);
const _muted = Color(0xFF9AA1A8);
const _green = Color(0xFF86D78E);

class CallEndedScreen extends StatelessWidget {
  const CallEndedScreen({
    super.key,
    required this.onReturnToSetup,
  });

  final VoidCallback onReturnToSetup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
          child: Column(
            children: [
              const Spacer(),
              const Icon(
                Icons.check_circle_outline_rounded,
                color: _green,
                size: 52,
              ),
              const SizedBox(height: 18),
              const Text(
                'Call ended',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your call has ended.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 17),
              ),
              const SizedBox(height: 24),
              const Text(
                'Riley Morgan  ·  00:18',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 15),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: FilledButton(
                  onPressed: onReturnToSetup,
                  style: FilledButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF2B3035),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'RETURN TO SETUP',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ready for another call.',
                style: TextStyle(color: _muted, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
