import 'dart:convert';

/// A user-recorded voice script for a simulated call, stored on-device.
///
/// Recordings live in app-private storage (never the bundled asset directory
/// and never a public/shared directory). Only [filePath] metadata is persisted;
/// the audio bytes stay in the private file referenced by that path.
class VoiceScenario {
  /// Stable unique identifier (also used to name the audio file on disk).
  final String id;

  /// User-facing scenario name, e.g. "Mom – pick me up".
  final String name;

  /// Optional longer description of when to use this scenario.
  final String description;

  /// Absolute path to the recorded audio file in app-private storage.
  final String filePath;

  /// Recording length in milliseconds (0 when unknown).
  final int durationMs;

  /// Creation timestamp (UTC) used for stable list ordering.
  final DateTime createdAt;

  const VoiceScenario({
    required this.id,
    required this.name,
    required this.description,
    required this.filePath,
    required this.durationMs,
    required this.createdAt,
  });

  VoiceScenario copyWith({
    String? name,
    String? description,
    String? filePath,
    int? durationMs,
  }) {
    return VoiceScenario(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      filePath: filePath ?? this.filePath,
      durationMs: durationMs ?? this.durationMs,
      createdAt: createdAt,
    );
  }

  /// Human-readable mm:ss duration.
  String get formattedDuration {
    final totalSeconds = (durationMs / 1000).round();
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'file_path': filePath,
        'duration_ms': durationMs,
        'created_at': createdAt.toUtc().toIso8601String(),
      };

  factory VoiceScenario.fromJson(Map<String, dynamic> json) {
    return VoiceScenario(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      filePath: json['file_path'] as String? ?? '',
      durationMs: (json['duration_ms'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '')?.toUtc() ??
              DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }

  /// Encodes a list of scenarios to a JSON string for persistence.
  static String encodeList(List<VoiceScenario> scenarios) =>
      jsonEncode(scenarios.map((s) => s.toJson()).toList());

  /// Decodes a persisted JSON string, tolerating corruption by skipping bad
  /// entries rather than throwing.
  static List<VoiceScenario> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      final result = <VoiceScenario>[];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          try {
            result.add(VoiceScenario.fromJson(item));
          } catch (_) {
            // Skip a single malformed entry; keep the rest usable.
          }
        }
      }
      return result;
    } catch (_) {
      return const [];
    }
  }

  @override
  bool operator ==(Object other) =>
      other is VoiceScenario &&
      other.id == id &&
      other.name == name &&
      other.description == description &&
      other.filePath == filePath &&
      other.durationMs == durationMs &&
      other.createdAt == createdAt;

  @override
  int get hashCode =>
      Object.hash(id, name, description, filePath, durationMs, createdAt);
}
