# GhostBuster Assets Directory

This directory houses static media assets utilized by the **GhostBuster** Flutter application.

---

## Directory Structure & Expected Files

```text
assets/
├── audio/
│   ├── ringtone_ios.mp3       # Simulated iOS incoming call ringtone
│   ├── ringtone_android.mp3   # Simulated Android incoming call ringtone
│   ├── peer_mom.mp3           # Consensual dialogue track ("Mom" persona)
│   └── peer_landlord.mp3      # Consensual dialogue track ("Landlord" persona)
│   └── README.md              # Detailed audio format & licensing guidelines
└── fonts/
    ├── SF-Pro-Display.ttf     # iOS-style San Francisco typography (optional)
    └── README.md              # Font licensing & open-source alternative guidelines
```

---

## Licensing & Asset Safety

> [!IMPORTANT]
> **No Fake Media / No Copyright Infringement**:
> - The repository does **not** include dummy binaries, proprietary fonts, or unauthorized voice recordings.
> - The application is designed with **safe fallbacks**:
>   - Audio playback is wrapped in `AudioService`, which logs and simulates playback gracefully if audio files are absent.
>   - Typography defaults to standard system fonts (San Francisco on iOS, Roboto on Android, Inter on Web) so custom font binaries are never mandatory.
> - The application compiles, analyzes, and tests successfully without these optional files present.

## Adding Assets

1. **Audio**: Drop your legally licensed MP3 or WAV files into `assets/audio/`.
2. **Fonts**: Drop your licensed TrueType/OpenType font into `assets/fonts/`.
3. Both directories are registered in `pubspec.yaml` under `flutter.assets:`.
