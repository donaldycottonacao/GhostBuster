# GhostBuster 👻

> An open-source, mobile-responsive Flutter web/native application designed to orchestrate tactical social escapes using hyper-realistic UI cloning, automated local state hooks, and custom-baked cloned AI peer voices. Completely free, offline-first, and highly petty.

---

## 1. Project Overview

**GhostBuster** provides users with an offline, hyper-realistic escape call mechanism to tactfully exit awkward social scenarios, meetings, or encounters. The system pairs a cross-platform Flutter frontend (simulating incoming call screens, slide-to-answer gestures, and active call timers) with modular Python backend tools (scaffolding voice cloning and text-to-speech dialogue generation).

### Key Architectural Tenets
- **Offline-First & Private**: Runs entirely locally on-device without remote telephony routing.
- **Explicitly Consensual**: Voice cloning and audio generation require documented speaker authorization.
- **Cross-Platform**: Targets Android, iOS, and Web from a single Flutter codebase.
- **Modular Scaffolding**: Separate boundaries for frontend UI, state models, audio playback services, and Python audio pipelines.

---

## 2. Directory Tree

```text
ghostbuster/
│
├── .github/
│   └── workflows/
│       └── flutter-ci.yml        # GitHub Actions CI for Flutter & Python validation
│
├── backend-tools/
│   ├── README.md                 # Backend audio tools guide & CLI documentation
│   ├── requirements.txt          # Python dependencies (lightweight core + deferred ML)
│   ├── scripts/
│   │   ├── clone_peer.py         # Consensual voice sample processing scaffold
│   │   └── text_to_speech.py     # Authorized dialogue synthesis scaffold
│   ├── voice_samples/
│   │   └── .gitkeep              # Input directory for approved audio samples (git-ignored)
│   └── output_assets/
│       └── .gitkeep              # Output directory for generated audio files (git-ignored)
│
├── frontend-client/
│   ├── android/                  # Android platform scaffolding & manifests
│   ├── ios/                      # iOS platform scaffolding & runner config
│   ├── web/                      # Web platform scaffolding & manifest
│   │
│   ├── assets/
│   │   ├── audio/
│   │   │   └── README.md         # Guide for optional ringtones & dialogue audio
│   │   └── fonts/
│   │       └── README.md         # Guide for optional custom typography (SF Pro / Inter)
│   │
│   ├── lib/
│   │   ├── main.dart             # Application entry point & theme definition
│   │   ├── models/
│   │   │   └── call_state.dart   # Call lifecycle enum & session models
│   │   ├── services/
│   │   │   └── audio_service.dart# Audio playback service interface & safe fallback
│   │   ├── screens/
│   │   │   ├── stealth_trigger.dart   # Escape trigger configuration & countdown
│   │   │   ├── incoming_call_ui.dart  # Simulated incoming call UI
│   │   │   └── active_call_ui.dart    # Simulated active call screen & timer
│   │   └── widgets/
│   │       ├── slide_button.dart      # Reusable gesture-slider widget
│   │       └── dial_pad_button.dart   # Reusable keypad-button widget
│   │
│   ├── test/
│   │   └── widget_test.dart      # Flutter widget verification tests
│   ├── pubspec.yaml              # Flutter project configuration & asset registration
│   └── README.md                 # Frontend documentation
│
├── .gitignore                    # Git ignore rules for Flutter, Dart, Python, & media
├── LICENSE                       # MIT License
└── README.md                     # Root project documentation
```

---

## 3. Technology Stack

- **Frontend**: Flutter (3.24+ / 3.29+), Dart (3.0+), Material 3, Cupertino Icons.
- **Backend / Tooling**: Python 3.10+, Standard Library CLI (`argparse`), pip.
- **CI / Automation**: GitHub Actions (`subosito/flutter-action`, `actions/setup-python`).
- **Platforms**: Android (API 21+), iOS (iOS 12+), Web (Modern Chromium, Safari, Firefox).

---

## 4. Prerequisites

