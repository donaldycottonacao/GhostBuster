import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Keeps the display awake while a simulation is in progress.
///
/// GhostBuster's countdown is a foreground Dart timer: if the screen sleeps,
/// Android pauses the app and the countdown is cancelled by the lifecycle
/// policy. Holding the screen on during countdown/ringing/active prevents that.
abstract class ScreenWakeController {
  Future<void> setKeepScreenOn(bool keepOn);
}

/// Android implementation backed by `FLAG_KEEP_SCREEN_ON` in MainActivity.
///
/// Platforms without the channel (iOS, web, desktop, tests) throw
/// MissingPluginException, which the caller treats as best-effort.
class PlatformScreenWakeController implements ScreenWakeController {
  const PlatformScreenWakeController();

  static const MethodChannel _channel = MethodChannel('ghostbuster/screen');

  @override
  Future<void> setKeepScreenOn(bool keepOn) =>
      _channel.invokeMethod<void>('setKeepScreenOn', keepOn);
}

/// Returns whether a bundled asset can be loaded.
typedef AssetProbe = Future<bool> Function(String assetPath);

/// Default [AssetProbe]: tries to load the asset from the app bundle.
Future<bool> bundleAssetExists(String assetPath) async {
  try {
    await rootBundle.load(assetPath);
    return true;
  } catch (error) {
    debugPrint('[AssetProbe] Missing asset $assetPath');
    return false;
  }
}
