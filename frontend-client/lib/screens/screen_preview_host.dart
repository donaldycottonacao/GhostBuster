import 'package:flutter/material.dart';

import 'active_call_ui.dart';
import 'call_ended_screen.dart';
import 'countdown_screen.dart';
import 'incoming_call_ui.dart';
import 'stealth_trigger.dart';

enum _PreviewPage { setup, countdown, incoming, active, ended }

class ScreenPreviewHost extends StatefulWidget {
  const ScreenPreviewHost({super.key});

  @override
  State<ScreenPreviewHost> createState() => _ScreenPreviewHostState();
}

class _ScreenPreviewHostState extends State<ScreenPreviewHost> {
  _PreviewPage _page = _PreviewPage.setup;
  int _selectedDelay = 30;
  String _script = 'Hey, can you call me? I need a reason to step out.';

  @override
  Widget build(BuildContext context) {
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
