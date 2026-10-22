# GhostBuster — Phase 3: Codebase Audit and Implementation Design

## 1. Repository & Build Baseline Status

- **Repository Root**: `c:\Development Project Files\GITHUD CLONE FILES\GhostBuster`
- **Flutter Directory**: `frontend-client/`
- **Git Branch**: `development` (synchronized with `origin/development`, clean working tree)
- **Baseline Verification**:
  - `flutter pub get`: **PASS** (Exit code 0)
  - `flutter analyze`: **PASS** (**0 errors, 0 warnings, 0 issues found**)
  - `flutter test`: **PASS** (**9/9 tests passed**)
  - `flutter build apk --debug`: **PASS** (`app-debug.apk` verified, 171.9 MB)

---

## 2. Source-Code Structure & File Inventory

The `frontend-client/lib/` directory contains 22 files organized into clean domain layers:

| File / Path | Exists? | Actual Responsibility | Key Classes / Symbols | Condition |
|---|---|---|---|---|
| [`lib/main.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/main.dart) | Yes | Application entrypoint, system UI configuration, Theme setup, `ChangeNotifierProvider<CallProvider>` root injection. | `GhostBusterApp`, `main()` | **Working** |
| [`lib/models/call_state.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/models/call_state.dart) | Yes | Domain models for call lifecycle states, caller personas, and call session state. | `CallLifecycleState`, `CallerPersona`, `CallSession` | **Working** |
| [`lib/models/api_models.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/models/api_models.dart) | Yes | Data transfer objects matching backend schemas with JSON serialization. | `HealthStatusModel`, `PersonaModel`, `EscapeScriptRequestModel`, `EscapeSessionRecordModel` | **Working** |
| [`lib/providers/call_provider.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/providers/call_provider.dart) | Yes | Centralized ChangeNotifier state machine managing timers, audio triggers, locale, and lifecycle transitions. | `CallProvider` | **Working** |
| [`lib/services/audio_service.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/services/audio_service.dart) | Yes | Audio service interface and safe fallback implementation preventing runtime crashes when audio files are absent. | `AudioServiceBase`, `AudioService` | **Working / Partial** (Safe mode active; audio player hardware bridge ready for P2) |
| [`lib/services/api_client.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/services/api_client.dart) | Yes | Resilient HTTP API client with platform host resolution (`10.0.2.2` vs `127.0.0.1`) and offline fallback. | `GhostBusterApiClient` | **Working** |
| [`lib/screens/stealth_trigger.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/screens/stealth_trigger.dart) | Yes | Main escape setup UI: quick trigger presets, delay selector (10s–3m), persona cards, AI dialogue input, language picker. | `StealthTriggerScreen` | **Working** |
| [`lib/screens/countdown_screen.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/screens/countdown_screen.dart) | Yes | Silent countdown screen with circular progress bar, timer display, cancel button, and preview controls. | `CountdownScreen` | **Working / Partial** (Static delay preview; needs live countdown binding) |
| [`lib/screens/incoming_call_ui.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/screens/incoming_call_ui.dart) | Yes | Hyper-realistic incoming call screen with animated caller avatar, slide-to-answer gesture, and decline action. | `IncomingCallScreen` | **Working / Partial** (Hardcoded name; needs persona binding) |
| [`lib/screens/active_call_ui.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/screens/active_call_ui.dart) | Yes | Ongoing call screen with emergency script prompt, dial pad, mute/speaker toggles, and end call button. | `ActiveCallScreen` | **Working / Partial** (Hardcoded '00:18'; needs live elapsed timer binding) |
| [`lib/screens/call_ended_screen.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/screens/call_ended_screen.dart) | Yes | Post-call summary screen logging escape telemetry and returning user to configuration. | `CallEndedScreen` | **Working** |
| [`lib/screens/screen_preview_host.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/screens/screen_preview_host.dart) | Yes | Host container switching screens via local state callbacks. | `ScreenPreviewHost` | **Working / Partial** (Manual callback switcher; needs binding to `CallProvider`) |
| [`lib/widgets/call_screen_components.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/widgets/call_screen_components.dart) | Yes | Shared design tokens, caller avatar widget, emergency script card. | `CallAvatar`, `EmergencyScriptCard` | **Working** |
| [`lib/widgets/slide_button.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/widgets/slide_button.dart) | Yes | Custom drag-to-slide interactive button with spring reset. | `SlideButton` | **Working** |
| [`lib/widgets/dial_pad_button.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/widgets/dial_pad_button.dart) | Yes | Circular phone keypad button. | `DialPadButton` | **Working** |
| [`lib/l10n/`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/l10n) | Yes | ARB source files and generated Dart localization classes for English, Tagalog, and Cebuano. | `AppLocalizations`, delegates | **Working** |
| [`test/widget_test.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/test/widget_test.dart) | Yes | Automated widget pump and flow tests. | Widget flow test cases | **Working** |
| [`test/api_client_test.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/test/api_client_test.dart) | Yes | Unit tests for API client parsing and offline fallbacks. | API client test cases | **Working** |

---

## 3. State-Management and Timer Inventory

### State Management Mechanism
- The project strictly utilizes **Provider** (`package:provider`, `^6.1.2`).
- Single state controller: `CallProvider` extends `ChangeNotifier`.
- Single domain model: `CallSession` in `call_state.dart`.
- Root consumer: `Consumer<CallProvider>` in `main.dart`.
- **Finding**: There are no duplicate or competing state-management libraries (no Riverpod, Bloc, or Redux). The state architecture is clean and unified.

### Timer Ownership and Lifecycle
- **Countdown Timer**: Owned exclusively by `CallProvider._countdownTimer` (`Timer.periodic(const Duration(seconds: 1), ...)`).
  - Started via `startCountdown({VoidCallback? onTriggered})`.
  - Cancelled via `cancelCountdown()` or `dispose()`.
  - Guards: `_canEditConfiguration` check prevents duplicate triggers while a countdown is already running.
- **Call Duration Timer**: Owned exclusively by `CallProvider._elapsedTimer` (`Timer.periodic(const Duration(seconds: 1), ...)`).
  - Started via `answerCall()`.
  - Cancelled via `declineCall()`, `endCall()`, or `dispose()`.
- **Disposal & Safety**:
  - `CallProvider.dispose()` cancels all active timers (`_countdownTimer?.cancel()`, `_elapsedTimer?.cancel()`) and stops all audio streams via `_audioService.stopAll()`.

### Identified Architectural Gap
In the teammate's current implementation:
1. `ScreenPreviewHost` maintains an internal `_page = _PreviewPage.setup` state with manual callback transitions (`_showPage`).
2. `CountdownScreen` accepts `final int delaySeconds` and renders static `_staticTime`, rather than reading `callProvider.remainingCountdown`.
3. `ActiveCallScreen` renders hardcoded `'00:18'` rather than reading `callProvider.formattedElapsedTime`.
4. `IncomingCallScreen` renders hardcoded `'Riley Morgan'` rather than `callProvider.persona.name`.

**Recommendation**: Connect `ScreenPreviewHost` and the child screens to `CallProvider` so that timer ticks, ringing triggers, and elapsed durations update dynamically while preserving the exact layout and callbacks.

---

## 4. Audio Service and Player Lifecycle

### Existing Audio Architecture
- Abstract Contract: `AudioServiceBase` in [`audio_service.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/services/audio_service.dart).
- Concrete Implementation: `AudioService` singleton.
- Methods:
  - `initialize()`: Sets up audio session.
  - `playRingtone({String? assetPath})`: Triggers simulated ringtone (`assets/audio/ringtone_ios.mp3`).
  - `playPeerAudio(String assetPath)`: Triggers dialogue track.
  - `stopAll()`: Halts playback and resets state.
