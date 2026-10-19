import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/call_state.dart';
import '../providers/call_provider.dart';
import '../widgets/slide_button.dart';
import 'active_call_ui.dart';

/// Screen simulating a hyper-realistic incoming phone call.
class IncomingCallScreen extends StatelessWidget {
  const IncomingCallScreen({super.key});

  void _answerCall(BuildContext context, CallProvider provider) {
    provider.answerCall();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const ActiveCallScreen(),
      ),
    );
  }

  void _declineCall(BuildContext context, CallProvider provider) {
    provider.declineCall();
    Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CallProvider>();
    final l10n = AppLocalizations.of(context)!;
    final persona = provider.persona;

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
                    _getPersonaLocalizedName(persona, l10n),
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
                  Text(
                    l10n.mobile,
                    style: const TextStyle(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.alarm, color: Colors.white70, size: 28),
                          const SizedBox(height: 6),
                          Text(l10n.remindMe, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      Column(
                        children: [
                          const Icon(Icons.message, color: Colors.white70, size: 28),
                          const SizedBox(height: 6),
                          Text(l10n.message, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Slide To Answer gesture slider
                  SlideButton(
                    label: l10n.slideToAnswer,
                    onSlideComplete: () => _answerCall(context, provider),
                    width: 290,
                    height: 68,
                  ),

                  const SizedBox(height: 24),

                  // Quick Decline Button
                  IconButton(
                    onPressed: () => _declineCall(context, provider),
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
                    tooltip: l10n.decline,
                  ),
                  Text(
                    l10n.decline,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
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
