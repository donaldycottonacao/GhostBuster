# GhostBuster — Phase 9: Automated Tests and Device Reliability

Date: 2026-10-21 · Branch: `development` (clean at `ff1c039` before this phase) · Nothing committed or pushed.

## Summary

- The automated suite grew from **69 to 156 tests**, all passing. `flutter analyze` reports no issues, and `flutter build apk --debug` passes.
- **Seven defects were confirmed (D1–D7).** Five were confirmed by a failing test before the fix. Two were found on the emulator: the launch crash, and the duplicate ARM trigger, which got a regression test after the fix. All seven are fixed with small, targeted changes. One of them (D1) meant **the debug APK could not launch at all**: `MainActivity` was missing, so the app crashed on start. Earlier phases only reported that the APK *built*.
- The full flow was run on the **Android emulator** (Android 17 / API 37). **No physical Android device was available**, so every physical-device case is **Not Run**.
- **No audio was audible anywhere.** The repository has no ringtone or voice files (Phase 8 staged none), so playback runs through the documented silent fallback: `Unable to load asset`, caught, no crash.

## A. Test environment

| Item | Value |
|---|---|
| OS | Windows 11 (26H2) |
| Flutter / Dart | 3.47.7 stable / 3.13.5 |
| Android SDK | 36.0.0, emulator 37.2.12.0. `flutter doctor` warns that cmdline-tools are missing and the licence status is unknown; neither blocked the build |
| Emulator | AVD `Medium_Phone_API_37.0`: `sdk_gphone64_x86_64`, Android 17, 1080×2400 at 420 dpi |
| Physical device | **None available** |
| Audio package | `audioplayers` 6.8.1 |
| Test-only dependency added | `fake_async: any` in dev_dependencies. It was already a transitive dependency pinned by `flutter_test` (1.3.3); `any` follows the existing `intl: any` convention |

## B. Automated test results

### Baseline (before changes)

`flutter pub get` passed. `dart format` passed (25 files, 0 changed). `flutter analyze` reported no issues. `flutter test` passed **69/69**.

Gaps found in that baseline:
- **No test advanced a timer.** Countdown expiry was never exercised; tests used `triggerRinging()` as a shortcut. The Phase 4 report lists "timer reaches zero" as verified, but no test did that.
- Several older test names promise more than they check. For example, `declineCall stops ringtone and transitions to ended state` and `answerCall halts ringtone before initiating peer audio track` only test rejected calls. They were left unchanged, and the new tests cover the real behavior.
- No test checked audio ordering at the player level, failure containment, stale async work, lifecycle events through the real `WidgetsBindingObserver`, or repeated use.

### Final

| File | Tests | Scope |
|---|---|---|
| `call_provider_timing_test.dart` (new) | 51 | Controller on a fake clock: transition groups A–I, races, lifecycle, audio failures, repeated use |
| `audio_service_ordering_test.dart` (new) | 17 | Real `AudioService` with fake `AudioPlayer`s: ordering, failure isolation, stale operations, provider integration |
| `call_flow_widget_test.dart` (new) | 19 | Real screens through `ScreenPreviewHost`: countdown, cancel, slide/tap/semantics answer, decline, hang-up, lifecycle, repeats, 320×568 at 1.5× text in en/tl/ceb |
| Pre-existing (6 files) | 69 | Unchanged except one assertion in `widget_test.dart` (see G, D3) |
| **Total** | **156** | **All passed.** None skipped |

Final commands, run from `frontend-client/`:
- `flutter pub get`: PASS
- `dart format lib test`: PASS (30 files, 0 changed)
- `flutter analyze`: PASS (no issues)
- `flutter test`: PASS (156/156)
- `flutter build apk --debug`: PASS

Test helpers live in `test/helpers/`:
- `RecordingAudioService` records an ordered call log and can inject failures, either synchronously or asynchronously.
- `FakeAudioPlayer` records player-level calls, with gates to simulate slow platform calls.
- `loadSdkRoboto` loads real Roboto metrics from the Flutter SDK for layout tests. The default test font draws every glyph as a wide box and reported overflows that don't happen with real fonts.

## Testability inventory

