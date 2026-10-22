# GhostBuster — Feature and UX Audit

Date: 2026-10-21 · Branch: `development` · Builds on the uncommitted Phase 9 work · Nothing committed or pushed.

## Summary

The core state machine and audio pipeline were sound after Phase 9. The main gaps were on the **setup screen**: several controls looked functional but changed nothing (caller card, ringtone menu, script language), and the user's setup was wiped after every call. On a real phone, **screen sleep silently cancelled the countdown**. The app UI was also locked to English, so the Tagalog and Cebuano translations never showed on a device.

All of these are fixed. The teammate's visual design is preserved: no colors, typography or layouts were redesigned. New UI uses the existing palette and components.

- Tests: **177/177 pass** (156 before this audit, 21 new).
- `flutter analyze`: no issues.
- `flutter build apk --debug`: passes.
- Every change was verified on the Android emulator (API 37). **No physical device** was available.

## 1. Missing or broken features found

| # | Finding | Evidence | Priority |
|---|---|---|---|
| F1 | Screen sleep during a countdown pauses the app, which cancels the countdown, so the call never comes | Phase 9 emulator test (15 s screen timeout, 30 s countdown) | **P1** |
| F2 | The caller card ("Riley Morgan" with a chevron) was hard-coded and not tappable. The provider supported 3 personas, but the UI could never select them | Source: `stealth_trigger.dart` | **P1** |
| F3 | The ringtone menu stored the choice in local widget state only; the call always used `ringtone_ios.mp3` | Source | **P1** |
| F4 | Script-language chips never reached the provider (`setScriptLanguage` was unused) | Source | P2 |
| F5 | Setup was lost after every call: "Return to setup" called `reset()`, which restored factory defaults, and the setup screen didn't read the provider. Lifecycle interruptions also used `reset()` | Source and new test | **P1** |
| F6 | App language was forced to English (`locale: currentLocale` defaulted to `en`, overriding device resolution). There was no in-app language picker, although `language`/`selectLanguage` strings existed | Source | **P1** |
| F7 | Copy was false or stale: "Preview only. No call is scheduled from this screen." (arming does schedule a call), and "Static countdown preview" on the live countdown | Screenshots | **P1** |
| F8 | No warning when audio files are missing; the call is silently mute. The plan requires that "the app … confirms required assets are present" | Emulator: `Unable to load asset` | **P1** |
| F9 | The active-call "Script" button only toggled its own highlight; the script card couldn't be hidden before showing the phone to someone | Source | P2 |
| F10 | Hard-coded English strings: "EMERGENCY SCRIPT", "Static countdown preview", "Preview incoming call screen" | Source | P2 |
| F11 | The incoming-call screen showed the caller name only, though personas have numbers. A real call screen normally shows the number | Source | P2 |

P0 items (launch crash, audio and timer leaks, races) were fixed in Phase 9; see `docs/phase-9-testing-and-device-reliability.md`.

## 2. UI/UX review by screen

| Screen | Problems | Changes made |
|---|---|---|
| Setup | Dead caller card and ringtone menu; misleading disclaimer; no language control; no audio warning; settings reset after each call | Tappable caller card opening a "Choose caller" sheet (name, relationship, voice badge, check mark, 64 px rows); working ringtone menu and language chips; language button (translate icon, tooltip) in the app bar; orange audio warning card (live region) above ARM; honest localized disclaimer; settings restored from the provider |
| Countdown | False "Static countdown preview" text; hard-coded English button; nothing told the user that leaving the app cancels the call | Localized hint: "Keep GhostBuster open. Leaving the app cancels the call."; localized ring-now button (English wording unchanged) |
| Incoming call | No caller number | Number shown under the name (muted, 17 pt), as call screens normally do; spacing adjusted so the layout height is unchanged |
| Active call | Script button did nothing; hard-coded title | Script button shows and hides the script card (its highlight reflects visibility; visible by default, as before); localized title |
| Call ended | Fixed in Phase 9 (real duration) | Returning keeps the setup |

