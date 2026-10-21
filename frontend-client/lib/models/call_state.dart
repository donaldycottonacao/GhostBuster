/// Call lifecycle phases for simulated calls in GhostBuster.
enum CallLifecycleState {
  /// User is configuring simulated call triggers, delay, and persona.
  configuration,

  /// Stealth countdown timer is running before call triggers.
  countdown,

  /// Incoming call screen is displayed and simulated ringing is active.
  ringing,

  /// User answered call; simulated call timer is counting up and dialogue audio plays.
  active,

  /// Call was declined, ended, or timed out.
  ended,
}

/// Representation of a caller persona profile.
class CallerPersona {
  final String id;
  final String name;
  final String number;
  final String? audioTrackAsset;

  const CallerPersona({
    required this.id,
    required this.name,
    required this.number,
    this.audioTrackAsset,
  });

  static const CallerPersona defaultPersona = CallerPersona(
    id: 'riley_morgan',
    name: 'Riley Morgan',
    number: '+1 (555) 234-5678',
    audioTrackAsset: 'assets/audio/peer_mom.mp3',
  );

  static const List<CallerPersona> defaultPersonas = [
    defaultPersona,
    CallerPersona(
      id: 'landlord',
      name: 'Landlord (Maintenance)',
      number: '+1 (555) 876-5432',
      audioTrackAsset: 'assets/audio/peer_landlord.mp3',
    ),
    CallerPersona(
      id: 'work_boss',
      name: 'Office Dispatch',
      number: '+1 (555) 432-1098',
      audioTrackAsset: null,
    ),
  ];
}

/// Ringtone choices offered on the setup screen, mapped to bundled asset paths.
///
/// Only licensed audio may be placed at these paths (see assets/audio/README.md).
/// A missing file is handled safely: the call screen still appears, silently.
class RingtoneOption {
  RingtoneOption._();

  static const String defaultId = 'containment';

  static const Map<String, String> assetPaths = {
    'containment': 'assets/audio/ringtone_ios.mp3',
    'classic': 'assets/audio/ringtone_android.mp3',
    'soft': 'assets/audio/ringtone_soft.mp3',
  };

  /// Asset path for [id], falling back to the default ringtone.
  static String assetFor(String id) => assetPaths[id] ?? assetPaths[defaultId]!;
}

/// State model tracking the current simulated call session.
class CallSession {
  final CallLifecycleState state;
  final CallerPersona persona;
  final int countdownSeconds;
  final int remainingCountdown;
  final String languageCode;
  final String situationText;
  final String voiceScriptText;
  final int activeDurationSeconds;
  final bool isMuted;
  final bool isSpeakerOn;
  final String ringtoneId;

  const CallSession({
    this.state = CallLifecycleState.configuration,
    this.persona = CallerPersona.defaultPersona,
    this.countdownSeconds = 30,
    this.remainingCountdown = 30,
    this.languageCode = 'en',
    this.situationText = '',
    this.voiceScriptText = 'Hey, can you call me? I need a reason to step out.',
    this.activeDurationSeconds = 0,
    this.isMuted = false,
    this.isSpeakerOn = false,
    this.ringtoneId = RingtoneOption.defaultId,
  });

  CallSession copyWith({
    CallLifecycleState? state,
    CallerPersona? persona,
    int? countdownSeconds,
    int? remainingCountdown,
    String? languageCode,
    String? situationText,
    String? voiceScriptText,
    int? activeDurationSeconds,
    bool? isMuted,
    bool? isSpeakerOn,
    String? ringtoneId,
  }) {
    return CallSession(
      state: state ?? this.state,
      persona: persona ?? this.persona,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      remainingCountdown: remainingCountdown ?? this.remainingCountdown,
      languageCode: languageCode ?? this.languageCode,
      situationText: situationText ?? this.situationText,
      voiceScriptText: voiceScriptText ?? this.voiceScriptText,
      activeDurationSeconds:
          activeDurationSeconds ?? this.activeDurationSeconds,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      ringtoneId: ringtoneId ?? this.ringtoneId,
    );
  }
}

/// Architectural alias for CallLifecycleState.
typedef CallState = CallLifecycleState;
