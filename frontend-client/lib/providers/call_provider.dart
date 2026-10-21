import 'dart:async';
import 'package:flutter/material.dart';
import '../models/call_state.dart';
import '../services/audio_service.dart';
import '../services/device_services.dart';

/// Centralized state provider for the GhostBuster simulated call lifecycle.
///
/// Encapsulates timer control, countdown progression, elapsed active duration,
/// audio triggers, in-call audio toggles, and current application locale.
class CallProvider extends ChangeNotifier {
  final AudioServiceBase _audioService;
  final ScreenWakeController _screenWake;
  final AssetProbe _assetProbe;

  CallSession _session = const CallSession();
  Timer? _countdownTimer;
  Timer? _elapsedTimer;

  /// In-app language choice; `null` follows the device language.
  Locale? _localeOverride;

  bool _screenKeptOn = false;
  bool? _ringtoneAvailable;
  bool? _voiceAvailable;
  int _readinessCheck = 0;

  /// Tracks active operation generation to invalidate stale asynchronous callbacks.
  int _operationGeneration = 0;
  bool _isDisposed = false;

  /// Delay boundaries according to UX specifications.
  static const int minCountdownDelay = 10;
  static const int maxCountdownDelay = 180;

  CallProvider({
    AudioServiceBase? audioService,
    ScreenWakeController? screenWake,
    AssetProbe? assetProbe,
  })  : _audioService = audioService ?? AudioService(),
        _screenWake = screenWake ?? const PlatformScreenWakeController(),
        _assetProbe = assetProbe ?? bundleAssetExists;

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
  String get ringtoneId => _session.ringtoneId;
  String get ringtoneAsset => RingtoneOption.assetFor(_session.ringtoneId);

  /// Selected in-app language, or English when following the device.
  Locale get currentLocale => _localeOverride ?? const Locale('en');

  /// Locale passed to MaterialApp; `null` means "use the device language".
  Locale? get localeOverride => _localeOverride;

  /// True once a readiness check found the selected ringtone file missing.
  bool get ringtoneMissing => _ringtoneAvailable == false;

  /// True once a readiness check found no playable voice for the persona.
  bool get voiceMissing => _voiceAvailable == false;

