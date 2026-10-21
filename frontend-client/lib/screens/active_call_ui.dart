import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/call_screen_components.dart';
import '../widgets/dial_pad_button.dart';

/// Screen simulating an active ongoing phone call with elapsed time display and keypad controls.
class ActiveCallScreen extends StatefulWidget {
  const ActiveCallScreen({
    super.key,
    required this.script,
    required this.onEndCall,
    this.callerName = 'Riley Morgan',
    this.durationText = '00:18',
    this.isMuted,
    this.isSpeakerOn,
    this.onToggleMute,
    this.onToggleSpeaker,
  });

  final String script;
  final VoidCallback onEndCall;
  final String callerName;
  final String? durationText;
  final bool? isMuted;
  final bool? isSpeakerOn;
  final VoidCallback? onToggleMute;
  final VoidCallback? onToggleSpeaker;

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  bool _localMuted = false;
  bool _keypadVisible = false;
  bool _localSpeakerOn = false;

  /// The Script button shows/hides the script card (e.g. before showing the
  /// screen to someone). Visible by default, as in the original design.
  bool _scriptVisible = true;

  bool get _muted => widget.isMuted ?? _localMuted;
  bool get _speakerOn => widget.isSpeakerOn ?? _localSpeakerOn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                      if (_scriptVisible) ...[
                        EmergencyScriptCard(
                          script: widget.script,
                          title:
                              l10n?.activeCallScriptTitle ?? 'EMERGENCY SCRIPT',
                        ),
                        const SizedBox(height: 34),
                      ],
                      const CallAvatar(diameter: 138),
                      const SizedBox(height: 20),
                      Text(
                        widget.callerName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        l10n?.callConnected ?? 'Connected',
                        style: const TextStyle(
                          color: callScreenGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.durationText ?? '00:18',
                        style: const TextStyle(
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
                            label: _muted
                                ? (l10n?.unmute ?? 'Unmute')
                                : (l10n?.mute ?? 'Mute'),
                            isSelected: _muted,
                            onTap: () {
                              if (widget.onToggleMute != null) {
                                widget.onToggleMute!();
                              } else {
                                setState(() => _localMuted = !_localMuted);
                              }
                            },
                          ),
                          CallControlButton(
                            icon: Icons.dialpad_rounded,
                            label: l10n?.keypad ?? 'Keypad',
                            isSelected: _keypadVisible,
                            onTap: () => setState(
                              () => _keypadVisible = !_keypadVisible,
                            ),
                          ),
                          CallControlButton(
                            icon: _speakerOn
                                ? Icons.volume_up_rounded
                                : Icons.volume_down_rounded,
                            label: l10n?.speaker ?? 'Speaker',
                            isSelected: _speakerOn,
                            onTap: () {
                              if (widget.onToggleSpeaker != null) {
                                widget.onToggleSpeaker!();
                              } else {
                                setState(
                                  () => _localSpeakerOn = !_localSpeakerOn,
                                );
                              }
                            },
                          ),
                          CallControlButton(
                            icon: Icons.notes_rounded,
                            label: l10n?.activeCallScript ?? 'Script',
                            isSelected: _scriptVisible,
                            onTap: () => setState(
                              () => _scriptVisible = !_scriptVisible,
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
            child: Text(
              AppLocalizations.of(context)?.hideKeypad.toUpperCase() ??
                  'HIDE KEYPAD',
            ),
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
    return Semantics(
      label: 'End Call',
      button: true,
      child: Column(
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
          Text(
            AppLocalizations.of(context)?.endCall.toUpperCase() ?? 'END CALL',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
