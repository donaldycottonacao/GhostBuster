import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_client/providers/voice_script_manager_controller.dart';
import 'package:frontend_client/services/voice_recorder.dart';
import 'package:frontend_client/services/voice_scenario_store.dart';

import 'helpers/audio_fakes.dart';
import 'helpers/voice_fakes.dart';

VoiceScriptManagerController buildController({
  required FakeVoiceRecorder recorder,
  required VoiceScenarioStore store,
  required RecordingAudioService audio,
  int idSeed = 0,
}) {
  var counter = idSeed;
  return VoiceScriptManagerController(
    recorder: recorder,
    store: store,
    audio: audio,
    idFactory: () => 'id${counter++}',
    clock: () => DateTime.utc(2026, 1, 1),
  );
}

void main() {
  late FakeVoiceRecorder recorder;
  late FakeRecordingFileStorage storage;
  late InMemoryMetadataBackend backend;
  late VoiceScenarioStore store;
  late RecordingAudioService audio;
  late VoiceScriptManagerController controller;

  setUp(() {
    recorder = FakeVoiceRecorder();
    storage = FakeRecordingFileStorage();
    backend = InMemoryMetadataBackend();
    store = VoiceScenarioStore(backend: backend, storage: storage);
    audio = RecordingAudioService();
    controller =
        buildController(recorder: recorder, store: store, audio: audio);
  });

  tearDown(() => controller.dispose());

  group('Permission handling', () {
    test('denied permission surfaces error and does not record', () async {
      await controller.load();
      recorder.permission = MicPermissionStatus.denied;
      await controller.startRecording();
      expect(controller.error, RecordingError.permissionDenied);
      expect(controller.phase, ManagerPhase.list);
      expect(recorder.log, isNot(contains(startsWith('start'))));
    });

    test('permanently denied surfaces the settings-specific error', () async {
      recorder.permission = MicPermissionStatus.permanentlyDenied;
      await controller.startRecording();
      expect(controller.error, RecordingError.permissionPermanentlyDenied);
    });

    test('granted permission begins recording', () async {
      await controller.load();
      await controller.startRecording();
      expect(controller.phase, ManagerPhase.recording);
      expect(recorder.recording, isTrue);
    });
  });

  group('Record -> stop -> save', () {
    test('stop moves to review, save persists and returns to list', () async {
      await controller.load();
      await controller.startRecording();
      await controller.stopRecording();
      expect(controller.phase, ManagerPhase.review);

      final saved = await controller.save(name: 'Mom', description: 'exit');
      expect(saved, isNotNull);
      expect(controller.phase, ManagerPhase.list);
      expect(controller.scenarios.single.name, 'Mom');
      // Persisted to the backing store.
      expect((await store.loadAll()).single.name, 'Mom');
    });

    test('empty stop result surfaces emptyRecording error', () async {
      recorder.stopReturnsNull = true;
      await controller.load();
      await controller.startRecording();
      await controller.stopRecording();
      expect(controller.error, RecordingError.emptyRecording);
      expect(controller.phase, ManagerPhase.list);
    });

    test('start failure surfaces startFailed error', () async {
      recorder.startThrows = true;
      await controller.load();
      await controller.startRecording();
      expect(controller.error, RecordingError.startFailed);
      expect(controller.phase, isNot(ManagerPhase.recording));
    });
  });

  group('Retake and cancel', () {
    test('retake discards pending and starts a fresh recording', () async {
      await controller.load();
      await controller.startRecording();
      await controller.stopRecording();
      await controller.retake();
      expect(controller.phase, ManagerPhase.recording);
      expect(recorder.log.where((e) => e.startsWith('start')).length, 2);
    });

    test('cancel returns to list and cancels the recorder', () async {
      await controller.load();
      await controller.startRecording();
      await controller.cancelRecording();
      expect(controller.phase, ManagerPhase.list);
      expect(recorder.log, contains('cancel'));
    });
  });

  group('Preview', () {
    test('previewPending plays the captured file', () async {
      await controller.load();
      await controller.startRecording();
      await controller.stopRecording();
      await controller.previewPending();
      expect(controller.previewingId, '__pending__');
      expect(audio.isPreviewPlaying, isTrue);
      await controller.stopPreview();
      expect(audio.isPreviewPlaying, isFalse);
    });

    test('previewScenario on a missing file reports error', () async {
      final scenario = makeScenario(id: 's1', filePath: '/tmp/voice/s1.m4a');
      await store.upsert(scenario);
      await controller.load();
      final ok = await controller.previewScenario(scenario);
      expect(ok, isFalse);
      expect(controller.error, RecordingError.emptyRecording);
    });

    test('previewScenario plays when the file exists', () async {
      final scenario = makeScenario(id: 's1', filePath: '/tmp/voice/s1.m4a');
      storage.existing.add(scenario.filePath);
      await store.upsert(scenario);
      await controller.load();
      final ok = await controller.previewScenario(scenario);
      expect(ok, isTrue);
      expect(controller.previewingId, 's1');
    });
  });

  group('Delete', () {
    test('delete removes scenario and stops its preview', () async {
      final scenario = makeScenario(id: 's1', filePath: '/tmp/voice/s1.m4a');
      storage.existing.add(scenario.filePath);
      await store.upsert(scenario);
      await controller.load();
      await controller.previewScenario(scenario);
      await controller.delete('s1');
      expect(controller.scenarios, isEmpty);
      expect(controller.previewingId, isNull);
      expect(storage.deleted, contains('/tmp/voice/s1.m4a'));
    });
  });

  group('Persistence across controller restart', () {
    test('a second controller loads the saved scenario', () async {
      await controller.load();
      await controller.startRecording();
      await controller.stopRecording();
      await controller.save(name: 'Persisted');

      final second =
          buildController(recorder: recorder, store: store, audio: audio);
      addTearDown(second.dispose);
      await second.load();
      expect(second.scenarios.single.name, 'Persisted');
    });
  });
}
