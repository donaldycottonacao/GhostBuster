import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_client/models/voice_scenario.dart';
import 'package:frontend_client/services/voice_scenario_store.dart';

import 'helpers/voice_fakes.dart';

void main() {
  group('VoiceScenario serialization', () {
    test('round-trips through JSON', () {
      final scenario = makeScenario(
        id: 'a',
        name: 'Mom pickup',
        description: 'party exit',
        durationMs: 4200,
      );
      final decoded = VoiceScenario.fromJson(scenario.toJson());
      expect(decoded, scenario);
    });

    test('decodeList tolerates corruption and bad entries', () {
      expect(VoiceScenario.decodeList(null), isEmpty);
      expect(VoiceScenario.decodeList(''), isEmpty);
      expect(VoiceScenario.decodeList('not json'), isEmpty);
      expect(VoiceScenario.decodeList('{"not":"a list"}'), isEmpty);
      // One good entry, one malformed (missing id) -> keeps the good one.
      const raw =
          '[{"id":"x","name":"X","file_path":"/p.m4a","duration_ms":1},{"name":"no id"}]';
      final list = VoiceScenario.decodeList(raw);
      expect(list.length, 1);
      expect(list.first.id, 'x');
    });

    test('formattedDuration renders mm:ss', () {
      expect(
          makeScenario(id: '1', durationMs: 65000).formattedDuration, '01:05');
    });
  });

  group('VoiceScenarioStore', () {
    late InMemoryMetadataBackend backend;
    late FakeRecordingFileStorage storage;
    late VoiceScenarioStore store;

    setUp(() {
      backend = InMemoryMetadataBackend();
      storage = FakeRecordingFileStorage();
      store = VoiceScenarioStore(backend: backend, storage: storage);
    });

    test('starts empty', () async {
      expect(await store.loadAll(), isEmpty);
    });

    test('upsert adds then persists, newest first', () async {
      await store.upsert(makeScenario(
          id: '1', name: 'First', createdAt: DateTime.utc(2026, 1, 1)));
      await store.upsert(makeScenario(
          id: '2', name: 'Second', createdAt: DateTime.utc(2026, 2, 1)));
      final all = await store.loadAll();
      expect(all.map((s) => s.id).toList(), ['2', '1']);
    });

    test('persistence survives a fresh store on the same backend', () async {
      await store.upsert(makeScenario(id: '1', name: 'Keep'));
      final reopened = VoiceScenarioStore(backend: backend, storage: storage);
      final all = await reopened.loadAll();
      expect(all.single.name, 'Keep');
    });

    test('rename updates name and description', () async {
      await store.upsert(makeScenario(id: '1', name: 'Old'));
      await store.rename('1', name: 'New', description: 'desc');
      final s = (await store.loadAll()).single;
      expect(s.name, 'New');
      expect(s.description, 'desc');
    });

    test('delete removes metadata and the audio file', () async {
      final scenario = makeScenario(id: '1', filePath: '/tmp/voice/1.m4a');
      storage.existing.add(scenario.filePath);
      await store.upsert(scenario);
      await store.delete('1');
      expect(await store.loadAll(), isEmpty);
      expect(storage.deleted, contains('/tmp/voice/1.m4a'));
    });

    test('audioExists reflects file presence', () async {
      final scenario = makeScenario(id: '1', filePath: '/tmp/voice/1.m4a');
      expect(await store.audioExists(scenario), isFalse);
      storage.existing.add(scenario.filePath);
      expect(await store.audioExists(scenario), isTrue);
    });
  });
}
