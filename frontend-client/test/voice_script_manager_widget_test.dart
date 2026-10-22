import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_client/l10n/app_localizations.dart';
import 'package:frontend_client/providers/voice_script_manager_controller.dart';
import 'package:frontend_client/services/voice_scenario_store.dart';

import 'package:frontend_client/screens/voice_script_manager_screen.dart';

import 'helpers/audio_fakes.dart';
import 'helpers/voice_fakes.dart';

Widget _wrap(VoiceScriptManagerController controller) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: VoiceScriptManagerScreen(controller: controller),
  );
}

void main() {
  late FakeVoiceRecorder recorder;
  late FakeRecordingFileStorage storage;
  late InMemoryMetadataBackend backend;
  late VoiceScenarioStore store;
  late RecordingAudioService audio;

  VoiceScriptManagerController build() {
    var n = 0;
    return VoiceScriptManagerController(
      recorder: recorder,
      store: store,
      audio: audio,
      idFactory: () => 'id${n++}',
      clock: () => DateTime.utc(2026, 1, 1),
    );
  }

  setUp(() {
    recorder = FakeVoiceRecorder();
    storage = FakeRecordingFileStorage();
    backend = InMemoryMetadataBackend();
    store = VoiceScenarioStore(backend: backend, storage: storage);
    audio = RecordingAudioService();
  });

  testWidgets('shows empty state when there are no scenarios', (tester) async {
    final controller = build();
    await tester.pumpWidget(_wrap(controller));
    // Let the post-frame load() complete (loading -> list) without
    // pumpAndSettle, which would hang on the loading spinner's animation.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('No voice scripts yet'), findsOneWidget);
    expect(find.text('Create Recording'), findsOneWidget);
    controller.dispose();
  });

  testWidgets('record -> stop -> save adds a scenario to the list',
      (tester) async {
    // NOTE: the recording phase keeps a periodic ticker + amplitude stream
    // running; pumping real durations against it is flaky in the harness.
    // The full record->stop->save->persist path is covered deterministically
    // by voice_script_manager_controller_test.dart. This widget test is a
    // lighter rendering check driven through the controller.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = build();
    await tester.pumpWidget(_wrap(controller));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // Drive the controller through runAsync so its async recorder/store calls
    // complete, then pump a single frame to rebuild (no duration pumping that
    // would advance the recording ticker and hang the harness).
    await tester.runAsync(() => controller.startRecording());
    await tester.pump();
    expect(find.text('Recording...'), findsOneWidget);

    await tester.runAsync(() => controller.stopRecording());
    await tester.pump();
    expect(find.text('Recording captured'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Save'), findsOneWidget);

    // Saving + name-sheet persistence is covered end-to-end by the controller
    // unit tests; here we confirm the list re-renders with the new scenario.
    await tester.runAsync(() => controller.save(name: 'Mom pickup'));
    await tester.pump();

    expect(find.text('Mom pickup'), findsOneWidget);
    expect(controller.scenarios.single.name, 'Mom pickup');
    controller.dispose();
  });

  testWidgets('delete removes a saved scenario after confirm', (tester) async {
    storage.existing.add('/tmp/voice/s1.m4a');
    await store.upsert(makeScenario(
        id: 's1', name: 'Delete me', filePath: '/tmp/voice/s1.m4a'));
    final controller = build();
    await tester.pumpWidget(_wrap(controller));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Delete me'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    // Confirm dialog.
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Delete me'), findsNothing);
    expect(controller.scenarios, isEmpty);
    controller.dispose();
  });
}
