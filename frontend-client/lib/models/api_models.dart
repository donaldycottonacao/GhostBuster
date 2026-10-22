// Data transfer objects matching GhostBuster backend API schemas.

class HealthStatusModel {
  final String status;
  final String appName;
  final String version;
  final String environment;
  final String database;

  const HealthStatusModel({
    required this.status,
    required this.appName,
    required this.version,
    required this.environment,
    required this.database,
  });

  factory HealthStatusModel.fromJson(Map<String, dynamic> json) {
    return HealthStatusModel(
      status: json['status'] as String? ?? 'unknown',
      appName: json['app_name'] as String? ?? 'GhostBuster API',
      version: json['version'] as String? ?? '0.1.0',
      environment: json['environment'] as String? ?? 'development',
      database: json['database'] as String? ?? 'disconnected',
    );
  }
}

class ScriptGenerateResponseModel {
  final String situation;
  final String language;
  final String tone;
  final String generatedScript;
  final List<String> alternatives;

  const ScriptGenerateResponseModel({
    required this.situation,
    required this.language,
    required this.tone,
    required this.generatedScript,
    required this.alternatives,
  });

  factory ScriptGenerateResponseModel.fromJson(Map<String, dynamic> json) {
    return ScriptGenerateResponseModel(
      situation: json['situation'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
      tone: json['tone'] as String? ?? 'panicked',
      generatedScript: json['generated_script'] as String? ?? '',
      alternatives: (json['alternatives'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class PersonaApiModel {
  final String id;
  final String name;
  final String number;
  final String relationship;
  final String voiceStyle;
  final String ringtone;
  final String? audioAsset;
  final bool isCustom;

  const PersonaApiModel({
    required this.id,
    required this.name,
    required this.number,
    required this.relationship,
    required this.voiceStyle,
    required this.ringtone,
    this.audioAsset,
    required this.isCustom,
  });

  factory PersonaApiModel.fromJson(Map<String, dynamic> json) {
    return PersonaApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      number: json['number'] as String,
      relationship: json['relationship'] as String? ?? 'Emergency contact',
      voiceStyle: json['voice_style'] as String? ?? 'PANICKED',
      ringtone: json['ringtone'] as String? ?? 'containment',
      audioAsset: json['audio_asset'] as String?,
      isCustom: json['is_custom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'number': number,
        'relationship': relationship,
        'voice_style': voiceStyle,
        'ringtone': ringtone,
        'audio_asset': audioAsset,
      };
}

class EscapeSessionRecordModel {
  final String? id;
  final String? personaId;
  final String callerName;
  final String? situation;
  final String script;
  final int delaySeconds;
  final int durationSeconds;
  final String status;
  final String language;

  const EscapeSessionRecordModel({
    this.id,
    this.personaId,
    required this.callerName,
    this.situation,
    required this.script,
    required this.delaySeconds,
    required this.durationSeconds,
    required this.status,
    required this.language,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (personaId != null) 'persona_id': personaId,
        'caller_name': callerName,
        if (situation != null) 'situation': situation,
        'script': script,
        'delay_seconds': delaySeconds,
        'duration_seconds': durationSeconds,
        'status': status,
        'language': language,
      };

  factory EscapeSessionRecordModel.fromJson(Map<String, dynamic> json) {
    return EscapeSessionRecordModel(
      id: json['id'] as String?,
      personaId: json['persona_id'] as String?,
      callerName: json['caller_name'] as String? ?? 'Riley Morgan',
      situation: json['situation'] as String?,
      script: json['script'] as String? ?? '',
      delaySeconds: json['delay_seconds'] as int? ?? 0,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      status: json['status'] as String? ?? 'completed',
      language: json['language'] as String? ?? 'en',
    );
  }
}
