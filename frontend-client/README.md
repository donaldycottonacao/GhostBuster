# GhostBuster - Frontend Client (Flutter)

The frontend client for **GhostBuster** is an offline-first, mobile-responsive Flutter application designed to simulate hyper-realistic phone calls for tactical social escapes.

---

## Architecture Overview

The frontend follows a clean, modular, provider-driven architecture separating UI screens, shared widgets, state providers, localization, and audio services:

```text
lib/
├── main.dart                 # Application entry point, theme & provider injection
├── l10n/                     # Internationalization (i18n / l10n)
│   ├── app_en.arb            # English translation resources
│   ├── app_tl.arb            # Tagalog translation resources
│   ├── app_ceb.arb           # Cebuano / Bisaya translation resources
│   └── app_localizations.dart# Strongly-typed localization delegates
├── models/
│   └── call_state.dart       # CallLifecycleState enum, persona profiles, session data
├── providers/
│   └── call_provider.dart    # Centralized state provider (timers, lifecycle, audio triggers, locale)
├── services/
│   └── audio_service.dart    # Safe audio playback interface & fallback simulator
├── screens/
│   ├── stealth_trigger.dart  # Countdown config, persona selector, trigger controls
│   ├── incoming_call_ui.dart # Simulated incoming call screen (slide to answer)
│   └── active_call_ui.dart   # Simulated in-call screen with timer & dial pad
└── widgets/
    ├── slide_button.dart     # Reusable gesture-slider widget scaffold
    └── dial_pad_button.dart  # Reusable circular phone dial pad button widget
```

---

## State Management Architecture

State is managed using the official **Provider** package (`CallProvider` extending `ChangeNotifier`).
- **Encapsulated Business Logic**: Widgets do not manage raw timers. Countdown ticking, active call duration, audio events, and lifecycle state changes are handled entirely inside `CallProvider`.
- **Safe Lifecycle & Cleanup**: Timers and audio streams are automatically canceled and cleaned up when calls end or when `dispose()` is invoked.
- **Dynamic Localization**: `CallProvider` maintains the active `Locale` and notifies listeners when the user switches languages between English, Tagalog, and Cebuano.

---

## Localization (English, Tagalog, Cebuano)

The application supports three languages:
1. **English (`en`)**: Default international language.
2. **Tagalog (`tl`)**: Filipino national language.
3. **Cebuano / Bisaya (`ceb`)**: Regional language spoken across Visayas and Mindanao.

### Adding a New Language
1. Create a new ARB file in `lib/l10n/app_<locale>.arb` (e.g. `app_es.arb`).
2. Copy all keys from `app_en.arb` and supply the translated values.
3. Add the locale to `AppLocalizations.supportedLocales` in `lib/l10n/app_localizations.dart`.
4. Register the new locale translation class in `_AppLocalizationsDelegate`.

---

## Supported Platforms

- **Android** (API 21+)
- **iOS** (iOS 12+)
- **Web** (Chrome, Safari, Firefox, Edge)

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

Optional audio and font assets are configured under:
- `assets/audio/` (e.g. `ringtone_ios.mp3`, `peer_mom.mp3`)
- `assets/fonts/` (e.g. `SF-Pro-Display.ttf`)

Both folders contain documentation and are registered in `pubspec.yaml`. The app incorporates safe fallback logic in `AudioService` and default system typography, ensuring missing optional media files will never crash or prevent building the application.