- **Current Behavior**: Currently operates in "Safe Mode" with debug logging, ensuring zero crashes even when optional audio binaries are absent from disk.
- **Sequencing Invariant**: `CallProvider.answerCall()` invokes `_audioService.stopAll()` before initiating peer voice playback, guaranteeing the ringtone stops before speech begins.

---

## 5. Screen-to-State Mapping

| UX Step | Existing Screen / Widget | `CallLifecycleState` | Trigger Event / User Gesture | Handler in Code | Target State |
|---|---|---|---|---|---|
| **01. Hidden Trigger** | [`StealthTriggerScreen`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/screens/stealth_trigger.dart) | `configuration` | Double-tap / Quick trigger tap | `callProvider.startCountdown()` | `countdown` |
| **02. Quiet Cooldown** | [`CountdownScreen`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/screens/countdown_screen.dart) | `countdown` | Cancel button tapped | `callProvider.cancelCountdown()` | `configuration` |
| **02. Cooldown Complete** | [`CountdownScreen`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/screens/countdown_screen.dart) | `countdown` | Timer reaches zero | `onTriggered` callback | `ringing` |
| **03. Ringing** | [`IncomingCallScreen`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/screens/incoming_call_ui.dart) | `ringing` | Slide-to-answer completed | `callProvider.answerCall()` | `active` |
| **03. Decline / Timeout** | [`IncomingCallScreen`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/screens/incoming_call_ui.dart) | `ringing` | Decline button tapped | `callProvider.declineCall()` | `ended` |
| **04. Answering Phase** | [`ActiveCallScreen`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/screens/active_call_ui.dart) | `active` | End Call button tapped | `callProvider.endCall()` | `ended` / `configuration` |
| **05. Tactical Escape** | [`CallEndedScreen`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/screens/call_ended_screen.dart) | `ended` | Return to Setup tapped | `onReturnToSetup` | `configuration` |