| Component | Implementation | Finding | Action |
|---|---|---|---|
| Call controller | `CallProvider` (`ChangeNotifier`); `AudioServiceBase` injected through the constructor | Good | Reused |
| Countdown and duration timers | `Timer.periodic` inside the provider | Deterministic under `fake_async` and `testWidgets` | No production change |
| Audio service | `AudioService.custom(ringtonePlayer:, voicePlayer:)` | Real `AudioPlayer` instances can be swapped for `Fake implements AudioPlayer` | Reused |
| Scenario mapping | `CallerPersona` objects carrying `audioTrackAsset` (nullable) | No free-form scenario IDs exist, so a "missing scenario" can only mean a missing or null asset | Tested at the asset level |
| Lifecycle | `ScreenPreviewHost` observer calls `handleAppLifecycle` | Testable through `binding.handleAppLifecycleStateChanged` | Reused |

## C. Failure and race-condition matrix

| Case | Result | Evidence |
|---|---|---|
| Double trigger during countdown | Rejected. One timer remains, the scenario is unchanged, and the ringtone starts once | Unit F; widget "double-tapping ARM" (snackbar shown) |
| Cancel 1 ms before the deadline | Cancel wins; no ringing | Unit E |
| Cancel and expiry at the same instant | Deterministic: whichever callback runs first wins. Expiry first means ringing, and the late cancel is ignored (the user can still decline). Cancel first means no ringing | Unit E (both orders) |
| Reset while an old countdown is pending | The stale timer can't ring the new session | Unit "Race conditions" |
| Hang-up during voice playback | Voice stops, timers stop, duration freezes | Unit I; widget "Active call screen" |
| Hang-up while voice start is in flight | Nothing plays and no state is left behind (**fixed**, D5) | Audio "Stale operations"; provider + AudioService test |
| Missing or invalid asset | Contained, no crash, next valid play works | Audio "Failures"; emulator logcat |
| Audio player throws (sync or async) | Contained inside the controller (**fixed**, D4) | Unit "Audio failures inside the controller" |
| Ringtone stop fails before voice | Voice is not started, to avoid overlap (**fixed**, D6) | Audio "Failures" |
| Disposal while active | Timers cancelled, no notifications, no audio started, no exceptions | Unit "Race conditions"; audio "dispose during in-flight voice start" |
| Lifecycle `paused`/`hidden`/`detached` | Countdown cancelled; ringing or active call reset; resume doesn't revive anything | Unit "Lifecycle policy"; widget lifecycle group; emulator |
| Lifecycle `inactive` only (notification shade) | Countdown continues and rings | Unit; widget; emulator |
| Decline during ringing | `stopAll`, ended screen showing 00:00 | Unit G; widget; emulator |
| Ringing timeout versus answer | Whichever is processed first wins; the other is ignored | Unit G |
| Automatic ringing timeout | **Not configured.** `handleRingingTimeout()` exists but nothing calls it, so ringing continues until answer or decline. No duration was invented | Unit G (documents the behavior) |
| Scenario auto-finish | **Not an agreed behavior.** The call stays active after the voice ends until hang-up. There is no completion listener, so no stale completion event exists | Code inspection |
| `returnToSetup()` outside the ended state | Ignored (**fixed**, D2) | Unit F |

## D. Audio operation ordering

At the player level, the real `AudioService` with fake players produces this order for ring → answer → hang-up:

```text
ringtone.setReleaseMode:loop → ringtone.play:audio/ringtone_ios.mp3
→ ringtone.stop → voice.setReleaseMode:stop → voice.play:audio/peer_mom.mp3
→ ringtone.stop → voice.stop
```

At the controller level, the recording fake produces:
- answered call: `playRingtone → stopAll → playPeerAudio:assets/audio/peer_mom.mp3`, then `stopAll` on hang-up
- declined call: `playRingtone → stopAll`

`stopAll` still stops the voice when the ringtone stop throws, and repeated `stopAll` calls are safe.

On the emulator (logcat, every cycle): `Ringtone triggered` → `Peer voice triggered` → `All audio tracks stopped` ×3 (answer, hang-up, return to setup).

## E. Device test matrix

The emulator ran a debug APK built from the final tree. Observations come from screenshots, UI-automator dumps and app logcat (`[CallProvider]`/`[AudioService]`). Audibility could not be judged because the assets don't exist.

