import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_client/models/api_models.dart';
import 'package:frontend_client/services/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GhostBusterApiClient', () {
    test('checkHealth returns model when backend responds 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/health');
        return http.Response(
          jsonEncode({
            'status': 'ok',
            'app_name': 'GhostBuster API',
            'version': '0.1.0',
            'environment': 'test',
            'database': 'connected',
          }),
          200,
        );
      });

      final apiClient = GhostBusterApiClient(
        client: mockClient,
        baseUrl: 'http://localhost:8000',
      );

      final health = await apiClient.checkHealth();
      expect(health, isNotNull);
      expect(health!.status, 'ok');
      expect(health.database, 'connected');
    });

    test('checkHealth returns null on network exception without throwing', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Network unreachable');
      });

      final apiClient = GhostBusterApiClient(
        client: mockClient,
        baseUrl: 'http://invalid-host:9999',
      );

      final health = await apiClient.checkHealth();
      expect(health, isNull);
    });

    test('generateScript parses backend AI response on success', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/scripts/generate');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['language'], 'tl');

        return http.Response(
          jsonEncode({
            'situation': 'meeting',
            'language': 'tl',
            'tone': 'urgent',
            'generated_script': 'Pumutok ang tubo sa kusina! Umuwi ka na!',
            'alternatives': [],
          }),
          200,
        );
      });

      final apiClient = GhostBusterApiClient(
        client: mockClient,
        baseUrl: 'http://localhost:8000',
      );

      final script = await apiClient.generateScript(
        situation: 'meeting',
        language: 'tl',
      );
      expect(script, 'Pumutok ang tubo sa kusina! Umuwi ka na!');
    });

    test('generateScript returns safe local fallback if backend is offline', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final apiClient = GhostBusterApiClient(
        client: mockClient,
        baseUrl: 'http://localhost:8000',
      );

      final script = await apiClient.generateScript(
        situation: 'party',
        language: 'ceb',
      );
      expect(script, 'Uy, matawagan ko nimo? Kinahanglan kog rason para makagawas.');
    });

    test('getPersonas parses remote personas list', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([
            {
              'id': 'custom_boss',
              'name': 'Big Boss',
              'number': '+1 555 9999',
              'relationship': 'Manager',
              'voice_style': 'DIRECT',
              'ringtone': 'classic',
              'audio_asset': null,
              'is_custom': true,
            }
          ]),
          200,
        );
      });

      final apiClient = GhostBusterApiClient(
        client: mockClient,
        baseUrl: 'http://localhost:8000',
      );

      final personas = await apiClient.getPersonas();
      expect(personas.length, 1);
      expect(personas.first.id, 'custom_boss');
      expect(personas.first.name, 'Big Boss');
    });

    test('recordSession sends formatted JSON payload', () async {
      var recordedPayload = '';
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/sessions');
        recordedPayload = request.body;
        return http.Response(
          jsonEncode({
            'id': 'test-uuid-1234',
            'persona_id': 'riley_morgan',
            'caller_name': 'Riley Morgan',
            'script': 'Test escape script',
            'delay_seconds': 30,
            'duration_seconds': 18,
            'status': 'completed',
            'language': 'en',
            'created_at': '2026-10-21T06:00:00Z',
          }),
          201,
        );
      });

      final apiClient = GhostBusterApiClient(
        client: mockClient,
        baseUrl: 'http://localhost:8000',
      );

      const session = EscapeSessionRecordModel(
        personaId: 'riley_morgan',
        callerName: 'Riley Morgan',
        script: 'Test escape script',
        delaySeconds: 30,
        durationSeconds: 18,
        status: 'completed',
        language: 'en',
      );

      final result = await apiClient.recordSession(session);
      expect(result, isNotNull);
      expect(recordedPayload, contains('riley_morgan'));
      expect(recordedPayload, contains('18'));
    });
  });
}
