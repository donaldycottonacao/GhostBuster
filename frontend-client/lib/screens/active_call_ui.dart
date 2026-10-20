import 'package:flutter/material.dart';

import '../widgets/call_screen_components.dart';
import '../widgets/dial_pad_button.dart';

/// Screen simulating an active ongoing phone call with elapsed time display and keypad controls.
class ActiveCallScreen extends StatefulWidget {
  const ActiveCallScreen({
    super.key,
    required this.script,
    required this.onEndCall,
  });

  final String script;
  final VoidCallback onEndCall;

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  bool _muted = false;
  bool _keypadVisible = false;
  bool _speakerOn = false;
  bool _scriptSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: callScreenBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: [
                      EmergencyScriptCard(script: widget.script),
                      const SizedBox(height: 34),
                      const CallAvatar(diameter: 138),
                      const SizedBox(height: 20),
                      const Text(
                        'Riley Morgan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Connected',
                        style: TextStyle(
                          color: callScreenGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '00:18',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.w300,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 38),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: constraints.maxWidth < 370 ? 8 : 12,
                        runSpacing: 16,
                        children: [
                          CallControlButton(
                            icon: _muted
                                ? Icons.mic_off_rounded
                                : Icons.mic_none_rounded,
                            label: _muted ? 'Unmute' : 'Mute',
                            isSelected: _muted,
                            onTap: () => setState(() => _muted = !_muted),
                          ),
                          CallControlButton(
                            icon: Icons.dialpad_rounded,
                            label: 'Keypad',
                            isSelected: _keypadVisible,
                            onTap: () => setState(
                              () => _keypadVisible = !_keypadVisible,
                            ),
                          ),
                          CallControlButton(
                            icon: _speakerOn
                                ? Icons.volume_up_rounded
                                : Icons.volume_down_rounded,
                            label: 'Speaker',
                            isSelected: _speakerOn,
                            onTap: () =>
                                setState(() => _speakerOn = !_speakerOn),
                          ),
                          CallControlButton(
                            icon: Icons.notes_rounded,
                            label: 'Script',
                            isSelected: _scriptSelected,
                            onTap: () => setState(
                              () => _scriptSelected = !_scriptSelected,
                            ),
                          ),
                        ],
                      ),
                      if (_keypadVisible) ...[
                        const SizedBox(height: 22),
                        _PreviewKeypad(onClose: () {
                          setState(() => _keypadVisible = false);
                        }),
                      ],
                      const SizedBox(height: 30),
                      _EndCallButton(onPressed: widget.onEndCall),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PreviewKeypad extends StatelessWidget {
  const _PreviewKeypad({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    const digits = [
      ('1', ''),
      ('2', 'ABC'),
      ('3', 'DEF'),
      ('4', 'GHI'),
      ('5', 'JKL'),
      ('6', 'MNO'),
      ('7', 'PQRS'),
      ('8', 'TUV'),
      ('9', 'WXYZ'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: callScreenSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: callScreenBorder),
      ),
      child: Column(
        children: [
          for (var row = 0; row < 3; row++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var column = 0; column < 3; column++)
                  DialPadButton(
                    digit: digits[row * 3 + column].$1,
                    subtext: digits[row * 3 + column].$2,
                    size: 64,
                  ),
              ],
            ),
            if (row < 2) const SizedBox(height: 10),
          ],
          TextButton(
            onPressed: onClose,
            child: const Text('HIDE KEYPAD'),
          ),
        ],
      ),
    );
  }
}

class _EndCallButton extends StatelessWidget {
  const _EndCallButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox.square(
          dimension: 86,
          child: Material(
            color: callScreenRed,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: const Icon(
                Icons.call_end_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'END CALL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
