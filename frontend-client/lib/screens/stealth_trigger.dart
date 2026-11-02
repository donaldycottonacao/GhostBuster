import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/call_state.dart';
import '../models/voice_scenario.dart';
import '../providers/call_provider.dart';
import '../providers/voice_script_manager_controller.dart';
import '../services/api_client.dart';
import '../services/audio_service.dart';
import '../services/voice_recorder.dart';
import '../services/voice_scenario_store.dart';
import '../theme/app_theme.dart';
import 'voice_script_manager_screen.dart';

class StealthTriggerScreen extends StatefulWidget {
  const StealthTriggerScreen({
    super.key,
    this.onPreviewCountdown,
    this.apiClient,
  });

  final void Function(int delaySeconds, String script)? onPreviewCountdown;
  final GhostBusterApiClient? apiClient;

  @override
  State<StealthTriggerScreen> createState() => _StealthTriggerScreenState();
}

class _StealthTriggerScreenState extends State<StealthTriggerScreen> {
  GhostPalette get c => GhostPalette.of(context);

  late final GhostBusterApiClient _apiClient =
      widget.apiClient ?? GhostBusterApiClient();
  final _situationController = TextEditingController();
  final _scriptController = TextEditingController();

  /// Delay presets offered as quick-pick chips (seconds).
  static const List<int> _delayPresets = [10, 30, 60, 180];

  int _selectedDelay = 10;
  String _selectedLanguage = 'en';
  String _selectedMode = 'own';
  String _selectedRingtone = RingtoneOption.defaultId;
  bool _hasInitializedScript = false;

