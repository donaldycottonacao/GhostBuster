import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/call_state.dart';
import '../providers/call_provider.dart';
import '../widgets/dial_pad_button.dart';

/// Screen simulating an active ongoing phone call with elapsed time display and keypad controls.
class ActiveCallScreen extends StatefulWidget {
  const ActiveCallScreen({super.key});

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  bool _showKeypadModal = false;

  void _endCall(BuildContext context, CallProvider provider) {
    provider.endCall();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  String _getPersonaLocalizedName(CallerPersona persona, AppLocalizations l10n) {
    switch (persona.id) {
      case 'mom':
        return l10n.personaMom;
      case 'landlord':
        return l10n.personaLandlord;
      case 'work_boss':
        return l10n.personaOffice;
      default:
        return persona.name;
    }
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
    final provider = context.watch<CallProvider>();
    final l10n = AppLocalizations.of(context)!;
    final persona = provider.persona;

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
                    _getPersonaLocalizedName(persona, l10n),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.formattedElapsedTime,
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
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              DialPadButton(digit: '1', subtext: ''),
                              DialPadButton(digit: '2', subtext: 'A B C'),
                              DialPadButton(digit: '3', subtext: 'D E F'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              DialPadButton(digit: '4', subtext: 'G H I'),
                              DialPadButton(digit: '5', subtext: 'J K L'),
                              DialPadButton(digit: '6', subtext: 'M N O'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
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
                            child: Text(
                              l10n.hideKeypad,
                              style: const TextStyle(color: Colors.white70),
                            ),
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
                          icon: provider.isMuted ? Icons.mic_off : Icons.mic,
                          label: provider.isMuted ? l10n.unmute : l10n.mute,
                          isActive: provider.isMuted,
                          onTap: () => provider.toggleMute(),
                        ),
                        _buildControlCircle(
                          icon: Icons.dialpad,
                          label: l10n.keypad,
                          isActive: false,
                          onTap: () {
                            setState(() {
                              _showKeypadModal = true;
                            });
                          },
                        ),
                        _buildControlCircle(
                          icon: provider.isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                          label: l10n.speaker,
                          isActive: provider.isSpeakerOn,
                          onTap: () => provider.toggleSpeaker(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlCircle(
                          icon: Icons.add_call,
                          label: l10n.addCall,
                          isActive: false,
                          onTap: () {},
                        ),
                        _buildControlCircle(
                          icon: Icons.videocam,
                          label: l10n.facetime,
                          isActive: false,
                          onTap: () {},
                        ),
                        _buildControlCircle(
                          icon: Icons.contacts,
                          label: l10n.contacts,
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
                      onTap: () => _endCall(context, provider),
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
