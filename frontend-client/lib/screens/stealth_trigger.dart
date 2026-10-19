import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/call_provider.dart';
import 'incoming_call_ui.dart';

const _background = Color(0xFF171A18);
const _surface = Color(0xFF222724);
const _surfaceRaised = Color(0xFF2B312D);
const _border = Color(0xFF39423C);
const _accent = Color(0xFF8BC49A);
const _muted = Color(0xFFABB4AD);
const _orange = Color(0xFFFFA33B);

class StealthTriggerScreen extends StatefulWidget {
  const StealthTriggerScreen({super.key});

  @override
  State<StealthTriggerScreen> createState() => _StealthTriggerScreenState();
}

class _StealthTriggerScreenState extends State<StealthTriggerScreen> {
  final _situationController = TextEditingController();
  final _scriptController = TextEditingController();

  String _selectedMode = 'own';
  String _selectedRingtone = 'containment';
  bool _hasInitializedScript = false;

  @override
  void dispose() {
    _situationController.dispose();
    _scriptController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasInitializedScript) return;
    final provider = context.read<CallProvider>();
    _situationController.text = provider.situationText;
    _scriptController.text = provider.voiceScriptText;
    _hasInitializedScript = true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<CallProvider>();

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'PHANTOM '),
                  TextSpan(
                    text: 'EXIT',
                    style: TextStyle(color: _accent),
                  ),
                ],
              ),
            ),
            Text(
              l10n?.setupTagline ?? 'DISCREET EXITS. BRIGHTER DAYS.',
              style: const TextStyle(
                color: _muted,
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _accent.withValues(alpha: 0.7)),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle, color: _accent, size: 8),
                const SizedBox(width: 7),
                Text(
                  l10n?.setupFieldMode ?? 'FIELD MODE',
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.settings_rounded, color: _muted),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n?.setupTitle ?? 'Set your exit',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n?.setupSubtitle ?? 'A convincing call, right on cue.',
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionCard(
                    title: l10n?.setupRingDelay ?? 'RING DELAY',
                    icon: Icons.schedule_rounded,
                    trailing: Text(
                      l10n?.setupRingDelayHelp ??
                          'Set how long until the call comes in.',
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _delayOption(
                            10,
                            l10n?.setupDelay10Seconds ?? '10 sec',
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: _delayOption(
                            30,
                            l10n?.setupDelay30Seconds ?? '30 sec',
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: _delayOption(
                            60,
                            l10n?.setupDelay1Minute ?? '1 min',
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: _delayOption(
                            180,
                            l10n?.setupDelay3Minutes ?? '3 min',
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SectionCard(
                    title: l10n?.setupIncomingCall ?? 'INCOMING CALL',
                    icon: Icons.call_rounded,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, color: _orange, size: 9),
                        const SizedBox(width: 6),
                        Text(
                          l10n?.setupPreview ?? 'PREVIEW',
                          style: const TextStyle(
                            color: _orange,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B211D),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF33483A),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: _accent,
                                  size: 34,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Riley Morgan',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      l10n?.setupEmergencyContact ??
                                          'Emergency contact',
                                      style: const TextStyle(
                                        color: _muted,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    DecoratedBox(
                                      decoration: const BoxDecoration(
                                        border: Border.fromBorderSide(
                                          BorderSide(color: _orange),
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(7),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          l10n?.setupVoicePanicked ??
                                              'VOICE: PANICKED',
                                          style: const TextStyle(
                                            color: _orange,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: _muted,
                                size: 25,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B211D),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _border),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.notifications_none_rounded,
                                color: _muted,
                                size: 21,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n?.setupRingtone ?? 'Ringtone',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                initialValue: _selectedRingtone,
                                onSelected: (value) =>
                                    setState(() => _selectedRingtone = value),
                                color: _surfaceRaised,
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'containment',
                                    child: Text(
                                      l10n?.setupRingtoneContainment ??
                                          'Containment Alarm',
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'soft',
                                    child: Text(
                                      l10n?.setupRingtoneSoft ?? 'Soft Chime',
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'classic',
                                    child: Text(
                                      l10n?.setupRingtoneClassic ??
                                          'Classic Ringtone',
                                    ),
                                  ),
                                ],
                                child: Row(
                                  children: [
                                    Text(
                                      _ringtoneLabel(l10n, _selectedRingtone),
                                      style: const TextStyle(
                                        color: _muted,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: _muted,
                                      size: 22,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: l10n?.setupScriptLanguage ?? 'SCRIPT LANGUAGE',
                    icon: Icons.language_rounded,
                    child: Row(
                      children: [
                        Expanded(
                          child: _languageOption(
                            'en',
                            l10n?.english ?? 'English',
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: _languageOption(
                            'tl',
                            l10n?.tagalog ?? 'Tagalog',
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: _languageOption(
                            'ceb',
                            l10n?.cebuano ?? 'Bisaya',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: l10n?.setupSituationEvent ?? 'SITUATION / EVENT',
                    icon: Icons.edit_note_rounded,
                    child: TextField(
                      controller: _situationController,
                      minLines: 3,
                      maxLines: 5,
                      onChanged: context.read<CallProvider>().setSituationText,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: _fieldDecoration(
                        l10n?.setupSituationHint ??
                            'e.g., At a party and ready to head home',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SectionCard(
                    title: l10n?.setupVoiceScript ?? 'VOICE SCRIPT',
                    icon: Icons.notes_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _modeOption(
                                'ai',
                                l10n?.setupGenerateWithAI ?? 'Generate with AI',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _modeOption(
                                'own',
                                l10n?.setupWriteMyOwn ?? 'Write my own',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _scriptController,
                          minLines: 2,
                          maxLines: 5,
                          onChanged:
                              context.read<CallProvider>().setVoiceScriptText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.5,
                          ),
                          decoration: _fieldDecoration(
                            l10n?.setupScriptHint ?? 'Write your script...',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.edit_outlined,
                                color: _accent, size: 16),
                            const SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                l10n?.setupReviewNote ??
                                    'Review and edit before use.',
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 60,
                    child: FilledButton.icon(
                      onPressed: () {
                        if (provider.isCountdownActive) {
                          provider.cancelCountdown();
                          return;
                        }
                        provider.startCountdown(
                          onTriggered: () {
                            if (!context.mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const IncomingCallScreen(),
                              ),
                            );
                          },
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: provider.isCountdownActive
                            ? _surfaceRaised
                            : _accent,
                        foregroundColor: provider.isCountdownActive
                            ? Colors.white
                            : const Color(0xFF152019),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: Icon(
                        provider.isCountdownActive
                            ? Icons.close_rounded
                            : Icons.hearing_rounded,
                      ),
                      label: Text(
                        provider.isCountdownActive
                            ? l10n?.cancelCountdown(
                                  provider.remainingCountdown,
                                ) ??
                                'CANCEL COUNTDOWN (${provider.remainingCountdown}s)'
                            : l10n?.setupArmButton ?? 'ARM STEALTH MODE',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n?.setupDisclaimer ??
                        'Preview only. No call is scheduled from this screen.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF7E8981),
                      fontSize: 11,
                      height: 1.4,
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

  Widget _delayOption(int seconds, String label) {
    final provider = context.watch<CallProvider>();
    final isSelected = provider.delaySeconds == seconds;
    return _SelectionChip(
      label: label,
      isSelected: isSelected,
      onTap: () => context.read<CallProvider>().setDelaySeconds(seconds),
    );
  }

  Widget _languageOption(String code, String label) {
    final provider = context.watch<CallProvider>();
    final isSelected = provider.languageCode == code;
    return _SelectionChip(
      label: label,
      isSelected: isSelected,
      onTap: () => context.read<CallProvider>().setLocale(Locale(code)),
    );
  }

  String _ringtoneLabel(AppLocalizations? l10n, String ringtone) =>
      switch (ringtone) {
        'soft' => l10n?.setupRingtoneSoft ?? 'Soft Chime',
        'classic' => l10n?.setupRingtoneClassic ?? 'Classic Ringtone',
        _ => l10n?.setupRingtoneContainment ?? 'Containment Alarm',
      };

  Widget _modeOption(String mode, String label) {
    final isSelected = _selectedMode == mode;
    return InkWell(
      onTap: () => setState(() => _selectedMode = mode),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minHeight: 42),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF33483A) : _surfaceRaised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? _accent : _border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (mode == 'ai') ...[
              Icon(
                Icons.auto_awesome_rounded,
                size: 15,
                color: isSelected ? _accent : _muted,
              ),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF778179), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFF1B211D),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: _accent, width: 1.2),
        ),
      );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: _accent, size: 17),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: trailing!,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SelectionChip extends StatelessWidget {
  const _SelectionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minWidth: 0, minHeight: 40),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF33483A) : _surfaceRaised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? _accent : _border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : _muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
