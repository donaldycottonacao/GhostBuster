# GhostBuster - Frontend Client (Flutter)

The frontend client for **GhostBuster** is an offline-first, mobile-responsive Flutter application designed to simulate hyper-realistic phone calls for tactical social escapes.

---

## Architecture Overview

The frontend follows a clean modular structure separating UI screens, shared widgets, data models, and services:

```text
lib/
├── main.dart                 # Application entry point and theme configuration
├── models/
│   └── call_state.dart       # Call lifecycle enum, persona definitions, session state
├── services/
│   └── audio_service.dart    # Safe audio playback interface and fallback simulator
├── screens/
│   ├── stealth_trigger.dart  # Countdown config, persona selector, trigger controls
│   ├── incoming_call_ui.dart # Simulated incoming call screen (slide to answer)
│   └── active_call_ui.dart   # Simulated in-call screen with timer & dial pad
└── widgets/
    ├── slide_button.dart     # Reusable gesture-slider widget scaffold
    └── dial_pad_button.dart  # Reusable circular phone dial pad button widget
```

---

## Supported Platforms

- **Android** (API 21+)
- **iOS** (iOS 12+)
- **Web** (Chrome, Safari, Firefox, Edge)

---

## Prerequisites

- **Flutter SDK**: 3.24+ / 3.29+
- **Dart SDK**: 3.0+
- **Android Studio / Xcode** (for mobile emulators/devices)
- **Chrome** (for web development)

---

## Setup & Running

### 1. Install Dependencies
From within the `frontend-client/` directory:
```bash
flutter pub get
```

### 2. Run Code Analysis & Tests
```bash
# Analyze Dart code for syntax, style, and potential bugs
flutter analyze

# Run automated widget and unit tests
flutter test
```

### 3. Launch Development Server / App
```bash
# Run on Chrome (Web)
flutter run -d chrome

# Run on connected mobile device or emulator
flutter run
```

---

## Assets & Safe Fallback

Optional audio and font assets are placed under:
- `assets/audio/` (e.g. `ringtone_ios.mp3`, `peer_mom.mp3`)
- `assets/fonts/` (e.g. `SF-Pro-Display.ttf`)

Both folders contain a `README.md` and are registered in `pubspec.yaml`. The app incorporates safe fallback logic in `AudioService` and default system fonts, ensuring that missing optional media files will never crash or prevent building the application.

---

## Ethical & Security Notice

GhostBuster generates **local simulated screen interfaces and sounds** only. It does not:
- Connect to cellular carrier networks.
- Intercept real-world phone calls.
- Spoof caller ID on external telephony lines.
