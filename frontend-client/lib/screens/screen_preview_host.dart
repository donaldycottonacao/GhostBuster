import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/call_state.dart';
import '../providers/call_provider.dart';
import 'active_call_ui.dart';
import 'call_ended_screen.dart';
import 'countdown_screen.dart';
import 'incoming_call_ui.dart';
import 'stealth_trigger.dart';

enum _PreviewPage { setup, countdown, incoming, active, ended }

/// Host widget that binds screen transitions to the centralized [CallProvider] state machine,
/// while maintaining backward-compatible manual preview callbacks for test harnesses.
class ScreenPreviewHost extends StatefulWidget {
  const ScreenPreviewHost({super.key});

  @override
  State<ScreenPreviewHost> createState() => _ScreenPreviewHostState();
}

class _ScreenPreviewHostState extends State<ScreenPreviewHost>
    with WidgetsBindingObserver {
  _PreviewPage _page = _PreviewPage.setup;
  int _selectedDelay = 30;
  String _script = 'Hey, can you call me? I need a reason to step out.';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    try {
      context.read<CallProvider>().handleAppLifecycle(state);
    } catch (_) {
      // Safe fallback if CallProvider is not available in test scope
    }
  }

  @override
  Widget build(BuildContext context) {
    CallProvider? callProvider;
    try {
      callProvider = context.watch<CallProvider>();
    } catch (_) {
      callProvider = null;
    }

    // If CallProvider is available, state-machine lifecycle is the single source of truth
    if (callProvider != null) {
      return switch (callProvider.state) {
        CallLifecycleState.configuration => StealthTriggerScreen(
            onPreviewCountdown: (delaySeconds, script) {
              _selectedDelay = delaySeconds;
              _script = script;
              callProvider?.setVoiceScriptText(script);
              callProvider?.startCountdown(delaySeconds: delaySeconds);
            },
          ),
        CallLifecycleState.countdown => CountdownScreen(
            delaySeconds: callProvider.delaySeconds,
            remainingSeconds: callProvider.remainingCountdown,
            callerName: callProvider.persona.name,
            onCancel: () => callProvider?.cancelCountdown(),
            onPreviewIncoming: () => callProvider?.triggerRinging(),
          ),
        CallLifecycleState.ringing => IncomingCallScreen(
            callerName: callProvider.persona.name,
            onAnswer: () => callProvider?.answerCall(),
            onDecline: () => callProvider?.declineCall(),
          ),
        CallLifecycleState.active => ActiveCallScreen(
            script: callProvider.voiceScriptText,
            callerName: callProvider.persona.name,
            durationText: callProvider.activeDurationSeconds > 0
                ? callProvider.formattedElapsedTime
                : '00:18',
            isMuted: callProvider.isMuted,
            isSpeakerOn: callProvider.isSpeakerOn,
            onToggleMute: () => callProvider?.toggleMute(),
            onToggleSpeaker: () => callProvider?.toggleSpeaker(),
            onEndCall: () => callProvider?.endCall(),
          ),
        CallLifecycleState.ended => CallEndedScreen(
            callerName: callProvider.persona.name,
            durationSeconds: callProvider.activeDurationSeconds > 0
                ? callProvider.activeDurationSeconds
                : 18,
            durationText: callProvider.activeDurationSeconds > 0
                ? callProvider.formattedElapsedTime
                : '00:18',
            onReturnToSetup: () => callProvider?.reset(),
          ),
      };
    }

    // Fallback for standalone/mock harness when provider is absent
    return switch (_page) {
      _PreviewPage.setup => StealthTriggerScreen(
          onPreviewCountdown: (delaySeconds, script) {
            setState(() {
              _selectedDelay = delaySeconds;
              _script = script;
              _page = _PreviewPage.countdown;
            });
          },
        ),
      _PreviewPage.countdown => CountdownScreen(
          delaySeconds: _selectedDelay,
          onCancel: () => _showPage(_PreviewPage.setup),
          onPreviewIncoming: () => _showPage(_PreviewPage.incoming),
        ),
      _PreviewPage.incoming => IncomingCallScreen(
          onAnswer: () => _showPage(_PreviewPage.active),
          onDecline: () => _showPage(_PreviewPage.setup),
        ),
      _PreviewPage.active => ActiveCallScreen(
          script: _script,
          onEndCall: () => _showPage(_PreviewPage.ended),
        ),
      _PreviewPage.ended => CallEndedScreen(
          onReturnToSetup: () => _showPage(_PreviewPage.setup),
        ),
    };
  }

  void _showPage(_PreviewPage page) => setState(() => _page = page);
}
