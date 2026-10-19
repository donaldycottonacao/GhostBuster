import 'dart:async';
import 'package:flutter/material.dart';
import '../models/call_state.dart';
import '../services/audio_service.dart';
import '../widgets/dial_pad_button.dart';

/// Screen simulating an active ongoing phone call with elapsed time display and keypad controls.
class ActiveCallScreen extends StatefulWidget {
  final CallSession session;

  const ActiveCallScreen({
    super.key,
    required this.session,
  });

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  final AudioService _audioService = AudioService();
  late CallSession _currentSession;
  Timer? _elapsedTimer;
  int _elapsedSeconds = 0;
  bool _showKeypadModal = false;

  @override
  void initState() {
    super.initState();
    _currentSession = widget.session;
    _startElapsedTimer();
    _playSimulatedPeerAudio();
  }

  void _startElapsedTimer() {
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _playSimulatedPeerAudio() {
    final asset = _currentSession.persona.audioTrackAsset;
    if (asset != null && asset.isNotEmpty) {
      _audioService.playPeerAudio(asset);
    }
  }

  String _formatElapsedTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _toggleMute() {
    setState(() {
      _currentSession = _currentSession.copyWith(isMuted: !_currentSession.isMuted);
    });
  }

  void _toggleSpeaker() {
    setState(() {
      _currentSession = _currentSession.copyWith(isSpeakerOn: !_currentSession.isSpeakerOn);
    });
  }

  void _endCall() {
    _audioService.stopAll();
    _elapsedTimer?.cancel();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _audioService.stopAll();
    super.dispose();
  }

  Widget _buildControlCircle({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Material(
            color: isActive ? Colors.white : const Color(0x2AFFFFFF),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Icon(
                icon,
                color: isActive ? Colors.black : Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final persona = _currentSession.persona;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Caller Metadata & Elapsed Timer
              Column(
                children: [
                  const SizedBox(height: 36),
                  Text(
                    persona.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatElapsedTime(_elapsedSeconds),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),

              // Middle Keypad Display (Toggled) or Action Grid
              if (_showKeypadModal)
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              DialPadButton(digit: '1', subtext: ''),
                              DialPadButton(digit: '2', subtext: 'A B C'),
                              DialPadButton(digit: '3', subtext: 'D E F'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              DialPadButton(digit: '4', subtext: 'G H I'),
                              DialPadButton(digit: '5', subtext: 'J K L'),
                              DialPadButton(digit: '6', subtext: 'M N O'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              DialPadButton(digit: '7', subtext: 'P Q R S'),
                              DialPadButton(digit: '8', subtext: 'T U V'),
                              DialPadButton(digit: '9', subtext: 'W X Y Z'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showKeypadModal = false;
                              });
                            },
                            child: const Text('Hide Keypad', style: TextStyle(color: Colors.white70)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlCircle(
                          icon: _currentSession.isMuted ? Icons.mic_off : Icons.mic,
                          label: _currentSession.isMuted ? 'unmute' : 'mute',
                          isActive: _currentSession.isMuted,
                          onTap: _toggleMute,
                        ),
                        _buildControlCircle(
                          icon: Icons.dialpad,
                          label: 'keypad',
                          isActive: false,
                          onTap: () {
                            setState(() {
                              _showKeypadModal = true;
                            });
                          },
                        ),
                        _buildControlCircle(
                          icon: _currentSession.isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                          label: 'speaker',
                          isActive: _currentSession.isSpeakerOn,
                          onTap: _toggleSpeaker,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlCircle(
                          icon: Icons.add_call,
                          label: 'add call',
                          isActive: false,
                          onTap: () {},
                        ),
                        _buildControlCircle(
                          icon: Icons.videocam,
                          label: 'FaceTime',
                          isActive: false,
                          onTap: () {},
                        ),
                        _buildControlCircle(
                          icon: Icons.contacts,
                          label: 'contacts',
                          isActive: false,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),

              // Bottom End Call Button
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Material(
                    color: const Color(0xFFEF4444),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _endCall,
                      customBorder: const CircleBorder(),
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
