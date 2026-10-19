# GhostBuster 👻

> An open-source, mobile-responsive Flutter web/native application designed to orchestrate tactical social escapes using hyper-realistic UI cloning, automated local state hooks, and custom-baked cloned AI peer voices. Completely free, offline-first, and highly petty.

---

## 1. Project Overview

**GhostBuster** provides users with an offline, hyper-realistic escape call mechanism to tactfully exit awkward social scenarios, meetings, or encounters. The system pairs a cross-platform Flutter frontend (simulating incoming call screens, slide-to-answer gestures, active call timers, and localized interfaces) with modular Python backend tools (scaffolding voice cloning and text-to-speech dialogue generation).

### Key Architectural Tenets
- **Offline-First & Private**: Runs entirely locally on-device without remote telephony routing or carrier networks.
- **Provider State Architecture**: Centralized, testable business logic in `CallProvider` decoupling state and timers from presentation widgets.
- **Trilingual Localization**: Native support for **English (`en`)**, **Tagalog (`tl`)**, and **Cebuano / Bisaya (`ceb`)**.
- **Explicitly Consensual**: Voice cloning and audio generation tools strictly require documented speaker authorization.
- **Cross-Platform**: Targets Android, iOS, and Web from a single Flutter codebase.

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
│   ├── .env.example              # Environment variables template for audio tools
│   ├── scripts/
│   │   ├── clone_peer.py         # Consensual voice sample processing scaffold
│   │   └── text_to_speech.py     # Authorized dialogue synthesis scaffold
│   ├── tests/
│   │   └── test_cli.py           # Backend CLI smoke tests & consent verification
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
│   │   ├── README.md             # Overview of assets, licensing, and fallbacks
│   │   ├── audio/
│   │   │   ├── ringtone_ios.mp3      # (Optional) iOS ringtone
│   │   │   ├── ringtone_android.mp3  # (Optional) Android ringtone
│   │   │   ├── peer_mom.mp3          # (Optional) Mom persona dialogue track
│   │   │   ├── peer_landlord.mp3     # (Optional) Landlord persona dialogue track
│   │   │   └── README.md             # Guide for optional ringtones & dialogue audio
│   │   └── fonts/
│   │       ├── SF-Pro-Display.ttf    # (Optional) Custom typography
│   │       └── README.md             # Guide for optional custom typography (SF Pro / Inter)
│   │
│   ├── lib/
│   │   ├── main.dart             # Application entry point, theme & Provider root
│   │   ├── l10n/                 # Localization ARB files & delegates
│   │   │   ├── app_en.arb        # English localization resources
│   │   │   ├── app_tl.arb        # Tagalog localization resources
│   │   │   ├── app_ceb.arb       # Cebuano / Bisaya localization resources
│   │   │   └── app_localizations.dart # Strongly typed localization classes & delegates
│   │   ├── models/
│   │   │   └── call_state.dart   # CallLifecycleState enum & persona/session models
│   │   ├── providers/
│   │   │   └── call_provider.dart# Centralized state provider (timers, lifecycle, locale)
│   │   ├── services/
│   │   │   └── audio_service.dart# Audio playback service interface & safe fallback
│   │   ├── screens/
│   │   │   ├── stealth_trigger.dart   # Escape trigger configuration, timer, language picker
│   │   │   ├── incoming_call_ui.dart  # Simulated incoming call UI
│   │   │   └── active_call_ui.dart    # Simulated active call screen & timer
│   │   └── widgets/
│   │       ├── slide_button.dart      # Reusable gesture-slider widget
│   │       └── dial_pad_button.dart   # Reusable keypad-button widget
│   │
│   ├── test/
│   │   └── widget_test.dart      # Flutter widget verification tests
│   ├── analysis_options.yaml     # Dart analysis and linting rules
│   ├── l10n.yaml                 # Flutter localization generation settings
│   ├── pubspec.yaml              # Flutter project configuration & dependencies
│   └── README.md                 # Frontend documentation
│
├── .gitignore                    # Git ignore rules for Flutter, Dart, Python, & media
├── LICENSE                       # MIT License
└── README.md                     # Root project documentation
```

---

## 3. Technology Stack

- **Frontend**: Flutter (3.24+ / 3.29+), Dart (3.0+), Material 3.
- **State Management**: `provider` (^6.1.2) via `CallProvider`.
- **Localization**: `flutter_localizations`, `intl` (^0.19.0), ARB resources (English, Tagalog, Cebuano).
- **Backend / Tooling**: Python 3.10+, Standard Library CLI (`argparse`, `unittest`), pip.
- **CI / Automation**: GitHub Actions (`subosito/flutter-action@v2`, `actions/setup-python@v5`).
- **Platforms**: Android (API 21+), iOS (iOS 12+), Web (Chromium, Safari, Firefox).

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

3. Install dependencies:
   ```bash
   pip install --upgrade pip
   pip install -r requirements.txt
   ```

4. Configure environment settings:
   ```bash
   cp .env.example .env     # macOS / Linux
   copy .env.example .env   # Windows
   ```

5. Run syntax check and CLI tests:
   ```bash
   python -m compileall scripts tests
   python -m unittest tests/test_cli.py
   ```

---

## 6. Localization Instructions

GhostBuster supports three languages out of the box:
- **English (`en`)**
- **Tagalog (`tl`)**
- **Cebuano / Bisaya (`ceb`)**

Users can switch languages on the fly using the **Language (🌐)** button in the AppBar.

### Adding a New Language:
1. Create `frontend-client/lib/l10n/app_<locale>.arb` (e.g. `app_es.arb`).
2. Add translations matching all keys in `app_en.arb`.
3. Register the locale in `AppLocalizations.supportedLocales` in `lib/l10n/app_localizations.dart`.

---

## 7. Optional Assets & Safe Fallback

The application is structured to compile, run, and pass all automated tests without requiring external proprietary media files:

- **Audio Tracks**: Drop licensed MP3/WAV files (`ringtone_ios.mp3`, `ringtone_android.mp3`, `peer_mom.mp3`, `peer_landlord.mp3`) into `frontend-client/assets/audio/`.
- **Fonts**: Drop licensed TrueType fonts (`SF-Pro-Display.ttf`) into `frontend-client/assets/fonts/`.
- If assets are absent, `AudioService` logs simulated playback safely without throwing unhandled runtime exceptions, and the UI gracefully uses platform system typography.

---

## 8. CI/CD Workflow

The GitHub Actions workflow (`.github/workflows/flutter-ci.yml`) runs on every push and pull request to `main`, `master`, `development`, and `develop`:
1. **Flutter CI**:
   - Sets up Flutter SDK `3.29.0`.
   - Runs `flutter pub get` in `frontend-client/`.
   - Runs `flutter analyze --no-fatal-infos`.
   - Runs `flutter test`.
2. **Python CI**:
   - Sets up Python 3.11.
   - Installs dependencies from `backend-tools/requirements.txt`.
   - Runs `python -m compileall scripts tests`.
   - Runs `python -m unittest tests/test_cli.py`.

---

## 9. Legal & Ethical Policy

GhostBuster is strictly a **local simulated call generator** designed for benign personal boundary management. It does not:
- Connect to cellular telecom networks.
- Intercept, spoof, or hijack real telephone calls.
- Permit unauthorized voice cloning or non-consensual voice generation.

---

## 10. License

This project is licensed under the [MIT License](LICENSE).
