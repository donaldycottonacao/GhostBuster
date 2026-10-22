import 'dart:io';

import 'package:flutter/services.dart';

/// Loads a real Roboto face under the family name `Roboto` (the Material
/// default on Android) so layout/overflow tests measure text with real glyph
/// metrics instead of the default flutter_test font, which draws every glyph as
/// a wide box and makes overflow checks pessimistic and platform-dependent.
///
/// The font is vendored at `test/fonts/Roboto-Regular.ttf` (Apache-2.0, license
/// alongside it) so the result is identical on every machine. The GitHub
/// Actions runner sets up the Flutter SDK but does NOT populate
/// `cache/artifacts/material_fonts`, so relying on the SDK copy made layout
/// tests fail on CI; the vendored font removes that dependency. The SDK path is
/// kept only as a fallback.
///
/// Returns true once a face is loaded.
Future<bool> loadSdkRoboto() async {
  if (await _loadVendoredRoboto()) return true;
  return _loadFromFlutterSdk();
}

Future<bool> _loadVendoredRoboto() async {
  // test/fonts relative to the package root where `flutter test` runs.
  final file = File('test/fonts/Roboto-Regular.ttf');
  if (!file.existsSync()) return false;
  final loader = FontLoader('Roboto')
    ..addFont(Future.value(ByteData.view(file.readAsBytesSync().buffer)));
  await loader.load();
  return true;
}

Future<bool> _loadFromFlutterSdk() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) return false;
  final sep = Platform.pathSeparator;
  final dir = Directory(
    '$flutterRoot${sep}bin${sep}cache${sep}artifacts${sep}material_fonts',
  );
  if (!dir.existsSync()) return false;

  final loader = FontLoader('Roboto');
  var added = 0;
  for (final weight in ['regular', 'light', 'medium', 'bold']) {
    final file = File('${dir.path}${sep}roboto-$weight.ttf');
    if (!file.existsSync()) continue;
    loader.addFont(Future.value(ByteData.view(file.readAsBytesSync().buffer)));
    added++;
  }
  if (added == 0) return false;
  await loader.load();
  return true;
}