| Scenario | Expected | Observed on emulator (API 37) | Emulator | Physical |
|---|---|---|---|---|
| App launch | Setup screen loads | Before D1: crash, `ClassNotFoundException: com.ghostbuster.app.MainActivity`. After D1: setup screen rendered | Pass (after fix) | Not Run |
| Countdown | Silent, counts down while in the foreground | 00:08 shown; no audio calls logged | Pass | Not Run |
| Ringing | Ringtone starts and loops | Incoming screen at 0 s; `Ringtone triggered`, then `Unable to load asset "assets/audio/ringtone_ios.mp3"` | **Blocked** (no asset); UI Pass | Not Run |
| Partial swipe | Does not answer | Still ringing after a 30% swipe | Pass | Not Run |
| Answer | Ringtone stops before voice | Full swipe → Connected; ordering as in D | Pass (logic) | Not Run |
| Voice playback | Selected voice audible | `Unable to load asset "assets/audio/peer_mom.mp3"` | **Blocked** (no asset) | Not Run |
| Simulated duration | Counts from 00:00 | 00:04 after 4 s (D3 fix confirmed) | Pass | Not Run |
| Hang-up | Voice stops; setup returns | Ended screen, then Return → setup; `All audio tracks stopped` | Pass | Not Run |
| Decline | Ringtone stops; resets | Ended screen showing `Riley Morgan · 00:00` → setup | Pass | Not Run |
| Repeated use | No stale playback | 3 consecutive answered cycles: exactly 1 ringtone start and 1 voice start each; 0 crashes in the crash buffer | Pass | Not Run |
| Volume / mute | Behavior understood | Not testable without audio assets | Blocked | Not Run |
| Audio interruption / incoming system call | Safe and documented | Not tested | Not Run | Not Run |
| Notification shade during countdown | `inactive` only; countdown continues | Rang on time after the shade was opened and closed | Pass | Not Run |
| HOME during countdown | Countdown cancelled (policy) | Resume → setup; no ringtone logged | Pass | Not Run |
| HOME during ringing | Audio stopped and reset | `All audio tracks stopped`; resume → setup | Pass | Not Run |
| HOME during active call | Voice stopped and reset | `All audio tracks stopped`; resume → setup | Pass | Not Run |
| **Screen sleep during countdown** | Documented policy | Screen timeout temporarily set to 15 s (restored afterwards). The screen slept about 15 s into a 30 s countdown, the app was paused, the **countdown was cancelled**, and no call came. See F1 | Matches the code; **product risk** | Not Run |
| Missing asset handling | Controlled, no crash | Both missing assets caught and logged; no crash | Pass | Not Run |

**iOS:** not verified, because a macOS/Xcode environment is required. **Web:** not tested in this phase.

## F. Known limitations and decisions needed

1. **Screen sleep cancels the countdown (decision needed).** The app doesn't keep the screen awake, and any `paused`/`hidden` event cancels the countdown by design (Phase 4 policy). With Android's usual 30 s–2 min screen timeouts, a 1–3 min countdown under the table will often be cancelled silently. The plan allows "prevent screen sleep where appropriate". Options:
   - (a) keep the screen on during countdown and ringing only. This needs a small dependency such as `wakelock_plus` or a native `FLAG_KEEP_SCREEN_ON`.
   - (b) document that users must keep the screen on.

   Not changed in this phase.
2. **No audio assets exist,** so ringtone and voice audibility, looping, volume, mute, routing and audio focus are unverified on any device.
3. **No physical device was tested.** Emulator results may differ from hardware, especially audio.
4. **Audio failure policy:** a failed ringtone or voice start is logged, and the visual call continues; decline, hang-up and reset still clean up. Nothing is surfaced to the user. Showing an error or ending the call instead would be a product decision.
5. **No automatic ringing timeout** and no auto-finish when the voice ends (both documented in C).
6. **Large text:** with real Roboto metrics, every screen fits 320×568 up to 1.5× text scale in en, tl and ceb. At 1.75×, setup overflows; at 2.0×, setup, countdown and ended overflow (measured by a temporary probe, since deleted). Not fixed.
7. **Background execution** is not supported: a foreground Dart timer stops when the app is paused, suspended or locked.
8. **Dev tooling:** the main manifest has no `INTERNET` permission and there is no debug manifest. Locally, `.gitignore`'s `[Dd]ebug/` rule would also ignore `android/app/src/debug/`. As a result:
   - the debug VM service can't open its socket (`SocketException ... Operation not permitted`), so `flutter run` hot reload and DevTools can't attach. Logcat and installed-APK testing work.
   - `CallEndedScreen` also calls `recordSession` on the backend server for every finished call. On device this fails silently (no permission and no reachable server). That call conflicts with the offline-first and no-telemetry principles; it was left unchanged for the Phase 12 decision.
