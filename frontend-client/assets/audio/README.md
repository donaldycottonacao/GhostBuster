# Audio Assets Directory

This directory stores approved audio assets for the GhostBuster simulated-call application.

## Expected / Optional Audio Files

The application architecture supports the following optional audio tracks:

| Filename | Purpose | Recommended Format |
| :--- | :--- | :--- |
| `ringtone_ios.mp3` | Simulated iOS incoming call ringtone | MP3 / WAV, 44.1 kHz, Stereo |
| `ringtone_android.mp3` | Simulated Android incoming call ringtone | MP3 / WAV, 44.1 kHz, Stereo |
| `peer_mom.mp3` | Simulated dialogue audio track ("Mom" persona) | MP3, 44.1 kHz, Mono/Stereo |
| `peer_landlord.mp3` | Simulated dialogue audio track ("Landlord" persona) | MP3, 44.1 kHz, Mono/Stereo |

## Asset Guidelines & Ethics

> [!IMPORTANT]
> **Legal and Licensing Compliance**:
> 1. Do not commit copyrighted ringtones, proprietary system sounds, or unauthorized voice recordings to public repositories.
> 2. Voice clips must be sourced from consenting individuals or royalty-free, licensed synthetic voice packs.
> 3. The application includes safe fallback mechanisms in `AudioService` so that the app compiles and runs cleanly even when these optional audio files are not present.

## Adding Custom Audio

1. Place your licensed MP3 or WAV file in this directory (`frontend-client/assets/audio/`).
2. Verify that the asset path is registered in `frontend-client/pubspec.yaml` under `flutter.assets`.
3. Reference the asset name in `AudioService` or `CallSession` configuration.
