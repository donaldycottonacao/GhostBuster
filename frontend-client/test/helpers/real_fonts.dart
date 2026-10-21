import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the Roboto files bundled with the Flutter SDK under the family name
/// `Roboto` (the Material default on Android).
///
/// The default flutter_test font draws every glyph as a wide box, which makes
/// overflow checks far more pessimistic than a real device. Layout tests that
/// assert "no overflow" should call this in `setUpAll` so text is measured with
/// real metrics. `flutter test` sets FLUTTER_ROOT; returns false if the fonts
/// cannot be found so callers can fail loudly instead of silently passing.
Future<bool> loadSdkRoboto() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) return false;
  final dir = Directory(
    '$flutterRoot${Platform.pathSeparator}bin${Platform.pathSeparator}cache'
    '${Platform.pathSeparator}artifacts${Platform.pathSeparator}material_fonts',
  );
  if (!dir.existsSync()) return false;

  final loader = FontLoader('Roboto');
  var added = 0;
  for (final weight in ['regular', 'light', 'medium', 'bold']) {
    final file = File('${dir.path}${Platform.pathSeparator}roboto-$weight.ttf');
    if (!file.existsSync()) continue;
    final bytes = file.readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    added++;
  }
  if (added == 0) return false;
  await loader.load();
  return true;
}