9. **Emulator stability:** the first boot stalled because the host had only about 730 MB of free RAM for a 2 GB AVD. A cold boot with `-no-snapshot-load` worked.

## G. Fixes applied

| # | Defect (how confirmed) | Root cause | Fix | Regression test |
|---|---|---|---|---|
| D1 | App crashed on launch (emulator logcat) | `android/app/src/main/kotlin/com/ghostbuster/app/MainActivity.kt` was never committed, though the manifest references `.MainActivity` | Added the standard 5-line `class MainActivity : FlutterActivity()` | Emulator launch (no automated Android test) |
| D2 | `returnToSetup()` during countdown jumped to configuration while the timer kept running and rang later; during an active call it left the voice and timer running (failing test) | No state guard | Ignored unless the state is `ended` | `call_provider_timing_test` F |
| D3 | A live call showed a fake `00:18` at answer, and declined calls showed `00:18` on the ended screen (failing test) | The preview placeholder leaked into the provider-driven path | The live path shows `formattedElapsedTime`; the provider-less preview keeps its placeholder. Updated one assertion in `widget_test.dart` that had asserted the placeholder, with a justification comment | `call_flow_widget_test` (decline and active call) |
| D4 | An audio service that throws produced uncaught async errors, and a synchronous throw inside the countdown timer skipped the ringing notification (failing tests) | Fire-and-forget audio calls had no error handling | `_runAudio()` wraps every provider audio call with `Future.sync(...).catchError` and logs the failure | `call_provider_timing_test` "Audio failures", H |
| D5 | Hanging up while a voice start was in flight left `isVoicePlaying`/`currentAsset` set (failing test) | `playPeerAudio` set its flags after awaiting the ringtone stop without rechecking the generation | Re-check the generation and disposal after that await | `audio_service_ordering_test` "Stale operations" |
| D6 | The voice started even when the ringtone stop threw, risking overlap (failing test) | `stopRingtone` swallowed the error | `_stopRingtonePlayer()` reports failure, and `playPeerAudio` skips the voice if the ringtone may still be playing | `audio_service_ordering_test` "Failures" |
| D7 | Every ARM press called `startCountdown` twice; the second call was rejected harmlessly but logged (emulator logcat) | Both `StealthTriggerScreen` and the host callback started the countdown | The host callback no longer starts it | `call_flow_widget_test` (`startCalls == 1`) |

Files changed:
- `lib/providers/call_provider.dart` (D2, D4)
- `lib/services/audio_service.dart` (D5, D6)
- `lib/screens/screen_preview_host.dart` (D3, D7)
- `android/app/src/main/kotlin/com/ghostbuster/app/MainActivity.kt` (new, D1)
- `pubspec.yaml` and `pubspec.lock` (`fake_async` dev dependency)
- `test/widget_test.dart` (one assertion, D3)
- New tests and helpers listed in B

No screen layout or styling was changed.

## H. Phase 9 assessment

**Met:**
- unit, widget and audio-ordering coverage, including every required negative path
- deterministic timer tests
- repeated use without stale timers or players
- lifecycle tests
- analysis, the test suite and the debug build are green
- regression tests for all confirmed defects
- emulator results recorded separately

**Not met or blocked:**
- physical Android testing (no device)
- audible ringtone and voice checks (no approved assets)
- iOS and web

**Decisions needed before release:**
- F1 (screen sleep)
- F4 (audio failure feedback)
- F8 (session-recording network call and dev manifest)

Recommended next step: resolve F1 and stage approved assets (Phase 8), then repeat matrix E on a physical device. **Phase 10 — CI and Team Workflow has not been started.**
