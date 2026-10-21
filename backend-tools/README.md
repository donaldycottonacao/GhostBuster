# GhostBuster - Backend Audio Tools

Local Python tools for preparing voice audio before it is packaged into the Flutter app
(`frontend-client/`). **These are developer tools, not a server.** The shipped app plays
already-packaged audio files offline and never needs Python, a model, or the network.

---

## What actually works (verified)

| Tool | Status | What it really does |
|---|---|---|
| `scripts/text_to_speech.py` | **Implemented** | Local, offline TTS using voices already installed in Windows (SAPI5 via Windows PowerShell). WAV output only. No API key, no download, no extra packages. |
| `scripts/audio_validation.py` | **Implemented** | Objective checks of `.wav` (full analysis) and `.mp3` (header only). |
| `scripts/stage_asset.py` | **Implemented** | The only sanctioned way to copy a reviewed file into `frontend-client/assets/audio/`; needs human attestations. |
| `scripts/clone_peer.py` | **NOT implemented** | Validates consent flag / sample file / output location only. A real run exits with code 3 and produces nothing. No cloning model is installed. |

Not available: voice cloning, GPU inference. MP3 encoding is not built into the tools; use an
external ffmpeg (optional, see "Convert WAV to MP3").

---

## Requirements

- Windows 10/11 (speech generation uses Windows SAPI). Validation/staging/tests run on any OS.
- Python 3.10+ (verified with 3.11.9).
- Windows PowerShell 5.1 (`powershell.exe`, ships with Windows).
- **No third-party Python packages** (`requirements.txt` documents this; heavy ML libraries are deferred and commented out).
- No GPU, no model download, no network, no credentials. Disk use is negligible (a 3 s clip is ~135 KB).
- `.env.example` is **not consumed by any script** today; you do not need a `.env`.

## Setup (PowerShell, from the repository root)

```powershell
cd backend-tools
py -0p                       # confirm a Python 3.10+ is installed
py -3.11 -m venv .venv
.\.venv\Scripts\Activate.ps1
python --version
python -m pip install -r requirements.txt   # installs nothing extra
python -m pip check
```

If PowerShell blocks activation, do not change machine-wide policy. Use the venv's
interpreter directly instead, e.g. `.\.venv\Scripts\python.exe scripts\text_to_speech.py ...`.

## Directory layout and data separation

```text
backend-tools/
  voice_samples/   PRIVATE authorized input recordings   (git-ignored)
  output_assets/   UNREVIEWED generated audio            (git-ignored)
  scripts/         the tools
  tests/           unit tests
frontend-client/assets/audio/   APPROVED distributable assets only
```

Generation tools refuse to write into `frontend-client/assets/`. Files only get there through
`stage_asset.py`.

## Usage

### List installed voices
```powershell
python scripts/text_to_speech.py --list-voices
```

### Generate a sample (dry-run first)
```powershell
python scripts/text_to_speech.py --text "This is a short test." --voice-model Zira `
  --output-file output_assets/test_sample.wav --authorized-voice --dry-run
python scripts/text_to_speech.py --text "This is a short test." --voice-model Zira `
  --output-file output_assets/test_sample.wav --authorized-voice
```

| Flag | Meaning |
|---|---|
| `--text` | Required. Dialogue (max 1000 chars). Text is not echoed back; only its length is printed. |
| `--voice-model` | Installed Windows voice (case-insensitive substring). Default: system voice. |
| `--output-file` | `.wav` path. Default `backend-tools/output_assets/simulated_dialogue.wav`. `.mp3` is rejected with an explanation. |
| `--rate` | -10..10 speaking rate. |
| `--authorized-voice` | Required attestation that the voice is licensed/authorized. |
| `--overwrite` | Needed to replace an existing file. A failed run never clobbers an existing file. |
| `--dry-run` | Validates everything, writes nothing. |

Exit codes: `0` ok, `1` invalid input/policy, `4` generated audio failed validation,
`5` speech engine unavailable/failed. (argparse usage errors exit `2`.)

### Validate audio
```powershell
python scripts/audio_validation.py output_assets/test_sample.wav [--json]
```
Checks: readable header, format, sample rate/channels, duration (0.3-120 s), silence
(-45 dBFS windows), peak/clipping, leading/trailing silence, size. `.mp3` is header-only
(duration/clipping/silence are **not** verified). **These are objective checks; they cannot
tell you whether the voice is intelligible or sounds good. Listen to it.**

