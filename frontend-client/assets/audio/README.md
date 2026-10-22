# Audio Assets Directory

This directory stores approved audio assets for the GhostBuster simulated-call application.

## Expected / Optional Audio Files

The application architecture supports the following optional audio tracks:

### Ringtones (bundled)

| Filename | Ringtone option id | Label | Source |
| :--- | :--- | :--- | :--- |
| `ringtone_telephone.mp3` | `telephone` (default) | Telephone | Pixabay (soundreality) #324474 |
| `ringtone_ringing.mp3` | `ringing` | Classic Ring | Pixabay (dragon-studio) #382734 |
| `ringtone_classic.mp3` | `classic` | Classic Phone | Pixabay (soynoviembre) #439034 |
| `ringtone_modern1.mp3` | `modern1` | Modern 1 | Pixabay (universfield) #496414 |
| `ringtone_modern2.mp3` | `modern2` | Modern 2 | Pixabay (universfield) #496417 |

These five ringtones are bundled and committed. They are from Pixabay, whose
content license permits free use (including commercial) without attribution,
and prohibits reselling the sound files standalone. See
<https://pixabay.com/service/license-summary/>.

### Voice dialogue (optional, not bundled)

| Filename | Purpose | Recommended Format |
| :--- | :--- | :--- |
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
