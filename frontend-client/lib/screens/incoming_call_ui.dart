import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/call_screen_components.dart';
import '../widgets/slide_button.dart';

/// Screen simulating a hyper-realistic incoming phone call.
class IncomingCallScreen extends StatelessWidget {
  const IncomingCallScreen({
    super.key,
    required this.onAnswer,
    required this.onDecline,
    this.callerName = 'Riley Morgan',
  });

  final VoidCallback onAnswer;
  final VoidCallback onDecline;
  final String callerName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: callScreenBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sliderWidth =
                (constraints.maxWidth - 40).clamp(260.0, 440.0).toDouble();
            final avatarDiameter =
                (constraints.maxWidth * 0.42).clamp(150.0, 250.0).toDouble();

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 58,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        CallAvatar(diameter: avatarDiameter),
                        const SizedBox(height: 34),
                        Text(
                          callerName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 96),
                        Text(
                          l10n?.incomingCallTitle ?? 'Incoming call...',
                          style: const TextStyle(
                            color: callScreenMuted,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Column(
                      children: [
                        SlideButton(
                          label: l10n?.slideToAnswer.toUpperCase() ??
                              'SLIDE TO ANSWER',
                          onSlideComplete: onAnswer,
                          width: sliderWidth,
                          height: 76,
                          backgroundColor: callScreenSurface,
                          sliderColor: callScreenGreen,
                        ),
                        const SizedBox(height: 8),
                        Semantics(
                          label: 'Tap to answer call',
                          button: true,
                          child: TextButton.icon(
                            onPressed: onAnswer,
                            icon: const Icon(
                              Icons.call_rounded,
                              color: callScreenGreen,
                              size: 20,
                            ),
                            label: Text(
                              l10n?.tapToAnswer ?? 'TAP TO ANSWER',
                              style: const TextStyle(
                                color: callScreenGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Semantics(
                      label: 'Decline call',
                      button: true,
                      child: Column(
                        children: [
                          SizedBox.square(
                            dimension: 84,
                            child: Material(
                              color: callScreenRed,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: onDecline,
                                child: const Icon(
                                  Icons.call_end_rounded,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n?.decline.toUpperCase() ?? 'DECLINE',
                            style: const TextStyle(
                              color: callScreenMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
