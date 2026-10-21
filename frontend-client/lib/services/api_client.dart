import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/api_models.dart';

/// Network API Client connecting the Flutter client to the GhostBuster backend.
///
/// Features:
/// - Environment-aware base URL resolution (Android emulator vs Web / Localhost).
/// - Safe offline fallback ensuring application operates seamlessly without remote servers.
/// - Trilingual AI escape script generation.
/// - Caller persona synchronization.
/// - Escape session telemetry.
class GhostBusterApiClient {
  final http.Client _client;
  final String _baseUrl;
  final Duration timeout;

  GhostBusterApiClient({
    http.Client? client,
    String? baseUrl,
    this.timeout = const Duration(seconds: 4),
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? _resolveDefaultBaseUrl();

  /// Determine appropriate base URL based on runtime platform.
  static String _resolveDefaultBaseUrl() {
    // 1. Check compile-time environment override
    const envUrl = String.fromEnvironment('API_URL');
    if (envUrl.isNotEmpty) return envUrl;

    // 2. Android emulator requires 10.0.2.2 to reach host machine loopback
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }

    // 3. Web, iOS Simulator, and Desktop use localhost
    return 'http://127.0.0.1:8000';
  }

  String get baseUrl => _baseUrl;

  /// Check backend connectivity and database health.
  Future<HealthStatusModel?> checkHealth() async {
    try {
      final uri = Uri.parse('$_baseUrl/health');
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return HealthStatusModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('[ApiClient] Health check offline or unreachable: $e');
    }
    return null;
  }

  /// Request AI-generated escape dialogue tailored to situation and language.
  /// Gracefully falls back to local trilingual samples if backend is offline.
  Future<String> generateScript({
    required String situation,
    required String language,
    String tone = 'panicked',
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/scripts/generate');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'situation': situation.isEmpty ? 'At a gathering' : situation,
              'language': language,
              'tone': tone,
            }),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = ScriptGenerateResponseModel.fromJson(data);
        if (result.generatedScript.isNotEmpty) {
          return result.generatedScript;
        }
      }
    } catch (e) {
      debugPrint(
          '[ApiClient] Remote script generation offline. Using local template: $e');
    }

    // Safe offline fallback
    return _localFallbackScript(language);
  }

  /// Fetch caller personas from backend, falling back to local defaults if offline.
  Future<List<PersonaApiModel>> getPersonas() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/personas');
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((item) =>
                PersonaApiModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[ApiClient] Fetch personas offline: $e');
    }

    return _localDefaultPersonas();
  }

  /// Record completed or cancelled escape call session to backend.
  Future<EscapeSessionRecordModel?> recordSession(
    EscapeSessionRecordModel session,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/sessions');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(session.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return EscapeSessionRecordModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('[ApiClient] Session recording offline: $e');
    }
    return session;
  }

  static String _localFallbackScript(String language) {
    return switch (language) {
      'tl' =>
        'Uy, puwede mo ba akong tawagan? Kailangan ko ng dahilan para makalabas.',
      'ceb' => 'Uy, matawagan ko nimo? Kinahanglan kog rason para makagawas.',
      _ => 'Hey, can you call me? I need a reason to step out.',
    };
  }

  static List<PersonaApiModel> _localDefaultPersonas() {
    return const [
      PersonaApiModel(
        id: 'riley_morgan',
        name: 'Riley Morgan',
        number: '+1 (555) 019-2834',
        relationship: 'Emergency contact',
        voiceStyle: 'PANICKED',
        ringtone: 'containment',
        audioAsset: 'assets/audio/peer_mom.mp3',
        isCustom: false,
      ),
      PersonaApiModel(
        id: 'mom',
        name: 'Mom',
        number: '+1 (555) 234-5678',
        relationship: 'Mother',
        voiceStyle: 'WORRIED',
        ringtone: 'containment',
        audioAsset: 'assets/audio/peer_mom.mp3',
        isCustom: false,
      ),
      PersonaApiModel(
        id: 'landlord',
        name: 'Landlord (Maintenance)',
        number: '+1 (555) 876-5432',
        relationship: 'Property Manager',
        voiceStyle: 'URGENT',
        ringtone: 'soft',
        audioAsset: 'assets/audio/peer_landlord.mp3',
        isCustom: false,
      ),
      PersonaApiModel(
        id: 'work_boss',
        name: 'Office Dispatch',
        number: '+1 (555) 432-1098',
        relationship: 'Workplace Support',
        voiceStyle: 'CALM & DIRECT',
        ringtone: 'classic',
        audioAsset: null,
        isCustom: false,
      ),
    ];
  }
}
