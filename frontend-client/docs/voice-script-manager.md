# Voice Script Manager

In-app recording, previewing, saving, renaming, and deleting of user voice
scripts for simulated calls. Recordings are stored on-device only (no cloud, no
backend) and persist across app restarts.

## User flow

1. On the setup screen, tap the **Voice scripts** row (below the ringtone row).
2. Tap **Create Recording** (grants microphone permission on first use).
3. Record with Pause/Resume, Stop, or Cancel. A timer and mic level animate.
4. After Stop, **Preview**, **Retake**, or **Save** (with a name + optional
   description).
5. Back in the list, each scenario offers Preview, **Use for call**, Rename,
   and Delete.
6. A scenario chosen with **Use for call** plays as the peer voice after you
   answer the simulated call, in place of the persona's bundled audio.

Recording is blocked while a simulated call is ringing or active.

## Architecture

| Layer | File | Responsibility |
| :--- | :--- | :--- |
| Model | `lib/models/voice_scenario.dart` | `VoiceScenario` + JSON (corruption-tolerant). |
| Storage | `lib/services/voice_scenario_store.dart` | Metadata via `shared_preferences`; files via `path_provider` (app-private `voice_scenarios/`). Injectable backends for tests. |
| Recorder | `lib/services/voice_recorder.dart` | Wraps `package:record` (AAC `.m4a`); permission, start/pause/resume/stop/cancel, amplitude stream. |
| Audio | `lib/services/audio_service.dart` | Adds `playVoiceFile` (DeviceFileSource) + isolated preview player. |
| Controller | `lib/providers/voice_script_manager_controller.dart` | Record/review/list state machine, previews, persistence, stale-callback guards. |
| Call wiring | `lib/providers/call_provider.dart` | `selectRecordedVoice` / `clearRecordedVoice`; `answerCall` prefers the recorded file over the persona asset. |
| UI | `lib/screens/voice_script_manager_screen.dart` | Full manager screen matching the GhostBuster setup theme. |

## Playback sequence (unchanged contract)

countdown -> ringing (ringtone loops) -> answer (ringtone stops) -> selected
voice plays (recorded file **or** bundled persona asset) -> hang up -> cleanup.

## Permissions

- Android: `RECORD_AUDIO` in `android/app/src/main/AndroidManifest.xml`.
- Denied / permanently-denied states surface localized messages; permanently
  denied directs the user to system settings.

## Dependencies added

`record`, `path_provider`, `shared_preferences`, `permission_handler`.

## Privacy

Recordings never leave the device and are stored in app-private storage (not the
bundled asset directory, not a public/shared directory). Delete removes both the
metadata and the audio file. File paths are not logged.

## Localization

New `voice*` keys in `lib/l10n/app_en.arb`, `app_tl.arb`, `app_ceb.arb`.
Regenerate with `flutter gen-l10n` (or any `flutter` build, since
`generate: true`).

## Tests

- `test/voice_scenario_store_test.dart` — serialization, persistence, CRUD,
  corruption tolerance.
- `test/voice_script_manager_controller_test.dart` — permissions, record/stop/
  save, retake/cancel, preview, delete, missing/empty file, persistence.
- `test/call_provider_recorded_voice_test.dart` — selecting a recording plays
  the file (not the asset), fallback, mid-call guards.
- `test/voice_script_manager_widget_test.dart` — empty state, record->save
  rendering, delete-with-confirm.
