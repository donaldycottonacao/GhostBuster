import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../services/api_client.dart';

const _background = Color(0xFF0A0D0C);
const _muted = Color(0xFF9AA1A8);
const _green = Color(0xFF86D78E);

class CallEndedScreen extends StatefulWidget {
  const CallEndedScreen({
    super.key,
    required this.onReturnToSetup,
    this.callerName = 'Riley Morgan',
    this.durationSeconds = 18,
    this.durationText,
    this.apiClient,
  });

  final VoidCallback onReturnToSetup;
  final String callerName;
  final int durationSeconds;
  final String? durationText;
  final GhostBusterApiClient? apiClient;

  @override
  State<CallEndedScreen> createState() => _CallEndedScreenState();
}

class _CallEndedScreenState extends State<CallEndedScreen> {
  @override
  void initState() {
    super.initState();
    (widget.apiClient ?? GhostBusterApiClient()).recordSession(
      EscapeSessionRecordModel(
        callerName: widget.callerName,
        script: 'Simulated escape call completed.',
        delaySeconds: 30,
        durationSeconds: widget.durationSeconds,
        status: 'completed',
        language: 'en',
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

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
              Text(
                '${widget.callerName}  ·  ${widget.durationText ?? _formatDuration(widget.durationSeconds)}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _muted, fontSize: 15),
              ),
              const Spacer(flex: 2),
              Semantics(
                label: 'Return to setup',
                button: true,
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: FilledButton(
                    onPressed: widget.onReturnToSetup,
                    style: FilledButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF24292D),
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
