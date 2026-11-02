import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/voice_scenario.dart';
import '../providers/voice_script_manager_controller.dart';
import '../theme/app_theme.dart';

/// Full-screen Voice Script Manager. Returns the [VoiceScenario] the user chose
/// to use for a call (via "Use for call"), or null if none was selected.
class VoiceScriptManagerScreen extends StatefulWidget {
  const VoiceScriptManagerScreen({
    super.key,
    required this.controller,
    this.selectedScenarioId,
    this.recordingBlocked = false,
  });

  final VoiceScriptManagerController controller;

  /// Currently selected scenario id (highlighted in the list).
  final String? selectedScenarioId;

  /// When true, recording is disabled because a simulated call is active.
  final bool recordingBlocked;

  @override
  State<VoiceScriptManagerScreen> createState() =>
      _VoiceScriptManagerScreenState();
}

class _VoiceScriptManagerScreenState extends State<VoiceScriptManagerScreen> {
  GhostPalette get c => GhostPalette.of(context);

  VoiceScriptManagerController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _c.load();
    });
  }

  @override
  void dispose() {
    _c.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
    _maybeShowError();
  }

  AppLocalizations? get _l10n => AppLocalizations.of(context);

  void _maybeShowError() {
    final error = _c.error;
    if (error == RecordingError.none) return;
    final l10n = _l10n;
    final message = switch (error) {
      RecordingError.permissionDenied =>
        l10n?.voiceMicDenied ?? 'Microphone permission is required to record.',
      RecordingError.permissionPermanentlyDenied =>
        l10n?.voiceMicDeniedForever ??
            'Microphone access is blocked. Enable it in system settings.',
      RecordingError.startFailed =>
        l10n?.voiceRecordFailed ?? 'Recording failed. Please try again.',
      RecordingError.saveFailed =>
        l10n?.voiceSaveFailed ?? 'Could not save the recording.',
      RecordingError.emptyRecording =>
        l10n?.voiceEmptyRecording ?? 'The recording file is missing or empty.',
      RecordingError.none => '',
    };
    _c.clearError();
    if (!mounted || message.isEmpty) return;
    _toast(message);
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: c.textPrimary)),
        backgroundColor: c.surfaceRaised,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Bell MT'),
      ),
      child: Scaffold(
        backgroundColor: c.background,
        appBar: AppBar(
          backgroundColor: c.background,
          foregroundColor: c.textPrimary,
          title: Text(l10n?.voiceManagerTitle ?? 'Voice Script Manager'),
        ),
        body: SafeArea(child: _buildBody()),
        floatingActionButton: _buildFab(),
      ),
    );
  }

  Widget? _buildFab() {
    if (_c.phase != ManagerPhase.list) return null;
    final l10n = _l10n;
    final blocked = widget.recordingBlocked;
    return FloatingActionButton.extended(
      backgroundColor: blocked ? c.surfaceRaised : c.accent,
      foregroundColor: blocked ? c.muted : c.onAccent,
      onPressed: blocked
          ? () => _toast(l10n?.voiceRecordBlocked ??
              'Finish the current call before recording.')
          : _c.startRecording,
      icon: const Icon(Icons.mic_rounded),
      label: Text(l10n?.voiceCreateRecording ?? 'Create Recording'),
    );
  }

  Widget _buildBody() {
    return switch (_c.phase) {
      ManagerPhase.loading =>
        Center(child: CircularProgressIndicator(color: c.accent)),
      ManagerPhase.recording => _RecordingView(controller: _c, l10n: _l10n),
      ManagerPhase.review => _ReviewView(
          controller: _c,
          l10n: _l10n,
          onSave: _promptSave,
        ),
      ManagerPhase.list => _c.isEmpty ? _buildEmpty() : _buildList(),
    };
  }

  Widget _buildEmpty() {
    final l10n = _l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.graphic_eq_rounded, color: c.muted, size: 64),
            const SizedBox(height: 16),
            Text(
              l10n?.voiceEmptyTitle ?? 'No voice scripts yet',
              style: TextStyle(color: c.textPrimary, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.voiceEmptyBody ??
                  'Record your own emergency voice script to play during a simulated call.',
              style: TextStyle(color: c.muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final l10n = _l10n;
    final scenarios = _c.scenarios;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: scenarios.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final scenario = scenarios[index];
        final isSelected = scenario.id == widget.selectedScenarioId;
        final isPreviewing = _c.previewingId == scenario.id;
        return _ScenarioTile(
          scenario: scenario,
          isSelected: isSelected,
          isPreviewing: isPreviewing,
          l10n: l10n,
          onPreviewToggle: () async {
            if (isPreviewing) {
              await _c.stopPreview();
            } else {
              await _c.previewScenario(scenario);
            }
          },
          onUse: () => Navigator.of(context).pop(scenario),
          onRename: () => _promptRename(scenario),
          onDelete: () => _confirmDelete(scenario),
        );
      },
    );
  }

  Future<void> _promptSave() async {
    final l10n = _l10n;
    final result = await _showNameSheet(
      title: l10n?.voiceSaveTitle ?? 'Save recording',
      saveLabel: l10n?.voiceSave ?? 'Save',
    );
    if (result == null) return;
    final saved = await _c.save(name: result.$1, description: result.$2);
    if (saved != null && mounted) {
      _toast(l10n?.voiceSavedSuccess ?? 'Voice script saved.');
    }
  }

  Future<void> _promptRename(VoiceScenario scenario) async {
    final l10n = _l10n;
    final result = await _showNameSheet(
      title: l10n?.voiceRenameTitle ?? 'Rename',
      saveLabel: l10n?.voiceSave ?? 'Save',
      initialName: scenario.name,
      initialDescription: scenario.description,
    );
    if (result == null) return;
    await _c.rename(scenario.id, name: result.$1, description: result.$2);
  }

  Future<void> _confirmDelete(VoiceScenario scenario) async {
    final l10n = _l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: c.surface,
        title: Text(
          l10n?.voiceDeleteTitle ?? 'Delete recording?',
          style: TextStyle(color: c.textPrimary),
        ),
        content: Text(
          l10n?.voiceDeleteBody ??
              'This permanently removes the recording from this device.',
          style: TextStyle(color: c.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n?.voiceCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n?.voiceDelete ?? 'Delete',
              style: TextStyle(color: c.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _c.delete(scenario.id);
      if (mounted) _toast(l10n?.voiceDeletedSuccess ?? 'Recording deleted.');
    }
  }

  /// Returns (name, description) or null if cancelled.
  Future<(String, String)?> _showNameSheet({
    required String title,
    required String saveLabel,
    String initialName = '',
    String initialDescription = '',
  }) {
    final l10n = _l10n;
    final nameController = TextEditingController(text: initialName);
    final descController = TextEditingController(text: initialDescription);
    return showModalBottomSheet<(String, String)>(
      context: context,
      backgroundColor: c.surface,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 4,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
                style: TextStyle(color: c.textPrimary),
                decoration: InputDecoration(
                  labelText: l10n?.voiceNameLabel ?? 'Scenario name',
                  labelStyle: TextStyle(color: c.muted),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: c.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: c.accent),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                style: TextStyle(color: c.textPrimary),
                maxLines: 2,
                decoration: InputDecoration(
                  labelText:
                      l10n?.voiceDescriptionLabel ?? 'Description (optional)',
                  labelStyle: TextStyle(color: c.muted),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: c.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: c.accent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: c.accent,
                  foregroundColor: c.onAccent,
                ),
                onPressed: () => Navigator.of(sheetContext)
                    .pop((nameController.text, descController.text)),
                child: Text(saveLabel),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ScenarioTile extends StatelessWidget {
  const _ScenarioTile({
    required this.scenario,
    required this.isSelected,
    required this.isPreviewing,
    required this.l10n,
    required this.onPreviewToggle,
    required this.onUse,
    required this.onRename,
    required this.onDelete,
  });

  final VoiceScenario scenario;
  final bool isSelected;
  final bool isPreviewing;
  final AppLocalizations? l10n;
  final VoidCallback onPreviewToggle;
  final VoidCallback onUse;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final c = GhostPalette.of(context);
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isSelected ? c.accent : c.border),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Semantics(
                button: true,
                label: isPreviewing
                    ? (l10n?.voiceStopPreview ?? 'Stop preview')
                    : (l10n?.voicePreview ?? 'Preview'),
                child: IconButton(
                  onPressed: onPreviewToggle,
                  icon: Icon(
                    isPreviewing
                        ? Icons.stop_circle_rounded
                        : Icons.play_circle_rounded,
                    color: c.accent,
                    size: 34,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scenario.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      scenario.description.isEmpty
                          ? scenario.formattedDuration
                          : '${scenario.formattedDuration} · ${scenario.description}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: c.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: c.surfaceRaised,
                icon: Icon(Icons.more_vert_rounded, color: c.muted),
                onSelected: (value) {
                  switch (value) {
                    case 'rename':
                      onRename();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Text(l10n?.voiceRename ?? 'Rename'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(l10n?.voiceDelete ?? 'Delete'),
                  ),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onUse,
              icon: Icon(
                isSelected ? Icons.check_rounded : Icons.call_rounded,
                color: c.accent,
                size: 18,
              ),
              label: Text(
                isSelected
                    ? (l10n?.voiceSelectedForCall ?? 'Selected for call')
                    : (l10n?.voiceUseForCall ?? 'Use for call'),
                style: TextStyle(color: c.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingView extends StatelessWidget {
  const _RecordingView({required this.controller, required this.l10n});

  final VoiceScriptManagerController controller;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final c = GhostPalette.of(context);
    final paused = controller.isPaused;
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _MicIndicator(level: paused ? 0 : controller.level),
          const SizedBox(height: 28),
          Text(
            controller.formattedElapsed,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 44,
              fontWeight: FontWeight.w300,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            paused
                ? (l10n?.voicePaused ?? 'Paused')
                : (l10n?.voiceRecordingNow ?? 'Recording...'),
            style: TextStyle(color: c.muted, fontSize: 15),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RoundAction(
                icon: Icons.close_rounded,
                label: l10n?.voiceCancel ?? 'Cancel',
                color: c.muted,
                onTap: controller.cancelRecording,
              ),
              _RoundAction(
                icon: paused ? Icons.mic_rounded : Icons.pause_rounded,
                label: paused
                    ? (l10n?.voiceResume ?? 'Resume')
                    : (l10n?.voicePause ?? 'Pause'),
                color: c.accent,
                onTap: paused
                    ? controller.resumeRecording
                    : controller.pauseRecording,
              ),
              _RoundAction(
                icon: Icons.stop_rounded,
                label: l10n?.voiceStop ?? 'Stop',
                color: c.danger,
                onTap: controller.stopRecording,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MicIndicator extends StatelessWidget {
  const _MicIndicator({required this.level});

  /// Normalized 0..1 microphone level.
  final double level;

  @override
  Widget build(BuildContext context) {
    final c = GhostPalette.of(context);
    final ringSize = 140.0 + (level.clamp(0.0, 1.0) * 60.0);
    return SizedBox(
      width: 220,
      height: 220,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: ringSize,
          height: ringSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.accent.withValues(alpha: 0.12),
            border: Border.all(color: c.accent.withValues(alpha: 0.5)),
          ),
          child: Center(
            child: Icon(Icons.mic_rounded, color: c.accent, size: 56),
          ),
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final c = GhostPalette.of(context);
    return Semantics(
      button: true,
      label: label,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: c.surfaceRaised,
            shape: CircleBorder(side: BorderSide(color: color)),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onTap(),
              child: SizedBox.square(
                dimension: 72,
                child: Icon(icon, color: color, size: 32),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ReviewView extends StatelessWidget {
  const _ReviewView({
    required this.controller,
    required this.l10n,
    required this.onSave,
  });

  final VoiceScriptManagerController controller;
  final AppLocalizations? l10n;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final c = GhostPalette.of(context);
    final isPreviewing = controller.previewingId == '__pending__';
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.graphic_eq_rounded, color: c.accent, size: 64),
          const SizedBox(height: 20),
          Text(
            l10n?.voiceReviewTitle ?? 'Recording captured',
            style: TextStyle(color: c.textPrimary, fontSize: 20),
          ),
          const SizedBox(height: 6),
          Text(
            controller.formattedElapsed,
            style: TextStyle(color: c.muted, fontSize: 15),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _RoundAction(
                icon: isPreviewing
                    ? Icons.stop_rounded
                    : Icons.play_arrow_rounded,
                label: isPreviewing
                    ? (l10n?.voiceStopPreview ?? 'Stop')
                    : (l10n?.voicePreview ?? 'Preview'),
                color: c.accent,
                onTap: () => isPreviewing
                    ? controller.stopPreview()
                    : controller.previewPending(),
              ),
              _RoundAction(
                icon: Icons.refresh_rounded,
                label: l10n?.voiceRetake ?? 'Retake',
                color: c.muted,
                onTap: controller.retake,
              ),
              _RoundAction(
                icon: Icons.close_rounded,
                label: l10n?.voiceCancel ?? 'Cancel',
                color: c.danger,
                onTap: controller.cancelRecording,
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: c.accent,
                foregroundColor: c.onAccent,
              ),
              onPressed: () => onSave(),
              icon: const Icon(Icons.save_rounded),
              label: Text(l10n?.voiceSave ?? 'Save'),
            ),
          ),
        ],
      ),
    );
  }
}
