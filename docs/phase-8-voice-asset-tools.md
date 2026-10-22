# GhostBuster — Phase 8: Local Python Voice-Asset Preparation Tools

Date: 2026-10-21 · Branch: `development` (up to date with `origin/development`) · Nothing committed or pushed.

## Summary

The committed `backend-tools/` scripts were **scaffolds that did not synthesize or clone anything**: `git show HEAD:` confirms `text_to_speech.py` and `clone_peer.py` only validated arguments and then printed `[SUCCESS] ... scaffold completed successfully.` with exit 0. The uncommitted Phase 8 work replaces that with honest behavior:

- `text_to_speech.py` performs real **local, offline** TTS through installed Windows SAPI voices. It needs no packages, no model download, and no network.
- `clone_peer.py` is documented as **not implemented** and enforces it (exit code 3).
- New `audio_validation.py` and `stage_asset.py` provide objective checks and a gated route into Flutter assets.
- **No asset has been staged into Flutter.** Nothing has been listened to by a human or approved under a license (see D).

A second verification pass (this revision) re-ran every claim. It corrected the earlier `.env` and ffmpeg statements and added a verified WAV→MP3 conversion step.

## A. Tool Audit

All proposed files exist. Extras: `tests/test_cli.py` (pre-existing, tracked) and the `.gitkeep` files. `backend-tools/.env` exists locally and is git-ignored and untracked. It has the same 9 keys with **identical values** to `.env.example` and contains no secrets. It is **not** byte-identical: it's an older copy with fewer comment lines. The earlier report was wrong about this. No script reads it.

| Tool | Exists | Actual functionality | Dependencies | Input | Output | HW / network |
|---|---|---|---|---|---|---|
| `text_to_speech.py` | Yes (modified) | HEAD: argument validation plus fake success (verified in source). Now: Windows SAPI synthesis (verified by execution) | stdlib + `powershell.exe` (System.Speech) | `--text`, installed voice name | `.wav` only (`.mp3` rejected with explanation) | CPU only, offline |
| `clone_peer.py` | Yes (modified) | HEAD: validation plus fake success. Now: validation only; a real run prints `NOT IMPLEMENTED` and exits 3 (verified by execution and test) | stdlib | sample file | none | none |
| `audio_validation.py` | New | Full WAV analysis; MP3 header only (verified by tests and execution) | stdlib | `.wav`/`.mp3` | report / exit code | none |
| `stage_asset.py` | New | Gated copy to `frontend-client/assets/audio/` (verified by tests and dry run against the real `lib/`) | stdlib | reviewed file + attestations | copied asset | none |
| ffmpeg (external) | Installed via winget | WAV→MP3 conversion and decode round-trip (verified by execution) | not a Python dependency | `.wav` | `.mp3` | offline |

Capability labels:
- **Verified by execution:** SAPI TTS, WAV validation, ffmpeg MP3 conversion.
- **Missing:** MP3 duration, clipping and silence checks inside `audio_validation.py` (header only). The workaround is a decode round-trip.
- **Not implemented:** voice cloning, GPU inference.

Text and voice values are passed to PowerShell through environment variables, never interpolated into the command string, so dialogue text cannot inject commands. Only the text *length* is printed.

## B. Environment

- `py -0p`: only Python 3.11.9 is installed. The venv at `backend-tools/.venv` resolves `sys.prefix` to the venv, not the global install. pip 24.0. `pip list`: only `pip` and `setuptools`. `pip check`: "No broken requirements found."
- `requirements.txt` installs nothing; no third-party packages are needed. pip was **not** upgraded (a newer version, 26.2.2, is available; not required).
- Models and hardware: none required. Installed SAPI voices: Microsoft David Desktop and Microsoft Zira Desktop (both en-US). **No Filipino or Cebuano voice** is installed.
- ffmpeg 9.0.2 (gyan.dev full build) is on PATH via winget. It's optional and only needed to produce `.mp3`.
- Licensing: Microsoft's terms for redistributing SAPI voice *output* inside a published app were **not verified**, so the status is **License unknown**. ffmpeg's licence covers the tool, not the audio it produces.
- Heavy frameworks (torch, Coqui TTS, edge-tts) were deliberately **not installed** and remain commented out. `edge-tts` is flagged as an online service, not offline.

## C. Sample Generation

Command (PowerShell, from `backend-tools/`):

```powershell
.\.venv\Scripts\python.exe scripts/text_to_speech.py --text "This is a short GhostBuster test sample." `
  --voice-model Zira --output-file output_assets/test_sample.wav --authorized-voice