Unchanged on purpose: colors, fonts, card styles, the slide-to-answer design, button placement, and the brand header.

Accessibility:
- The caller card is a labelled button.
- Picker rows are at least 64 px tall.
- The warning is a live region.
- Slide-to-answer keeps its "TAP TO ANSWER" button and semantic tap action.

The Phase 9 layout test now passes at **320×568 with 1.5× text** in en, tl and ceb, including the new warning card and app-bar button. It is measured with real Roboto metrics.

## 3. Prioritized backlog

| Priority | Item | Status |
|---|---|---|
| P0 | Launch crash, audio/timer races, duplicate trigger (Phase 9) | Done |
| P1 | F1 keep the screen on while a simulation runs | **Done** |
| P1 | F2 caller selection | **Done** |
| P1 | F3 ringtone selection wired to playback | **Done** |
| P1 | F5 keep the setup across calls and interruptions | **Done** |
| P1 | F6 follow the device language, plus an in-app picker | **Done** |
| P1 | F7 honest copy | **Done** |
| P1 | F8 missing-audio warning (non-blocking) | **Done** |
| P1 | Licensed ringtone and voice files | **Blocked:** needs approved assets (Phase 8) |
| P2 | F4, F9, F10, F11 | **Done** |
| P2 | Localize the English-only `Semantics` labels (e.g. "Decline call", "End Call") for tl/ceb screen readers | Open |
| P2 | Native-speaker review of the new Tagalog and Cebuano strings | Open |
| P2 | Large text: setup, countdown and ended screens overflow at 1.75× and above | Open |
| P3 | Persist settings across app restarts (needs a storage dependency such as `shared_preferences`) | Not started: dependency decision |
| P3 | Dim or black "stealth" countdown screen with a discreet double-tap trigger (shown in the UX diagram, not built) | Not started: design decision |
| P3 | Audio preview of the ringtone and voice on setup | Not started: no assets to preview |
| P3 | Automatic ringing timeout; auto-end when the voice finishes | Not started: no agreed duration or behavior |
| P3 | iOS keep-screen-on (`isIdleTimerDisabled`) | Not started: no macOS/Xcode to verify |

## 4. Implementation notes

**Keep screen on (F1).**
- `CallProvider` decides when the screen should stay on: during countdown, ringing and active call.
- It calls an injectable `ScreenWakeController` only when that value changes, and releases the screen on dispose.
- On Android, `MainActivity.kt` handles the `ghostbuster/screen` channel by setting or clearing `FLAG_KEEP_SCREEN_ON`. No new dependency.
- Other platforms throw `MissingPluginException`, which is logged once and ignored.
- The Phase 4 lifecycle policy is unchanged: pressing the power button or leaving the app still cancels.

**Caller and ringtone (F2, F3).**
- `CallerPersona.defaultPersonas` is reused as-is.
- New `RingtoneOption` map:

  | Option | Asset |
  |---|---|
  | `containment` (default) | `ringtone_ios.mp3` (the previous default) |
  | `classic` | `ringtone_android.mp3` (name from the project plan) |
  | `soft` | `ringtone_soft.mp3` (**new expected filename**; change it if you prefer another) |

- A missing file falls back safely.

**Setup persistence (F5).**
- "Return to setup" now uses the existing `returnToSetup()`, which keeps the configuration and repeats `stopAll` idempotently.
- Lifecycle interruptions use a new `_abortToConfiguration()`: everything stops, and the configuration is kept.
- `reset()` still restores factory defaults for error recovery; Phase 9 tests cover that.
- The setup screen initializes its fields from the provider.

**Language (F6).** MaterialApp gets `localeOverride`, which is `null` unless the user picks a language. With `null`, the existing resolution callback follows the device language and falls back to English. `currentLocale` keeps its old meaning for existing callers and tests.

