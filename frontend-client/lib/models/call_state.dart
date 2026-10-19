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
    id: 'mom',
    name: 'Mom',
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

/// State model tracking the current simulated call session.
class CallSession {
  final CallLifecycleState state;
  final CallerPersona persona;
  final int countdownSeconds;
  final int remainingCountdown;
  final int activeDurationSeconds;
  final bool isMuted;
  final bool isSpeakerOn;

  const CallSession({
    this.state = CallLifecycleState.configuration,
    this.persona = CallerPersona.defaultPersona,
    this.countdownSeconds = 10,
    this.remainingCountdown = 10,
    this.activeDurationSeconds = 0,
    this.isMuted = false,
    this.isSpeakerOn = false,
  });

  CallSession copyWith({
    CallLifecycleState? state,
    CallerPersona? persona,
    int? countdownSeconds,
    int? remainingCountdown,
    int? activeDurationSeconds,
    bool? isMuted,
    bool? isSpeakerOn,
  }) {
    return CallSession(
      state: state ?? this.state,
      persona: persona ?? this.persona,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      remainingCountdown: remainingCountdown ?? this.remainingCountdown,
      activeDurationSeconds: activeDurationSeconds ?? this.activeDurationSeconds,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
    );
  }
}