  /// Whether the screen is currently being held awake.
  bool get isScreenKeptOn => _screenKeptOn;

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
    const supported = {'en', 'tl', 'ceb'};
    final effectiveLocale =
        supported.contains(locale.languageCode) ? locale : const Locale('en');
    if (_localeOverride == effectiveLocale) return;
    _localeOverride = effectiveLocale;
    notifyListeners();
  }

  /// Follow the device language again (resolved by MaterialApp).
  void useSystemLocale() {
    if (_localeOverride == null) return;
    _localeOverride = null;
    notifyListeners();
  }

  /// Select one of [RingtoneOption.assetPaths] for the next call.
  void setRingtone(String ringtoneId) {
    if (!_canEditConfiguration ||
        !RingtoneOption.assetPaths.containsKey(ringtoneId) ||
        _session.ringtoneId == ringtoneId) {
      return;
    }
    _session = _session.copyWith(ringtoneId: ringtoneId);
    _ringtoneAvailable = null;
    notifyListeners();
    unawaited(refreshAudioReadiness());
  }

  /// Checks whether the selected ringtone and persona voice are bundled.
  ///
  /// Missing audio never blocks a call; the setup screen warns instead.
  /// Later checks supersede earlier ones that are still in flight.
  Future<void> refreshAudioReadiness() async {
    final check = ++_readinessCheck;
    final ringtonePath = ringtoneAsset;
    final voicePath = _session.persona.audioTrackAsset;

    bool ringtoneOk;
    bool voiceOk;
    try {
      ringtoneOk = await _assetProbe(ringtonePath);
      voiceOk = voicePath != null &&
          voicePath.isNotEmpty &&
          await _assetProbe(voicePath);
    } catch (error) {
      debugPrint('[CallProvider] Audio readiness check failed: $error');
      return;
    }

    if (_isDisposed || check != _readinessCheck) return;
    if (_ringtoneAvailable == ringtoneOk && _voiceAvailable == voiceOk) return;
    _ringtoneAvailable = ringtoneOk;
    _voiceAvailable = voiceOk;
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
    if (_session.persona.id == persona.id) return;
    _session = _session.copyWith(persona: persona);
    _voiceAvailable = null;
    notifyListeners();
    unawaited(refreshAudioReadiness());
  }

  /// Runs one fire-and-forget audio operation and contains its failure.
  ///
  /// Audio is best-effort: a missing asset or player error (synchronous or
  /// asynchronous) is logged and never escapes into timers or the UI. The
  /// visual simulation continues and decline/hang-up/reset still clean up.
  void _runAudio(String operation, Future<void> Function() action) {
    unawaited(
      Future<void>.sync(action).catchError((Object error) {
        debugPrint('[CallProvider] Audio "$operation" failed: $error');
      }),
    );
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

  /// Whether the session is in a state where configuration can be modified.
  bool get canEditConfiguration => _canEditConfiguration;

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
        _startRingtone();
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

  /// Immediately transitions to ringing state (useful for instant triggers or preview flows).
  void triggerRinging() {
    if (_session.state != CallLifecycleState.configuration &&
        _session.state != CallLifecycleState.countdown) {
      return;
    }
    _operationGeneration++;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _session = _session.copyWith(
      state: CallLifecycleState.ringing,
      remainingCountdown: 0,
    );
    _startRingtone();
    notifyListeners();
  }

  void _startRingtone() {
    final asset = ringtoneAsset;
    _runAudio(
        'playRingtone', () => _audioService.playRingtone(assetPath: asset));
  }

  /// Answer incoming call, transition to active state, and start elapsed timer.
  ///
  /// Halts ringtone prior to starting peer dialogue playback.
  void answerCall() {
    if (_session.state != CallLifecycleState.ringing) return;
    final generation = ++_operationGeneration;

    // Sequence: Stop ringtone before starting peer dialogue audio
    _runAudio('stopAll', _audioService.stopAll);
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
      _runAudio('playPeerAudio', () => _audioService.playPeerAudio(audioTrack));
    }
  }

  /// Decline incoming call, halt ringtone, and transition to ended state.
  void declineCall() {
    if (_session.state != CallLifecycleState.ringing) return;
    _operationGeneration++;
    _runAudio('stopAll', _audioService.stopAll);
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

  /// Terminate active call and transition to ended state.
  void endCall() {
    if (_session.state != CallLifecycleState.active) return;
    _operationGeneration++;
    _runAudio('stopAll', _audioService.stopAll);
    _elapsedTimer?.cancel();
    _elapsedTimer = null;

    _session = _session.copyWith(
      state: CallLifecycleState.ended,
      isMuted: false,
      isSpeakerOn: false,
    );
    notifyListeners();
  }

  /// Return from ended state back to configuration state.
  ///
  /// Ignored in any other state: leaving countdown/ringing/active this way would
  /// skip timer and audio cleanup (use [cancelCountdown], [declineCall],
  /// [endCall] or [reset] instead).
  void returnToSetup() {
    if (_session.state != CallLifecycleState.ended) return;
    // Media was already stopped on decline/hang-up; repeat it idempotently so
    // configuration is always silent even if that earlier stop failed.
    _runAudio('stopAll', _audioService.stopAll);
    _session = _session.copyWith(
      state: CallLifecycleState.configuration,
      activeDurationSeconds: 0,
      remainingCountdown: _session.countdownSeconds,
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
    _runAudio('stopAll', _audioService.stopAll);

    _session = const CallSession();
    notifyListeners();
  }

  /// Handles foreground/background app lifecycle changes.
  ///
  /// Foreground-first MVP policy:
  /// - Suspended/paused/hidden while in countdown: cancels countdown safely.
  /// - Suspended/paused/hidden while in ringing or active call: stops audio and
  ///   returns to configuration, keeping the user's setup (caller, delay,
  ///   script, ringtone, language).
  void handleAppLifecycle(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.paused ||
        lifecycle == AppLifecycleState.detached ||
        lifecycle == AppLifecycleState.hidden) {
      if (_session.state == CallLifecycleState.countdown) {
        cancelCountdown();
      } else if (_session.state == CallLifecycleState.ringing ||
          _session.state == CallLifecycleState.active) {
        _abortToConfiguration();
      }
    }
  }

  /// Stops every timer and player and returns to configuration without
  /// discarding the user's configuration (unlike [reset]).
  void _abortToConfiguration() {
    _operationGeneration++;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
    _runAudio('stopAll', _audioService.stopAll);
    _session = _session.copyWith(
      state: CallLifecycleState.configuration,
      remainingCountdown: _session.countdownSeconds,
      activeDurationSeconds: 0,
      isMuted: false,
      isSpeakerOn: false,
    );
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      _syncScreenWake();
      super.notifyListeners();
    }
  }

  /// Holds the screen on only while a simulation is countdown/ringing/active.
  void _syncScreenWake() {
    final shouldKeepOn = _session.state == CallLifecycleState.countdown ||
        _session.state == CallLifecycleState.ringing ||
        _session.state == CallLifecycleState.active;
    if (shouldKeepOn == _screenKeptOn) return;
    _screenKeptOn = shouldKeepOn;
    _runPlatform(
      'setKeepScreenOn($shouldKeepOn)',
      () => _screenWake.setKeepScreenOn(shouldKeepOn),
    );
  }

  static bool _loggedPlatformFailure = false;

  void _runPlatform(String operation, Future<void> Function() action) {
    unawaited(
      Future<void>.sync(action).catchError((Object error) {
        if (_loggedPlatformFailure) return;
        _loggedPlatformFailure = true;
        debugPrint(
            '[CallProvider] Platform "$operation" unavailable (best-effort): $error');
      }),
    );
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
    _runAudio('stopAll', _audioService.stopAll);
    if (_screenKeptOn) {
      _screenKeptOn = false;
      _runPlatform(
          'setKeepScreenOn(false)', () => _screenWake.setKeepScreenOn(false));
    }
    super.dispose();
  }
}
