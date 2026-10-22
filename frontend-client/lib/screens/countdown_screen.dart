import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

const _background = Color(0xFF080B09);
const _surface = Color(0xFF151D18);
const _border = Color(0xFF344138);
const _accent = Color(0xFF8BD49A);
const _muted = Color(0xFFA9B4AB);

const _glossyIconShadows = [
  Shadow(color: Color(0xAAFFFFFF), blurRadius: 2),
  Shadow(color: Color(0xCC07100B), offset: Offset(0, 2), blurRadius: 3),
];

class CountdownScreen extends StatelessWidget {
  const CountdownScreen({
    super.key,
    required this.delaySeconds,
    required this.onCancel,
    required this.onPreviewIncoming,
    this.remainingSeconds,
    this.callerName = 'Riley Morgan',
  });

  final int delaySeconds;
  final VoidCallback onCancel;
  final VoidCallback onPreviewIncoming;
  final int? remainingSeconds;
  final String callerName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final effectiveRemaining = remainingSeconds ?? delaySeconds;
    final minutes = (effectiveRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (effectiveRemaining % 60).toString().padLeft(2, '0');
    final formattedTime = '$minutes:$seconds';
    final progress = delaySeconds > 0
        ? (effectiveRemaining / delaySeconds).clamp(0.0, 1.0)
        : 0.5;
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _CountdownHeader(),
                  const SizedBox(height: 42),
                  Text(
                    l10n?.countdownStandingBy ?? 'Standing by...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Center(
                    child: SizedBox.square(
                      dimension: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 4,
                              backgroundColor: _border,
                              color: _accent,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                formattedTime,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 58,
                                  fontWeight: FontWeight.w300,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n?.countdownSilent ?? 'SILENT COUNTDOWN',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    l10n?.countdownKeepOpen ??
                        'Keep GhostBuster open. Leaving the app cancels the call.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _muted, fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  _CallerPreviewCard(callerName: callerName),
                  const SizedBox(height: 20),
                  Semantics(
                    label: 'Cancel countdown',
                    button: true,
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(58),
                        side: const BorderSide(color: _muted),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        l10n?.countdownCancelButton ?? 'CANCEL',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    label: 'Preview incoming call screen',
                    button: true,
                    child: TextButton(
                      onPressed: onPreviewIncoming,
                      child: Text(
                        l10n?.countdownRingNow ??
                            'Preview incoming call screen',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: _muted),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountdownHeader extends StatelessWidget {
  const _CountdownHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(
          Icons.menu_rounded,
          color: _muted,
          size: 25,
          shadows: _glossyIconShadows,
        ),
        SizedBox(width: 14),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'PHANTOM EXIT  ·  '),
                TextSpan(
                  text: 'STEALTH ACTIVE',
                  style: TextStyle(color: _accent),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(width: 14),
        Icon(
          Icons.more_horiz_rounded,
          color: _muted,
          size: 25,
          shadows: _glossyIconShadows,
        ),
      ],
    );
  }
}

class _CallerPreviewCard extends StatelessWidget {
  const _CallerPreviewCard({this.callerName = 'Riley Morgan'});

  final String callerName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 31,
            backgroundColor: Color(0xFF385442),
            child: Icon(
              Icons.person_rounded,
              color: Color(0xFFD8F1DC),
              size: 38,
              shadows: _glossyIconShadows,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  callerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)?.setupEmergencyContact ??
                      'Emergency contact',
                  style: const TextStyle(color: _muted, fontSize: 14),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.equalizer_rounded,
            color: Color(0xFFFFC247),
            size: 24,
            shadows: _glossyIconShadows,
          ),
        ],
      ),
    );
  }
}
