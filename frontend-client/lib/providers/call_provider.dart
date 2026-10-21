import 'dart:async';
import 'package:flutter/material.dart';
import '../models/call_state.dart';
import '../services/audio_service.dart';

/// Centralized state provider for the GhostBuster simulated call lifecycle.
///
/// Encapsulates timer control, countdown progression, elapsed active duration,
/// audio triggers, in-call audio toggles, and current application locale.
class CallProvider extends ChangeNotifier {
  final AudioServiceBase _audioService;

  CallSession _session = const CallSession();
  Timer? _countdownTimer;
  Timer? _elapsedTimer;
  Locale _currentLocale = const Locale('en');

  /// Tracks active operation generation to invalidate stale asynchronous callbacks.
  int _operationGeneration = 0;
  bool _isDisposed = false;

  /// Delay boundaries according to UX specifications.
  static const int minCountdownDelay = 10;
  static const int maxCountdownDelay = 180;

  CallProvider({AudioServiceBase? audioService})
      : _audioService = audioService ?? AudioService();

  CallSession get session => _session;
  CallLifecycleState get state => _session.state;
  CallerPersona get persona => _session.persona;
  int get delaySeconds => _session.countdownSeconds;
  String get languageCode => _session.languageCode;
  String get situationText => _session.situationText;
  String get voiceScriptText => _session.voiceScriptText;
  int get remainingCountdown => _session.remainingCountdown;
  int get activeDurationSeconds => _session.activeDurationSeconds;
  bool get isMuted => _session.isMuted;
  bool get isSpeakerOn => _session.isSpeakerOn;
  bool get isCountdownActive => _session.state == CallLifecycleState.countdown;
  Locale get currentLocale => _currentLocale;

  /// Formatted call duration string (mm:ss).
  String get formattedElapsedTime {
    final minutes =
        (_session.activeDurationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds =
        (_session.activeDurationSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Change active application locale between English, Tagalog, and Cebuano.
  void setLocale(Locale locale) {
    if (_currentLocale == locale) return;
    _currentLocale = locale;
    notifyListeners();
  }

  /// Select the language used for the simulated voice script.
  void setScriptLanguage(String languageCode) {
    const supportedLanguageCodes = {'en', 'tl', 'ceb'};
    if (!supportedLanguageCodes.contains(languageCode) ||
        _session.languageCode == languageCode) {
      return;
    }

    _session = _session.copyWith(languageCode: languageCode);
    notifyListeners();
  }

  /// Select a caller persona for the simulated call.
  void setPersona(CallerPersona persona) {
    if (_session.state != CallLifecycleState.configuration &&
        _session.state != CallLifecycleState.ended) {
      return;
    }
    _session = _session.copyWith(persona: persona);
    notifyListeners();
  }

  /// Validates whether a delay in seconds falls within the allowed range [10, 180].
  bool validateDelay(int seconds) =>
      seconds >= minCountdownDelay && seconds <= maxCountdownDelay;

  /// Select countdown delay in seconds.
  void setDelaySeconds(int seconds) {
    if (!_canEditConfiguration || seconds <= 0) return;
    _session = _session.copyWith(
      state: CallLifecycleState.configuration,
      countdownSeconds: seconds,
      remainingCountdown: seconds,
    );
    notifyListeners();
  }

  /// Store situation context for the next simulated call.
  void setSituationText(String text) {
    if (!_canEditConfiguration || _session.situationText == text) return;
    _session = _session.copyWith(
      state: CallLifecycleState.configuration,
      situationText: text,
    );
    notifyListeners();
  }

  /// Store the editable voice script for the next simulated call.
  void setVoiceScriptText(String text) {
    if (!_canEditConfiguration || _session.voiceScriptText == text) return;
    _session = _session.copyWith(
      state: CallLifecycleState.configuration,
      voiceScriptText: text,
    );
    notifyListeners();
  }

  bool get _canEditConfiguration =>
      _session.state == CallLifecycleState.configuration ||
      _session.state == CallLifecycleState.ended;

  /// Arm and start the stealth countdown timer.
  ///
  /// Rejects duplicate triggers if countdown or call is already active.
  /// Validates delay against [minCountdownDelay] and [maxCountdownDelay].
  bool startCountdown({
    int? delaySeconds,
    CallerPersona? persona,
    VoidCallback? onTriggered,
  }) {
    if (!_canEditConfiguration) {
      debugPrint(
          '[CallProvider] Duplicate countdown trigger rejected: state is ${_session.state}');
      return false;
    }

    final delay = delaySeconds ?? _session.countdownSeconds;
    if (!validateDelay(delay)) {
      debugPrint(
          '[CallProvider] Rejected invalid countdown delay: $delay (must be $minCountdownDelay-$maxCountdownDelay s)');
      return false;
    }

    final generation = ++_operationGeneration;
    _countdownTimer?.cancel();
    _countdownTimer = null;

    _session = _session.copyWith(
      state: CallLifecycleState.countdown,
      persona: persona ?? _session.persona,
      countdownSeconds: delay,
      remainingCountdown: delay,
    );
    notifyListeners();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (generation != _operationGeneration) {
        timer.cancel();
        return;
      }

      if (_session.remainingCountdown <= 1) {
        timer.cancel();
        _countdownTimer = null;
        if (generation != _operationGeneration) return;

        _session = _session.copyWith(
          state: CallLifecycleState.ringing,
          remainingCountdown: 0,
        );
        _audioService.playRingtone();
        notifyListeners();
        onTriggered?.call();
      } else {
        _session = _session.copyWith(
          remainingCountdown: _session.remainingCountdown - 1,
        );
        notifyListeners();
      }
    });

    return true;
  }

  /// Cancel active countdown and return to configuration state.
  void cancelCountdown() {
    if (_session.state != CallLifecycleState.countdown) return;
    _operationGeneration++;
    _countdownTimer?.cancel();
    _countdownTimer = null;

    _session = _session.copyWith(
      state: CallLifecycleState.configuration,
      remainingCountdown: _session.countdownSeconds,
    );
    notifyListeners();
  }

  /// Answer incoming call, transition to active state, and start elapsed timer.
  ///
  /// Halts ringtone prior to starting peer dialogue playback.
  void answerCall() {
    if (_session.state != CallLifecycleState.ringing) return;
    final generation = ++_operationGeneration;

    // Sequence: Stop ringtone before starting peer dialogue audio
    _audioService.stopAll();
    _session = _session.copyWith(
      state: CallLifecycleState.active,
      activeDurationSeconds: 0,
    );
    notifyListeners();

    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (generation != _operationGeneration) {
        timer.cancel();
        return;
      }
      _session = _session.copyWith(
        activeDurationSeconds: _session.activeDurationSeconds + 1,
      );
      notifyListeners();
    });

