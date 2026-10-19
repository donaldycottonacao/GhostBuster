# Font Assets Directory

This directory stores custom typography assets for the GhostBuster simulated-call application.

## Expected / Optional Font Files

| Font Family | Filename | Purpose | Recommended Source |
| :--- | :--- | :--- | :--- |
| **SF Pro Display** | `SF-Pro-Display.ttf` | iOS-styled dial pad and lock screen simulation | Apple Developer Fonts (macOS/iOS only) or Open Source alternative |

## Licensing & Distribution Compliance

> [!WARNING]
> **Proprietary Font Licensing**:
> Apple's San Francisco (SF Pro) font family is proprietary and restricted by Apple's software license agreements for use on Apple platforms. It cannot be redistributed in public Git repositories or used commercially on non-Apple operating systems without a commercial license.

### Recommended Open-Source Alternatives:
For cross-platform (Web and Android) parity without licensing restrictions, consider using:
- **Inter** (OFL - SIL Open Font License) - matches modern mobile typography geometry.
- **Roboto** (Apache 2.0) - native Android aesthetic.

### Safe Build Scaffolding:
The application uses Flutter's default platform system fonts as fallback (`ThemeData.light()` / `ThemeData.dark()`). The application will build and run cleanly without requiring manual font binaries. If you add custom `.ttf` or `.otf` files here, remember to declare the font family in `pubspec.yaml`.