1. **Flutter SDK**: [Install Flutter SDK](https://docs.flutter.dev/get-started/install) (ensure `flutter` and `dart` are available on your `PATH`).
2. **Python**: Python 3.10 or 3.11 with `pip`.
3. **Platform Tooling**:
   - For Android: Android Studio with Android SDK and command-line tools.
   - For iOS: Xcode (macOS only) and CocoaPods.
   - For Web: Google Chrome or Microsoft Edge.
4. **Git**: Git 2.30+ installed and configured.

---

## 5. Quickstart & Setup Instructions

### A. Flutter Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd frontend-client
   ```

2. Download Flutter package dependencies:
   ```bash
   flutter pub get
   ```

3. Run static analysis:
   ```bash
   flutter analyze
   ```

4. Run automated test suite:
   ```bash
   flutter test
   ```

5. Launch the application:
   ```bash
   # Run on Chrome (Web)
   flutter run -d chrome

   # Run on connected phone or emulator
   flutter run
   ```

---

### B. Python Backend Tools Setup

1. Navigate to the backend tools directory:
   ```bash
   cd backend-tools
   ```

2. Create and activate a virtual environment:
   - **Windows (PowerShell):**
     ```powershell
     python -m venv .venv
     .\.venv\Scripts\Activate.ps1
     ```
   - **macOS / Linux:**
     ```bash
     python3 -m venv .venv
     source .venv/bin/activate
     ```

3. Install requirements:
   ```bash
   pip install --upgrade pip
   pip install -r requirements.txt
   ```

4. Verify script compilation:
   ```bash
   python -m compileall scripts
   ```

5. Test audio tool commands:
   ```bash
   # Text-to-speech dialogue synthesis validation
   python scripts/text_to_speech.py --text "Urgent notice!" --authorized-voice --dry-run

   # Voice cloning scaffolding validation (requires explicit consent flag)
   python scripts/clone_peer.py --sample-path voice_samples/sample.wav --speaker-name "Alex" --authorized-consent --dry-run
   ```

---

## 6. Testing Instructions

| Test Scope | Target Directory | Command | Purpose |
| :--- | :--- | :--- | :--- |
| **Dart Analysis** | `frontend-client/` | `flutter analyze` | Validates syntax, style rules, and type safety |
| **Flutter Widgets** | `frontend-client/` | `flutter test` | Executes widget mount and rendering tests |
| **Python Syntax** | `backend-tools/` | `python -m compileall scripts` | Validates Python syntax and bytecode compilation |
| **CI Automation** | `.github/workflows/` | GitHub Actions Runner | Runs on every push and pull request |

---

## 7. Git Workflow Instructions

1. **Branching Model**:
   - `main`: Production-ready, passing all CI checks.
   - `feature/<feature-name>`: Feature branches for new screens, audio pipeline integration, or state logic.
   - `fix/<bug-name>`: Bug fixes and performance adjustments.

2. **Commits**:
   - Use conventional commit messages: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`.
   - Never commit private recordings, generated voice weights, API keys, or `.env` files (enforced by `.gitignore`).

---

## 8. Optional Assets & Future Development

The repository is configured to build cleanly out of the box without any third-party binary assets.

- **Audio Tracks**: You may optionally place `ringtone_ios.mp3`, `ringtone_android.mp3`, `peer_mom.mp3`, or `peer_landlord.mp3` inside `frontend-client/assets/audio/`. Consult `frontend-client/assets/audio/README.md` for guidelines.
- **Custom Typography**: You may place custom fonts like `SF-Pro-Display.ttf` in `frontend-client/assets/fonts/`. Consult `frontend-client/assets/fonts/README.md` for licensing notes and open-source alternatives.
- **Future AI Voice Modeling**: Heavyweight dependencies (`torch`, `coqui-tts`, etc.) are deferred. Once ready, update `backend-tools/requirements.txt` and integrate with `clone_peer.py` and `text_to_speech.py`.

---

## 9. Legal & Ethical Policy

GhostBuster is an offline, strictly simulated experience intended for polite personal social boundary management. It does not interface with cellular carrier networks or emergency services. Using voice cloning tools on non-consenting individuals or creating deceptive impersonations is strictly forbidden.

---

## 10. License

This project is licensed under the [MIT License](LICENSE).