    final audioTrack = _session.persona.audioTrackAsset;
    if (audioTrack != null && audioTrack.isNotEmpty) {
      _audioService.playPeerAudio(audioTrack);
    }
  }

  /// Decline incoming call, halt ringtone, and transition to ended state.
  void declineCall() {
    if (_session.state != CallLifecycleState.ringing) return;
    _operationGeneration++;
    _audioService.stopAll();
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _elapsedTimer?.cancel();
    _elapsedTimer = null;

    _session = _session.copyWith(
      state: CallLifecycleState.ended,
    );
    notifyListeners();
  }

  /// Handles incoming ringing timeout.
  void handleRingingTimeout() {
    if (_session.state != CallLifecycleState.ringing) return;
    declineCall();
  }

  /// Terminate active call and reset session back to configuration state.
  void endCall() {
    if (_session.state != CallLifecycleState.active) return;
    _operationGeneration++;
    _audioService.stopAll();
    _elapsedTimer?.cancel();
    _elapsedTimer = null;

    _session = _session.copyWith(
      state: CallLifecycleState.configuration,
      activeDurationSeconds: 0,
      isMuted: false,
      isSpeakerOn: false,
    );
    notifyListeners();
  }

  /// Toggle in-call microphone mute state.
  void toggleMute() {
    if (_session.state != CallLifecycleState.active) return;
    _session = _session.copyWith(isMuted: !_session.isMuted);
    notifyListeners();
  }

  /// Toggle in-call speakerphone state.
  void toggleSpeaker() {
    if (_session.state != CallLifecycleState.active) return;
    _session = _session.copyWith(isSpeakerOn: !_session.isSpeakerOn);
    notifyListeners();
  }

  /// Reset all active timers, stop all audio, and restore initial configuration.
  ///
  /// Safe to invoke repeatedly or during error recovery.
  void reset() {
    _operationGeneration++;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    _audioService.stopAll();

    _session = const CallSession();
    notifyListeners();
  }

  /// Handles foreground/background app lifecycle changes.
  ///
  /// Foreground-first MVP policy:
  /// - Suspended/paused/hidden while in countdown: cancels countdown safely.
  /// - Suspended/paused/hidden while in ringing or active call: stops audio and resets.
  void handleAppLifecycle(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.paused ||
        lifecycle == AppLifecycleState.detached ||
        lifecycle == AppLifecycleState.hidden) {
      if (_session.state == CallLifecycleState.countdown) {
        cancelCountdown();
      } else if (_session.state == CallLifecycleState.ringing ||
          _session.state == CallLifecycleState.active) {
        reset();
      }
    }
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _operationGeneration++;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    _audioService.stopAll();
    super.dispose();
  }
}