### Convert WAV to MP3 (optional, external ffmpeg)
The app's scenario mapping expects `.mp3` names. ffmpeg is **not** a Python dependency and is
not bundled; install it separately if you need MP3 (e.g. `winget install Gyan.FFmpeg`, then open
a new terminal). Verified with ffmpeg 9.0.2:
```powershell
ffmpeg -n -i output_assets/test_sample.wav -codec:a libmp3lame -q:a 2 output_assets/test_sample.mp3
```
- `-n` refuses to overwrite an existing file. Output stays in the private `output_assets/`.
- `-q:a 2` is high-quality VBR. MP3 is lossy; keep the WAV as the master copy until approval.
- Sample rate and channels are kept as-is (no resampling or normalization).
- `audio_validation.py` only checks MP3 headers. For a full check, decode to a temporary WAV
  and validate that:
  ```powershell
  ffmpeg -y -i output_assets/test_sample.mp3 $env:TEMP\roundtrip.wav
  python scripts/audio_validation.py $env:TEMP\roundtrip.wav
  Remove-Item $env:TEMP\roundtrip.wav
  ```

### Stage an approved asset for Flutter
```powershell
python scripts/stage_asset.py --source output_assets/peer_mom.mp3 --target-name peer_mom.mp3 `
  --approved-by "Your Name" --license-note "Original voice actor, written release on file" `
  --confirm-listened --dry-run
```
Refuses when: not listened-to, invalid audio, source in `voice_samples/`, extension mismatch
(no renaming WAV to MP3), target name not referenced by the Dart code, or file exists
(without `--overwrite`). It does not edit `pubspec.yaml` or run git.

### Voice cloning (`clone_peer.py`)
Not implemented. `--dry-run` only checks the self-declared `--authorized-consent` flag, the
sample file, and the output location. The flag is a self-declaration, not proof of consent.

## Approval workflow

1. Generate into `output_assets/` (dry-run first).
2. Run `audio_validation.py`; fix errors, review warnings.
3. **A human listens** and confirms intelligibility (the tools cannot do this).
4. Confirm license/consent (below) and record it in `docs/phase-8-voice-asset-tools.md`.
5. Run `stage_asset.py` with the exact filename the app expects (currently
   `assets/audio/peer_mom.mp3`, `peer_landlord.mp3`, `ringtone_ios.mp3`; see
   `frontend-client/lib/models/call_state.dart`, `lib/services/api_client.dart`,
   `lib/services/audio_service.dart`). The app expects **`.mp3`** names: convert with ffmpeg
   (above), supply an MP3 from an authorized source, or change the Flutter mapping deliberately
   (a separate, reviewed change).
6. `assets/audio/` is already registered in `pubspec.yaml` (directory entry), so no
   pubspec edit is needed. `.gitignore` ignores `assets/audio/*.mp3|wav` by default; add an
   explicit `!frontend-client/assets/audio/<file>` rule only for files approved to commit.
7. From `frontend-client/`: `flutter pub get`, `dart format lib test`, `flutter analyze`,
   `flutter test`, `flutter build apk --debug`, then verify on a device with airplane mode.

## Consent, licensing, storage, deletion

- **Never** clone or process a recognizable person's voice without their explicit, informed,
  written permission covering purpose, audience, storage, and public redistribution.
- Keep consent records and raw recordings **outside Git** (e.g. an access-controlled folder).
  Record who provided audio, purpose, where files live, and how the speaker can request
  deletion.
- Do not upload voice samples to any online service without the speaker's knowledge.
  `edge-tts` (commented out in `requirements.txt`) sends text to an online Microsoft service
  and is not offline.
- **Windows voices:** the licence terms allowing redistribution of their *output* inside a
  published app have **not been verified** here. Treat their output as private development
  audio until a human confirms the terms. An original voice actor or properly licensed voice
  pack is the safe choice for the release.
- Deletion: remove the speaker's files from `voice_samples/`, `output_assets/`, and
  `frontend-client/assets/audio/`; rebuild the app; if a file was ever committed, history
  rewriting needs an explicit team decision.
- Retention: delete `output_assets/` leftovers once approved assets are staged.

## Tests

```powershell
python -m unittest discover -s tests -v
```
All tests are offline and use mocks (no model/network/private audio). One optional integration
test uses real Windows SAPI: set `$env:GHOSTBUSTER_RUN_SAPI_TESTS = "1"` to enable it.

## Troubleshooting

- **`[ENGINE ERROR] ... only runs on Windows`**: speech generation needs Windows SAPI.
- **`Voice '...' is not installed`**: run `--list-voices` and use one of those names.
- **`[OUTPUT EXISTS]`**: choose a new path or pass `--overwrite`.
- **`[UNSUPPORTED FORMAT]` for mp3**: the tool writes WAV; convert with ffmpeg (see above).
- **`ffmpeg` not recognized**: install it separately and open a new terminal so PATH refreshes.
- **`[OUTPUT INVALID]`**: engine produced silent/corrupt audio; nothing was written.
- **PowerShell blocks `Activate.ps1`**: call `.\.venv\Scripts\python.exe` directly.

## Known limitations

- Only Windows' installed voices (US English on the verified machine); Filipino/Cebuano TTS
  voices were not available and were not tested.
- No built-in MP3 encoding (external ffmpeg only), no cloning, no loudness normalization or
  resampling.
- Listening/intelligibility checks are manual.
