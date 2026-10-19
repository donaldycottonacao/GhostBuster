import 'dart:async';
import 'package:flutter/material.dart';
import '../models/call_state.dart';
import 'incoming_call_ui.dart';

/// Screen for configuring stealth timer countdown and caller persona triggers.
class StealthTriggerScreen extends StatefulWidget {
  const StealthTriggerScreen({super.key});

  @override
  State<StealthTriggerScreen> createState() => _StealthTriggerScreenState();
}

class _StealthTriggerScreenState extends State<StealthTriggerScreen> {
  CallerPersona _selectedPersona = CallerPersona.defaultPersona;
  int _delaySeconds = 5;
  int _remainingSeconds = 5;
  bool _isCountdownActive = false;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _remainingSeconds = _delaySeconds;
      _isCountdownActive = true;
    });

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _isCountdownActive = false;
        });
        _triggerIncomingCall();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _isCountdownActive = false;
      _remainingSeconds = _delaySeconds;
    });
  }

  void _triggerIncomingCall() {
    final session = CallSession(
      state: CallLifecycleState.ringing,
      persona: _selectedPersona,
      countdownSeconds: _delaySeconds,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => IncomingCallScreen(session: session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark tactical slate
      appBar: AppBar(
        title: const Text(
          'GhostBuster - Stealth Escape',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tactical Header Card
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isCountdownActive ? Icons.timer : Icons.security,
                      color: _isCountdownActive ? Colors.amberAccent : Colors.lightBlueAccent,
                      size: 32,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isCountdownActive ? 'Escape Sequence Armed' : 'Simulated Call Generator',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isCountdownActive
                                ? 'Incoming call triggers in $_remainingSeconds seconds...'
                                : 'Configure trigger delay and select fake caller persona.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Persona Selector Header
              const Text(
                'CALLER PERSONA',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              // Persona list options
              ...CallerPersona.defaultPersonas.map((persona) {
                final isSelected = _selectedPersona.id == persona.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    tileColor: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? Colors.blueAccent : const Color(0xFF334155),
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? Colors.blueAccent : const Color(0xFF334155),
                      child: Text(
                        persona.name[0],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      persona.name,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      persona.number,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.blueAccent)
                        : null,
                    onTap: _isCountdownActive
                        ? null
                        : () {
                            setState(() {
                              _selectedPersona = persona;
                            });
                          },
                  ),
                );
              }),

              const SizedBox(height: 20),

              // Delay Timer Selector Header
              const Text(
                'TRIGGER DELAY',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              // Delay preset chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [5, 15, 30, 60].map((seconds) {
                  final isSelected = _delaySeconds == seconds;
                  return ChoiceChip(
                    label: Text('${seconds}s'),
                    selected: isSelected,
                    selectedColor: Colors.blueAccent,
                    backgroundColor: const Color(0xFF1E293B),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: _isCountdownActive
                        ? null
                        : (selected) {
                            if (selected) {
                              setState(() {
                                _delaySeconds = seconds;
                                _remainingSeconds = seconds;
                              });
                            }
                          },
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Action Trigger Button
              if (_isCountdownActive)
                ElevatedButton.icon(
                  onPressed: _cancelCountdown,
                  icon: const Icon(Icons.close),
                  label: Text('CANCEL COUNTDOWN ($_remainingSeconds s)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _startCountdown,
                  icon: const Icon(Icons.bolt),
                  label: Text('ARM ESCAPE CALL (${_delaySeconds}s DELAY)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Simulation only. No actual phone lines or cellular networks are accessed.',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white38),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