---

## 6. Transition-by-Transition Gap Analysis

| Starting State | Event / Guard | Expected Behavior | Implementation Status | Confirmed Gap / Action Needed |
|---|---|---|---|---|
| `configuration` | Trigger activated with valid delay | Store scenario; arm single silent timer | **Implemented** | Connect `StealthTriggerScreen` directly to `callProvider.startCountdown()`. |
| `countdown` | 1-second tick | Decrement remaining time silently | **Implemented** | Pass `callProvider.remainingCountdown` to `CountdownScreen` so display counts down live. |
| `countdown` | Timer reaches zero | Cancel timer, start ringtone, show incoming screen | **Implemented** | Transition `_page` to `incoming` automatically when `CallProvider` state becomes `ringing`. |
| `countdown` | User cancels | Cancel timer, reset pending state, return to setup | **Implemented** | Invokes `callProvider.cancelCountdown()`. Clean. |
| `ringing` | Slide-to-answer | Stop ringtone before starting voice audio; start elapsed timer | **Implemented** | Invokes `callProvider.answerCall()`. Audio sequencing verified. |
| `ringing` | User declines / timeout | Stop ringtone, clear timers, transition to ended/setup | **Implemented** | Invokes `callProvider.declineCall()`. |
| `active` | User hangs up | Stop voice playback and timer; transition to ended screen | **Implemented** | Invokes `callProvider.endCall()`. Elapsed time logged. |
| Any state | Dispose / Error | Stop all timers and audio; reset transient state | **Implemented** | `CallProvider.dispose()` cleans up cleanly. |

---

## 7. Assets, Localization, and Dependencies Inventory

### Assets
- Registered in `pubspec.yaml`:
  - `assets/audio/`
  - `assets/fonts/`
- Verified on disk:
  - `assets/audio/README.md`
  - `assets/fonts/README.md`
- **Audio binary status**: MP3 files (`ringtone_ios.mp3`, `ringtone_android.mp3`, `peer_mom.mp3`, `peer_landlord.mp3`) are optional and excluded from Git via `.gitignore`. The app contains safe fallbacks in `AudioService` so missing audio files do not cause runtime errors.

### Localization
- Configuration: `l10n.yaml` (`template-arb-file: app_en.arb`, `output-localization-file: app_localizations.dart`).
- Sources:
  - `lib/l10n/app_en.arb` (English, 28 keys)
  - `lib/l10n/app_tl.arb` (Tagalog, 28 keys)
  - `lib/l10n/app_ceb.arb` (Cebuano/Bisaya, 28 keys)
- Generated: `app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_tl.dart`, `app_localizations_ceb.dart`.
- Condition: 100% synchronized and verified across all 3 languages.

### Dependencies
- `provider: ^6.1.2` (State management) — **In use & required**
- `intl: any` (Localization) — **In use & required**
- `audioplayers: ^6.8.1` (Audio playback) — **In use & required**
- `http: ^1.2.0` (API communication) — **In use & required**
- `cupertino_icons: ^1.0.8` (Icons) — **In use & required**
- `path_provider_android: 2.2.15` (Dependency override) — **Required to eliminate NDK toolchain dependency**

---

## 8. Python Voice Tooling and Backend Scope (ADR)

### Architecture Decision Record: Offline-First MVP

1. **Context**:
   - `backend-tools/` contains standalone Python CLI scripts (`clone_peer.py`, `text_to_speech.py`) for offline audio asset preparation on a developer workstation.
   - GhostBuster's core mission is an emergency/escape simulation that must function reliably in low-connectivity or offline environments (e.g., basements, airplanes, remote venues).
2. **Decision**:
   - The primary application MVP is strictly **offline-first**.
   - No remote server or internet connection is required to arm, trigger, ring, answer, or conclude a simulated call.
   - Any backend integration (such as the optional `backend-server/` FastAPI service) acts strictly as an enhancement (remote AI script generation, persona backup, session telemetry) with immediate local fallbacks when unreachable.
3. **Ethics and Consent Gate**:
   - Both `clone_peer.py` and `text_to_speech.py` enforce explicit consent parameters (`--authorized-consent`, `--authorized-voice`).
   - Personal voice recordings and model weights are strictly git-ignored (`voice_samples/`, `output_assets/`).

---

## 9. Proposed Target Architecture