**Audio readiness (F8).**
- `refreshAudioReadiness()` probes the selected ringtone and the persona's voice through an injectable `AssetProbe` (default: `rootBundle.load`).
- Stale probe results are discarded, and probe errors are contained.
- The warning never blocks arming, because the visual call still works.

## 5. Files changed

| File | Reason |
|---|---|
| `lib/models/call_state.dart` | `RingtoneOption`; `CallSession.ringtoneId` |
| `lib/providers/call_provider.dart` | Ringtone, readiness, locale override, keep-screen-on, config-preserving return and lifecycle abort |
| `lib/services/device_services.dart` (new) | `ScreenWakeController` (+ platform implementation), `AssetProbe` |
| `android/.../MainActivity.kt` | `ghostbuster/screen` channel (file created in Phase 9) |
| `lib/main.dart` | `locale: localeOverride` |
| `lib/screens/stealth_trigger.dart` | Caller picker, ringtone/language wiring, language button, audio warning, restore setup |
| `lib/screens/countdown_screen.dart` | Honest localized copy |
| `lib/screens/incoming_call_ui.dart` | Optional caller number |
| `lib/screens/active_call_ui.dart` | Working Script toggle; localized title |
| `lib/screens/screen_preview_host.dart` | Pass the number; return with `returnToSetup()` |
| `lib/widgets/call_screen_components.dart` | Script-card title parameter |
| `lib/l10n/app_{en,tl,ceb}.arb` + generated Dart | 11 new keys in all three locales; corrected `setupDisclaimer` |
| `test/feature_audit_test.dart` (new, 21 tests), `test/helpers/audio_fakes.dart` | Coverage for all of the above |

## 6. Test and build results (from `frontend-client/`)

| Command | Result |
|---|---|
| `flutter pub get` | PASS |
| `flutter gen-l10n` | PASS (key parity test passes) |
| `dart format lib test` | PASS (32 files) |
| `flutter analyze` | PASS (no issues) |
| `flutter test` | **PASS 177/177** |
| `flutter build apk --debug` | PASS |

**Emulator** (`sdk_gphone64_x86_64`, Android 17), installed debug APK, observed through screenshots, UI-automator dumps, `dumpsys` and logcat:
- **Screen sleep:** with the screen timeout temporarily set to 15 s, a 30 s countdown **rang**. Before this fix it was cancelled; the device stayed awake. The timeout was restored afterwards.
- **Screen flag:** `FLAG_KEEP_SCREEN_ON` was present during the countdown and cleared after cancel, decline or hang-up.
- **Audio warning:** shown, with both messages, because the assets are missing.
- **Caller picker:** listed 3 callers. After choosing the landlord, the incoming call showed "Landlord (Maintenance)" and "+1 (555) 876-5432", and `peer_landlord.mp3` was requested.
- **Script toggle:** hid the card.
- **Setup after a call:** the landlord was still selected after hang-up and return.
- **Language:** the picker switched the UI to Tagalog and back to the device language.
- **Crashes:** none in the crash buffer.

## 7. Remaining limitations and next steps

1. **No audio assets.** Ringing and the voice are silent everywhere; the warning now says so. Stage licensed MP3s at the paths in §4 (Phase 8 `stage_asset.py`).
2. **No physical Android device was tested.**
3. **Translations:** the new tl/ceb strings were written without native-speaker review.
4. **Decisions still open from Phase 9:**
   - whether a failed audio start should show an error during the call;
   - the backend calls to `generateScript` and `recordSession`, which send situation and session data to a server, conflicting with the offline-first and no-telemetry principles. They fail silently on Android because there is no `INTERNET` permission.
5. **Keep-screen-on is Android-only.** iOS behavior is unchanged and unverified.
6. **Settings don't survive an app restart** (P3).

Recommended next step: add approved audio assets, then repeat the device matrix on a physical Android phone. **Phase 10 (CI) has not been started.**