ffmpeg -n -i output_assets/test_sample.wav -codec:a libmp3lame -q:a 2 output_assets/test_sample.mp3
```

Outputs (both git-ignored; the text isn't sensitive and contains no personal voice data):

| Check | `test_sample.wav` | `test_sample.mp3` |
|---|---|---|
| Size | 135,824 B | 26,184 B |
| Format / header | WAV PCM, readable | MP3 (ffprobe: `codec_name=mp3`) |
| Rate / channels / bits | 22,050 Hz, mono, 16-bit | 22,050 Hz, mono, ~68 kbps VBR |
| Duration | 3.079 s | 3.079 s (ffprobe) |
| Peak / RMS | 0.599 / 0.082, clipped ratio 0.0 | 0.5995 / 0.0818 after decode round-trip |
| Active (non-silent) ratio | 0.656 | 0.656 (round-trip) |
| Leading / trailing silence | 0.12 s / 0.74 s (under warning thresholds) | same (round-trip) |
| **Human listening / intelligibility** | **NOT performed** | **NOT performed** |
| Played through Flutter `AudioService` | Not done | Not done (not staged; no Android device) |

The objective checks show an audible, non-clipped signal shaped like speech. They don't show that it's intelligible. A developer must listen to `output_assets/test_sample.wav` or `.mp3`.

Failure paths verified by execution in this pass:

| Case | Result |
|---|---|
| Dry run | exit 0, no file written |
| Existing output without `--overwrite` | `[OUTPUT EXISTS]`, exit 1 |
| `.mp3` output requested | `[UNSUPPORTED FORMAT]`, exit 1 |
| Missing `--authorized-voice` | `[ETHICS & LICENSING ERROR]`, exit 1 |
| Unknown voice | `[VOICE ERROR]` listing the installed voices, exit 1 |
| `clone_peer.py` real run | `NOT IMPLEMENTED`, exit 3, output dir not created |
| Staging `peer_mom.wav` (not referenced in Dart) | refused, exit 1 |
| Optional real-SAPI test (`GHOSTBUSTER_RUN_SAPI_TESTS=1`) | OK (2.104 s clip generated in a temp dir) |

## D. Asset Approval and Staging

- Approved assets: **none**. Nothing was copied to `frontend-client/assets/audio/`, which still contains only `README.md`.
- Names the app expects: `assets/audio/peer_mom.mp3` and `peer_landlord.mp3` (`lib/models/call_state.dart`, `lib/services/api_client.dart`), plus `ringtone_ios.mp3` (`lib/services/audio_service.dart`). The audio package is `audioplayers ^6.8.1`.
- MP3 production is **no longer a tooling blocker**: ffmpeg conversion works (C).
- Still required before staging: a human listening check, and a licence decision. That means either confirming that Windows-voice output may be redistributed, or using an original voice actor or a licensed voice pack.
- `pubspec.yaml` is unchanged; `assets/audio/` is already registered as a directory.
- Staging command, to run **only after approval**:

  ```powershell
  .\.venv\Scripts\python.exe scripts/stage_asset.py --source output_assets/<reviewed>.mp3 `
    --target-name peer_mom.mp3 --approved-by "<name>" --license-note "<basis>" --confirm-listened
  ```

## E. Flutter Integration (no Flutter source changes this phase)

Flutter 3.47.7 (stable), from `frontend-client/`:

| Step | Result |
|---|---|
| `flutter pub get` | PASS (6 packages have newer versions that the current constraints don't allow; unchanged) |
| `dart format --output=none --set-exit-if-changed lib test` | PASS (25 files, 0 changed) |
| `flutter analyze` | PASS (no issues) |
| `flutter test` | PASS (69/69) |
| `flutter build apk --debug` | PASS (`build\app\outputs\flutter-apk\app-debug.apk`, 45.8 s) |
| Offline playback on device | **UNVERIFIED.** `flutter devices` lists only Windows, Chrome and Edge, with no Android device or emulator. No real audio asset is staged. |

## F. Privacy and Repository Hygiene

- Ignored (verified with `git check-ignore -v`): `backend-tools/voice_samples/*`, `backend-tools/output_assets/*` (including `test_sample.wav` and `.mp3`), `backend-tools/.venv/`, `backend-tools/models/`, model-weight extensions, `backend-tools/.env`, `__pycache__/`.
- Not ignored (verified): `.env.example`, all four scripts, `tests/test_tools.py`, `requirements.txt`, this report.
- Added to `.gitignore` this phase: `backend-tools/.venv/`, `*.partial.wav`, model weights (`*.pt, *.pth, *.ckpt, *.onnx, *.safetensors`) and `backend-tools/models/`.
- Already-tracked private material: **none**. `git ls-files backend-tools frontend-client/assets` shows only scripts, tests, READMEs, requirements, `.env.example` and `.gitkeep`.
- `frontend-client/assets/audio/*.mp3|wav` stay git-ignored by default. Approved files need an explicit `!` rule.
- `git diff --check`: no whitespace errors (only CRLF normalization notices).
- `.env.example` is tracked but no script uses it. It's labelled as such rather than deleted; whether to remove it is your call.

## Tests (backend-tools)

`.\.venv\Scripts\python.exe -m unittest discover -s tests -v` → **43 tests, OK (1 skipped)**:
- 4 pre-existing CLI tests
- audio validation (13)
- TTS validation and failure handling with a mocked engine (15)
- `clone_peer` not-implemented and dry-run (2)
- staging safeguards (9)

The skipped test is the optional real-SAPI integration test. It passed when run explicitly (see C). No test needs network access, models, a GPU or private audio.

## G. Remaining Blockers / Decisions

1. **Human listening** to `test_sample.wav`/`.mp3` hasn't been done.
2. **Release voice source and licensing** are undecided. Whether Windows-voice output can be redistributed is unverified.
3. **Voice cloning** is not implemented, and there is no authorized peer recording or model. Starting that work needs a separate decision covering consent records, model licence and hardware.
4. **Filipino and Cebuano speech** aren't available from the installed voices.
5. **Offline playback on Android** is unverified (no device or emulator).
6. `stage_asset.py` attestations are self-declarations, not proof.
7. ffmpeg is a manual, machine-level install. Another developer has to install it separately to produce MP3s.

## H. Recommended Next Step

Resolve G1 and G2 (listen, then decide the licensed voice source). Then stage the approved MP3s with `stage_asset.py` and verify on an Android device. After that, proceed to **Phase 9 — Automated Tests and Physical-Device Reliability** (not started).