```text
+-------------------------------------------------------------+
|                      Flutter Presentation                   |
|  StealthTriggerScreen -> CountdownScreen -> IncomingScreen  |
|            -> ActiveCallScreen -> CallEndedScreen           |
+-------------------------------------------------------------+
                               |
                               v
+-------------------------------------------------------------+
|                     CallProvider (State)                    |
|  - CallLifecycleState: config -> countdown -> ringing       |
|                       -> active -> ended                    |
|  - Countdown Timer (1s periodic)                            |
|  - Active Elapsed Timer (1s periodic)                       |
|  - Current Locale (en / tl / ceb)                           |
+-------------------------------------------------------------+
          |                                       |
          v                                       v
+-----------------------+              +----------------------+
|     AudioService      |              |   GhostBusterApiClient|
| - playRingtone()      |              | - checkHealth()      |
| - playPeerAudio()     |              | - generateScript()   |
| - stopAll()           |              | - recordSession()    |
| (Safe fallback mode)  |              | (Offline resilient)  |
+-----------------------+              +----------------------+
          |                                       |
          v                                       v
+-----------------------+              +----------------------+
|  Local Audio Assets   |              | Local Offline Backup |
| (ringtone / dialogue) |              |  (Cached Templates)  |
+-----------------------+              +----------------------+
```

---

## 10. File-by-File Implementation Plan

| File | Current Condition | Recommended Action | Priority |
|---|---|---|---|
| [`lib/screens/screen_preview_host.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/screens/screen_preview_host.dart) | Manual callback page switcher | Connect `ScreenPreviewHost` to `CallProvider` state so automatic timer triggers switch pages seamlessly. | **P1** |
| [`lib/screens/countdown_screen.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/screens/countdown_screen.dart) | Displays static delay | Bind countdown display to `CallProvider.remainingCountdown` for live ticking countdown. | **P1** |
| [`lib/screens/active_call_ui.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/screens/active_call_ui.dart) | Hardcoded '00:18' | Bind active timer to `CallProvider.formattedElapsedTime`. | **P1** |
| [`lib/screens/incoming_call_ui.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/screens/incoming_call_ui.dart) | Hardcoded 'Riley Morgan' | Bind caller name to `CallProvider.persona.name`. | **P2** |
| [`lib/services/audio_service.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/lib/services/audio_service.dart) | Safe simulated mode | Bridge to `audioplayers` with fallback if assets are not on disk. | **P2** |
| [`test/widget_test.dart`](file:///c:/Development%20Project%20Files/GITHUD%20CLONE%20FILES/GhostBuster/frontend-client/test/widget_test.dart) | 3 tests passing | Expand unit and widget tests covering all 8 transition table rows. | **P3** |

---

## 11. Prioritized Implementation Backlog

- **P0: Build & Analysis Baseline**
  - Status: **Complete & Verified** (0 errors, 9/9 tests pass, debug APK built).
- **P1: State Machine & Screen Wiring**
  - Task P1.1: Wire `CallProvider` state directly into `ScreenPreviewHost` so state transitions trigger screen changes automatically.
  - Task P1.2: Connect `CountdownScreen` to dynamic `remainingCountdown`.
  - Task P1.3: Connect `ActiveCallScreen` to dynamic `formattedElapsedTime`.
- **P2: Audio Service Hardware Integration**
  - Task P2.1: Implement `AudioPlayer` ringtone loop and peer voice playback in `AudioService` with safe asset existence checks.
  - Task P2.2: Verify audio lifecycle cleanup on call decline and hang-up.
- **P3: UI & Persona Polish**
  - Task P3.1: Pass dynamic persona details (Mom, Landlord, Boss) into `IncomingCallScreen` and `ActiveCallScreen`.
  - Task P3.2: Verify trilingual string rendering in all screens.
- **P4: Comprehensive Test Suite & Documentation**
  - Task P4.1: Add unit tests verifying each row of the state transition table.
  - Task P4.2: Finalize CI workflow and deployment documentation.

---

## 12. Phase 3 Exit-Criteria Assessment

- [x] Actual source tree inspected directly.
- [x] Each relevant file has a documented responsibility.
- [x] State management and timer ownership clearly mapped.
- [x] Audio service lifecycle and fallback behavior analyzed.
- [x] Screen-to-state map established.
- [x] Transition-by-transition gaps documented.
- [x] Assets and localization resources verified.
- [x] Local Python tooling and offline MVP scope defined.
- [x] Architecture design reuses existing components without unnecessary rewrites.
- [x] Implementation backlog prioritized (P0–P4).
- [x] Audit report documented in `docs/phase-3-codebase-audit.md`.
- [x] No unapproved application source changes made.