  /// The provider is optional so the screen still works in preview harnesses.
  CallProvider? _readProvider() {
    try {
      return context.read<CallProvider>();
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Restore the previous setup so a finished call doesn't reset everything.
    final provider = _readProvider();
    if (provider != null) {
      _selectedDelay = provider.validateDelay(provider.delaySeconds)
          ? provider.delaySeconds
          : 10;
      _selectedLanguage = provider.languageCode;
      _selectedRingtone = provider.ringtoneId;
      _situationController.text = provider.situationText;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _readProvider()?.refreshAudioReadiness();
      });
    }
  }

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
    final providerScript = _readProvider()?.voiceScriptText;
    final hasCustomScript = providerScript != null &&
        providerScript != const CallSession().voiceScriptText;
    _scriptController.text = hasCustomScript
        ? providerScript
        : AppLocalizations.of(context)?.setupScriptExample ??
            'Hey, can you call me? I need a reason to step out.';
    _hasInitializedScript = true;
  }

  String _personaRelationship(AppLocalizations? l10n, CallerPersona persona) =>
      switch (persona.id) {
        'landlord' => l10n?.personaRelationshipLandlord ?? 'Property manager',
        'work_boss' => l10n?.personaRelationshipOffice ?? 'Workplace support',
        _ => l10n?.setupEmergencyContact ?? 'Emergency contact',
      };

  String _personaVoiceBadge(AppLocalizations? l10n, CallerPersona persona) {
    if (persona.audioTrackAsset == null || persona.audioTrackAsset!.isEmpty) {
      return l10n?.personaVoiceNone ?? 'SCRIPT ONLY';
    }
    return switch (persona.id) {
      'landlord' => l10n?.personaVoiceUrgent ?? 'VOICE: URGENT',
      _ => l10n?.setupVoicePanicked ?? 'VOICE: PANICKED',
    };
  }

  Future<void> _choosePersona(CallProvider provider) async {
    final l10n = AppLocalizations.of(context);
    final chosen = await showModalBottomSheet<CallerPersona>(
      context: context,
      backgroundColor: c.surface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                l10n?.setupChooseCaller ?? 'Choose caller',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final persona in CallerPersona.defaultPersonas)
              ListTile(
                minTileHeight: 64,
                leading: CircleAvatar(
                  backgroundColor: c.selectedFill,
                  child: Icon(Icons.person_rounded, color: c.accent),
                ),
                title: Text(
                  persona.name,
                  style: TextStyle(color: c.textPrimary),
                ),
                subtitle: Text(
                  '${_personaRelationship(l10n, persona)} · '
                  '${_personaVoiceBadge(l10n, persona)}',
                  style: TextStyle(color: c.muted),
                ),
                trailing: persona.id == provider.persona.id
                    ? Icon(Icons.check_rounded, color: c.accent)
                    : null,
                selected: persona.id == provider.persona.id,
                onTap: () => Navigator.of(sheetContext).pop(persona),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (chosen != null && mounted) provider.setPersona(chosen);
  }

  /// Opens the Voice Script Manager. A returned scenario is selected as the
  /// voice for the next call; recording is blocked while a call is active.
  Future<void> _openVoiceManager(CallProvider? provider) async {
    final controller = VoiceScriptManagerController(
      recorder: VoiceRecorder(),
      store: VoiceScenarioStore(),
      audio: AudioService(),
    );
    final chosen = await Navigator.of(context).push<VoiceScenario>(
      MaterialPageRoute(
        builder: (_) => VoiceScriptManagerScreen(
          controller: controller,
          selectedScenarioId: provider?.selectedVoiceScenarioId,
          recordingBlocked: provider?.isCallAudioActive ?? false,
        ),
      ),
    );
    controller.dispose();
    if (chosen != null && mounted) {
      provider?.selectRecordedVoice(
        scenarioId: chosen.id,
        filePath: chosen.filePath,
      );
    }
  }

  Future<void> _chooseAppLanguage(CallProvider provider) async {
    final l10n = AppLocalizations.of(context);
    final current = provider.localeOverride?.languageCode;
    final options = <(String?, String)>[
      (null, l10n?.languageSystem ?? 'Device language'),
      ('en', l10n?.english ?? 'English'),
      ('tl', l10n?.tagalog ?? 'Tagalog'),
      ('ceb', l10n?.cebuano ?? 'Cebuano / Bisaya'),
    ];
    final picked = await showDialog<(String?,)>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        backgroundColor: c.surface,
        title: Text(
          l10n?.selectLanguage ?? 'Select Language',
          style: TextStyle(color: c.textPrimary),
        ),
        children: [
          for (final (code, label) in options)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop((code,)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(color: c.textPrimary),
                      ),
                    ),
                    if (code == current)
                      Icon(Icons.check_rounded, color: c.accent),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
    if (picked == null || !mounted) return;
    final code = picked.$1;
    if (code == null) {
      provider.useSystemLocale();
    } else {
      provider.setLocale(Locale(code));
    }
  }

  IconData _themeIcon(ThemeMode mode) => switch (mode) {
        ThemeMode.light => Icons.light_mode_rounded,
        ThemeMode.dark => Icons.dark_mode_rounded,
        ThemeMode.system => Icons.brightness_auto_rounded,
      };

  Future<void> _chooseTheme(ThemeController controller) async {
    final l10n = AppLocalizations.of(context);
    final options = <(ThemeMode, String)>[
      (ThemeMode.system, l10n?.themeSystem ?? 'Device setting'),
      (ThemeMode.light, l10n?.themeLight ?? 'Light'),
      (ThemeMode.dark, l10n?.themeDark ?? 'Dark'),
    ];
    final picked = await showDialog<ThemeMode>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        backgroundColor: c.surface,
        title: Text(
          l10n?.theme ?? 'Theme',
          style: TextStyle(color: c.textPrimary),
        ),
        children: [
          for (final (mode, label) in options)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(mode),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(_themeIcon(mode), color: c.muted, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(color: c.textPrimary),
                      ),
                    ),
                    if (mode == controller.mode)
                      Icon(Icons.check_rounded, color: c.accent),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
    if (picked != null && mounted) await controller.setMode(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    CallProvider? callProvider;
    try {
      callProvider = context.watch<CallProvider>();
    } catch (_) {
      callProvider = null;
    }
    ThemeController? themeController;
    try {
      themeController = context.watch<ThemeController>();
    } catch (_) {
      themeController = null;
    }
    final persona = callProvider?.persona ?? CallerPersona.defaultPersona;

    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Bell MT'),
        primaryTextTheme:
            Theme.of(context).primaryTextTheme.apply(fontFamily: 'Bell MT'),
      ),
      child: Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(
          backgroundColor: c.background,
          foregroundColor: c.textPrimary,
          centerTitle: true,
          // Scales the brand title down on very narrow screens with large text
          // instead of cutting it off.
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'PHANTOM '),
                      TextSpan(
                        text: 'EXIT',
                        style: TextStyle(color: c.accent),
                      ),
                    ],
                  ),
                ),
                Text(
                  l10n?.setupTagline ?? 'DISCREET EXITS. BRIGHTER DAYS.',
                  style: TextStyle(
                    color: c.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
          titleTextStyle: TextStyle(
            color: c.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
          actions: [
            if (callProvider != null)
              IconButton(
                tooltip: l10n?.language ?? 'Language',
                icon: Icon(Icons.translate_rounded, color: c.muted),
                onPressed: () => _chooseAppLanguage(callProvider!),
              ),
            if (themeController != null)
              IconButton(
                tooltip: l10n?.theme ?? 'Theme',
                icon: Icon(_themeIcon(themeController.mode), color: c.muted),
                onPressed: () => _chooseTheme(themeController!),
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
                    const SizedBox(height: 8),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'GHOST'),
                            TextSpan(
                              text: 'BUSTER',
                              style: TextStyle(color: c.textPrimary),
                            ),
                          ],
                        ),
                        style: TextStyle(
                          color: c.accent,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                          shadows: [
                            Shadow(color: c.logoGlow, blurRadius: 14),
                            Shadow(color: c.danger, blurRadius: 2),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SectionCard(
                      title: l10n?.setupRingDelay ?? 'RING DELAY',
                      icon: Icons.schedule_rounded,
                      trailing: Text(
                        l10n?.setupRingDelayHelp ??
                            'Set how long until the call comes in.',
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(color: c.muted, fontSize: 11),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              for (var i = 0;
                                  i < _delayPresets.length;
                                  i++) ...[
                                if (i > 0) const SizedBox(width: 7),
                                Expanded(
                                  child: delayOption(
                                    _delayPresets[i],
                                    _presetLabel(l10n, _delayPresets[i]),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 7),
                          customDelayOption(l10n),
                        ],
                      ),
                    ),
                    _SectionCard(
                      title: l10n?.setupIncomingCall ?? 'INCOMING CALL',
                      icon: Icons.call_rounded,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: c.warning, size: 9),
                          const SizedBox(width: 6),
                          Text(
                            l10n?.setupPreview ?? 'PREVIEW',
                            style: TextStyle(
                              color: c.warning,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Semantics(
                            button: callProvider != null,
                            label: l10n?.setupChooseCaller ?? 'Choose caller',
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: callProvider == null
                                    ? null
                                    : () => _choosePersona(callProvider!),
                                child: Ink(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: c.field,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: c.border),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: c.selectedFill,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: c.accent,
                                          size: 34,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              persona.name,
                                              style: TextStyle(
                                                color: c.textPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              _personaRelationship(
                                                  l10n, persona),
                                              style: TextStyle(
                                                color: c.muted,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 7),
                                            DecoratedBox(
                                              decoration: BoxDecoration(
                                                border: Border.fromBorderSide(
                                                  BorderSide(color: c.warning),
                                                ),
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(7),
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                child: Text(
                                                  _personaVoiceBadge(
                                                      l10n, persona),
                                                  style: TextStyle(
                                                    color: c.warning,
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
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: c.muted,
                                        size: 25,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: c.field,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: c.border),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.notifications_none_rounded,
                                  color: c.muted,
                                  size: 21,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    l10n?.setupRingtone ?? 'Ringtone',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: c.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: PopupMenuButton<String>(
                                    initialValue: _selectedRingtone,
                                    onSelected: (value) {
                                      setState(() => _selectedRingtone = value);
                                      callProvider?.setRingtone(value);
                                    },
                                    color: c.surfaceRaised,
                                    itemBuilder: (context) => [
                                      for (final id in RingtoneOption.ids)
                                        PopupMenuItem(
                                          value: id,
                                          child: Text(ringtoneLabel(l10n, id)),
                                        ),
                                    ],
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            ringtoneLabel(
                                                l10n, _selectedRingtone),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                              color: c.muted,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          color: c.muted,
                                          size: 22,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _VoiceScriptEntry(
                      callProvider: callProvider,
                      onOpen: () => _openVoiceManager(callProvider),
                    ),
                    const SizedBox(height: 14),
                    _SectionCard(
                      title: l10n?.setupScriptLanguage ?? 'SCRIPT LANGUAGE',
                      icon: Icons.language_rounded,
                      child: Row(
                        children: [
                          Expanded(
                            child: languageOption(
                              'en',
                              l10n?.english ?? 'English',
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: languageOption(
                              'tl',
                              l10n?.tagalog ?? 'Tagalog',
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: languageOption(
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
                        style: TextStyle(color: c.textPrimary, fontSize: 14),
                        decoration: fieldDecoration(
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
                                child: modeOption(
                                  'ai',
                                  l10n?.setupGenerateWithAI ??
                                      'Generate with AI',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: modeOption(
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
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 14,
                              height: 1.5,
                            ),
                            decoration: fieldDecoration(
                              l10n?.setupScriptHint ?? 'Write your script...',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.edit_outlined,
                                  color: c.accent, size: 16),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  l10n?.setupReviewNote ??
                                      'Review and edit before use.',
                                  style: TextStyle(
                                    color: c.muted,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (callProvider != null &&
                        (callProvider.ringtoneMissing ||
                            callProvider.voiceMissing)) ...[
                      const SizedBox(height: 14),
                      _AudioWarning(
                        messages: [
                          if (callProvider.ringtoneMissing)
                            l10n?.setupAudioMissingRingtone ??
                                "Ringtone audio isn't installed. The call screen will appear, but it won't ring out loud.",
                          if (callProvider.voiceMissing)
                            l10n?.setupAudioMissingVoice ??
                                'No voice recording for this caller. Only the on-screen script will be shown.',
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    Semantics(
                      label: 'Arm Stealth Mode',
                      button: true,
                      child: SizedBox(
                        height: 60,
                        child: FilledButton.icon(
                          onPressed: () {
                            CallProvider? callProvider;
                            try {
                              callProvider = context.read<CallProvider>();
                            } catch (_) {
                              callProvider = null;
                            }

                            if (callProvider != null) {
                              if (!callProvider.validateDelay(_selectedDelay)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n?.errorInvalidDelay ??
                                          'Invalid delay. Delay must be between 10 and 180 seconds.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (!callProvider.canEditConfiguration) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n?.errorSimulationActive ??
                                          'A simulation is already active. Please wait or cancel the current call.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              callProvider.setDelaySeconds(_selectedDelay);
                              callProvider
                                  .setSituationText(_situationController.text);
                              callProvider
                                  .setVoiceScriptText(_scriptController.text);
                              callProvider.startCountdown(
                                delaySeconds: _selectedDelay,
                              );
                            }

                            widget.onPreviewCountdown?.call(
                              _selectedDelay,
                              _scriptController.text,
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: c.accent,
                            foregroundColor: c.onAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(
                            Icons.hearing_rounded,
                          ),
                          label: Text(
                            l10n?.setupArmButton ?? 'ARM STEALTH MODE',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n?.setupDisclaimer ??
                          'Preview only. No call is scheduled from this screen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: c.subtle,
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
      ),
    );
  }

  Widget delayOption(int seconds, String label) {
    final isSelected = _selectedDelay == seconds;
    return _SelectionChip(
      label: label,
      isSelected: isSelected,
      onTap: () => setState(() => _selectedDelay = seconds),
    );
  }

  /// Localized label for a preset delay value.
  String _presetLabel(AppLocalizations? l10n, int seconds) => switch (seconds) {
        10 => l10n?.setupDelay10Seconds ?? '10 sec',
        30 => l10n?.setupDelay30Seconds ?? '30 sec',
        60 => l10n?.setupDelay1Minute ?? '1 min',
        180 => l10n?.setupDelay3Minutes ?? '3 min',
        _ => _formatDelay(seconds),
      };

  /// Human label for any delay, e.g. "45 sec" or "1:30 min".
  String _formatDelay(int seconds) {
    if (seconds < 60) return '$seconds sec';
    final minutes = seconds ~/ 60;
    final rem = seconds % 60;
    return rem == 0
        ? '$minutes min'
        : '$minutes:${rem.toString().padLeft(2, '0')} min';
  }

  /// The "Custom" chip. Selected whenever the current delay isn't a preset;
  /// shows the chosen value so the user can see what's set.
  Widget customDelayOption(AppLocalizations? l10n) {
    final isCustom = !_delayPresets.contains(_selectedDelay);
    final label = isCustom
        ? '${l10n?.setupDelayCustom ?? 'Custom'} · ${_formatDelay(_selectedDelay)}'
        : (l10n?.setupDelayCustom ?? 'Custom');
    return _SelectionChip(
      label: label,
      isSelected: isCustom,
      onTap: () => _pickCustomDelay(l10n),
    );
  }

  /// Opens a dialog to choose any delay within the allowed range.
  Future<void> _pickCustomDelay(AppLocalizations? l10n) async {
    const minDelay = CallProvider.minCountdownDelay; // 10
    const maxDelay = CallProvider.maxCountdownDelay; // 180
    var value = _selectedDelay.clamp(minDelay, maxDelay);

    final chosen = await showDialog<int>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: c.surface,
          title: Text(
            l10n?.setupDelayCustomTitle ?? 'Custom ring delay',
            style: TextStyle(color: c.textPrimary, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatDelay(value),
                style: TextStyle(
                  color: c.accent,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Slider(
                value: value.toDouble(),
                min: minDelay.toDouble(),
                max: maxDelay.toDouble(),
                divisions: maxDelay - minDelay,
                activeColor: c.accent,
                label: _formatDelay(value),
                onChanged: (v) => setDialogState(() => value = v.round()),
              ),
              Text(
                l10n?.setupDelayCustomRange ??
                    'Between 10 seconds and 3 minutes.',
                style: TextStyle(color: c.muted, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n?.countdownCancelButton ?? 'CANCEL'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: c.accent),
              onPressed: () => Navigator.of(dialogContext).pop(value),
              child: Text(
                l10n?.setupDelaySet ?? 'SET',
                style: TextStyle(color: c.onAccent),
              ),
            ),
          ],
        ),
      ),
    );

    if (chosen != null && mounted) {
      setState(() => _selectedDelay = chosen);
    }
  }

  Widget languageOption(String code, String label) {
    final isSelected = _selectedLanguage == code;
    return _SelectionChip(
      label: label,
      isSelected: isSelected,
      onTap: () {
        setState(() => _selectedLanguage = code);
        _readProvider()?.setScriptLanguage(code);
      },
    );
  }

  String ringtoneLabel(AppLocalizations? l10n, String ringtone) =>
      switch (ringtone) {
        'ringing' => l10n?.ringtoneRinging ?? 'Classic Ring',
        'classic' => l10n?.ringtoneClassic ?? 'Classic Phone',
        'modern1' => l10n?.ringtoneModern1 ?? 'Modern 1',
        'modern2' => l10n?.ringtoneModern2 ?? 'Modern 2',
        _ => l10n?.ringtoneTelephone ?? 'Telephone',
      };

  Widget modeOption(String mode, String label) {
    final isSelected = _selectedMode == mode;
    return InkWell(
      onTap: () {
        setState(() => _selectedMode = mode);
        if (mode != 'ai') return;

        final sample = switch (_selectedLanguage) {
          'tl' =>
            'Uy, puwede mo ba akong tawagan? Kailangan ko ng dahilan para makalabas.',
          'ceb' =>
            'Uy, matawagan ko nimo? Kinahanglan kog rason para makagawas.',
          _ => 'Hey, can you call me? I need a reason to step out.',
        };
        _scriptController.text = sample;

        final situation = _situationController.text.trim();
        if (situation.isNotEmpty) {
          _apiClient
              .generateScript(
            situation: situation,
            language: _selectedLanguage,
          )
              .then((aiScript) {
            if (mounted && _selectedMode == 'ai' && aiScript.isNotEmpty) {
              setState(() {
                _scriptController.text = aiScript;
              });
            }
          });
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minHeight: 42),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? c.selectedFill : c.surfaceRaised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? c.accent : c.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (mode == 'ai') ...[
              Icon(
                Icons.auto_awesome_rounded,
                size: 15,
                color: isSelected ? c.accent : c.muted,
              ),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? c.textPrimary : c.muted,
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

  InputDecoration fieldDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.hint, fontSize: 13),
        filled: true,
        fillColor: c.field,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: c.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: c.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: BorderSide(color: c.accent, width: 1.2),
        ),
      );
}

/// Tappable setup row that opens the Voice Script Manager and shows whether a
/// user recording is currently selected for the call.
class _VoiceScriptEntry extends StatelessWidget {
  const _VoiceScriptEntry({
    required this.callProvider,
    required this.onOpen,
  });

  final CallProvider? callProvider;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final c = GhostPalette.of(context);
    final l10n = AppLocalizations.of(context);
    final usesRecorded = callProvider?.usesRecordedVoice ?? false;
    return Semantics(
      button: true,
      label: l10n?.voiceManagerTitle ?? 'Voice Script Manager',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onOpen,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              color: c.field,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: c.border),
            ),
            child: Row(
              children: [
                Icon(Icons.graphic_eq_rounded, color: c.muted, size: 21),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.voiceManagerEntry ?? 'Voice scripts',
                        style: TextStyle(color: c.textPrimary, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        usesRecorded
                            ? (l10n?.voiceSelectedForCall ??
                                'Selected for call')
                            : (l10n?.voiceCreateRecording ??
                                'Create Recording'),
                        style: TextStyle(
                          color: usesRecorded ? c.accent : c.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: c.muted, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
    final c = GhostPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: c.accent, size: 17),
              const SizedBox(width: 8),
              Expanded(
                flex: trailing != null ? 3 : 1,
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  flex: 4,
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

/// Non-blocking notice shown when bundled call audio is missing.
class _AudioWarning extends StatelessWidget {
  const _AudioWarning({required this.messages});

  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    final c = GhostPalette.of(context);
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.warningSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.warning.withValues(alpha: 0.6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.volume_off_rounded, color: c.warning, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final message in messages)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        message,
                        style: TextStyle(
                          color: c.warningText,
                          fontSize: 12.5,
                          height: 1.35,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
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
    final c = GhostPalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minWidth: 0, minHeight: 40),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? c.selectedFill : c.surfaceRaised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? c.accent : c.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? c.textPrimary : c.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
