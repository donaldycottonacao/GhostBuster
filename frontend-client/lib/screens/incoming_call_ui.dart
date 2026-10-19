import 'package:flutter/material.dart';
import '../models/call_state.dart';
import '../services/audio_service.dart';
import '../widgets/slide_button.dart';
import 'active_call_ui.dart';

/// Screen simulating a hyper-realistic incoming phone call.
class IncomingCallScreen extends StatefulWidget {
  final CallSession session;

  const IncomingCallScreen({
    super.key,
    required this.session,
  });

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _startSimulatedRingtone();
  }

  void _startSimulatedRingtone() {
    _audioService.playRingtone(assetPath: 'assets/audio/ringtone_ios.mp3');
  }

  void _answerCall() {
    _audioService.stopAll();
    final updatedSession = widget.session.copyWith(
      state: CallLifecycleState.active,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ActiveCallScreen(session: updatedSession),
      ),
    );
  }

  void _declineCall() {
    _audioService.stopAll();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _audioService.stopAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final persona = widget.session.persona;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Caller Metadata
              Column(
                children: [
                  const SizedBox(height: 48),
                  Text(
                    persona.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    persona.number,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'mobile',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              // Bottom Action Controls
              Column(
                children: [
                  // Remind Me & Message Action Scaffolds
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.alarm, color: Colors.white70, size: 28),
                          SizedBox(height: 6),
                          Text('Remind Me', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.message, color: Colors.white70, size: 28),
                          SizedBox(height: 6),
                          Text('Message', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Slide To Answer gesture slider
                  SlideButton(
                    label: 'slide to answer',
                    onSlideComplete: _answerCall,
                    width: 290,
                    height: 68,
                  ),

                  const SizedBox(height: 24),

                  // Quick Decline Button
                  IconButton(
                    onPressed: _declineCall,
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    tooltip: 'Decline Call',
                  ),
                  const Text(
                    'Decline',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
