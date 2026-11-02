import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Glossy highlight on icons. Only drawn in the dark theme; on a light
/// background the white highlight reads as a smudge.
List<Shadow>? _glossyIconShadows(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const [
            Shadow(color: Color(0xAAFFFFFF), blurRadius: 2),
            Shadow(
                color: Color(0xCC07100B), offset: Offset(0, 2), blurRadius: 3),
          ]
        : null;

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
    final c = GhostPalette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveRemaining = remainingSeconds ?? delaySeconds;
    final minutes = (effectiveRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (effectiveRemaining % 60).toString().padLeft(2, '0');
    final formattedTime = '$minutes:$seconds';
    final progress = delaySeconds > 0
        ? (effectiveRemaining / delaySeconds).clamp(0.0, 1.0)
        : 0.5;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: c.background,
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
                      style: TextStyle(
                        color: c.textPrimary,
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
                                backgroundColor: c.border,
                                color: c.accent,
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    color: c.textPrimary,
                                    fontSize: 58,
                                    fontWeight: FontWeight.w300,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n?.countdownSilent ?? 'SILENT COUNTDOWN',
                                  style: TextStyle(
                                    color: c.textPrimary,
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
                      style: TextStyle(color: c.muted, fontSize: 15),
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
                          foregroundColor: c.textPrimary,
                          minimumSize: const Size.fromHeight(58),
                          side: BorderSide(color: c.muted),
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
                          style: TextStyle(color: c.muted),
                        ),
                      ),
                    ),
                  ],
                ),
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
    final c = GhostPalette.of(context);
    final shadows = _glossyIconShadows(context);
    return Row(
      children: [
        Icon(
          Icons.menu_rounded,
          color: c.muted,
          size: 25,
          shadows: shadows,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'PHANTOM EXIT  ·  '),
                TextSpan(
                  text: 'STEALTH ACTIVE',
                  style: TextStyle(color: c.accent),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c.muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Icon(
          Icons.more_horiz_rounded,
          color: c.muted,
          size: 25,
          shadows: shadows,
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
    final c = GhostPalette.of(context);
    final shadows = _glossyIconShadows(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 31,
            backgroundColor: c.avatarFill,
            child: Icon(
              Icons.person_rounded,
              color: c.avatarIcon,
              size: 38,
              shadows: shadows,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  callerName,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)?.setupEmergencyContact ??
                      'Emergency contact',
                  style: TextStyle(color: c.muted, fontSize: 14),
                ),
              ],
            ),
          ),
          Icon(
            Icons.equalizer_rounded,
            color: c.amber,
            size: 24,
            shadows: shadows,
          ),
        ],
      ),
    );
  }
}
