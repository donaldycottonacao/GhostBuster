import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Colors used by the setup, countdown and voice script manager screens.
///
/// The dark palette is the original GhostBuster design. The light palette keeps
/// the same green identity with darker accents so text stays readable on white.
/// The call screens (incoming, active, ended) always use the dark call-screen
/// palette in `call_screen_components.dart`, because they imitate a real phone.
@immutable
class GhostPalette extends ThemeExtension<GhostPalette> {
  const GhostPalette({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.field,
    required this.border,
    required this.accent,
    required this.onAccent,
    required this.textPrimary,
    required this.muted,
    required this.subtle,
    required this.hint,
    required this.selectedFill,
    required this.avatarFill,
    required this.avatarIcon,
    required this.warning,
    required this.warningSurface,
    required this.warningText,
    required this.danger,
    required this.amber,
    required this.logoGlow,
  });

  final Color background;
  final Color surface;
  final Color surfaceRaised;

  /// Fill for inputs and tappable rows inside a card.
  final Color field;
  final Color border;
  final Color accent;

  /// Text and icons drawn on top of [accent].
  final Color onAccent;
  final Color textPrimary;
  final Color muted;

  /// Footnote text (disclaimer).
  final Color subtle;
  final Color hint;

  /// Fill for a selected chip.
  final Color selectedFill;
  final Color avatarFill;
  final Color avatarIcon;
  final Color warning;
  final Color warningSurface;
  final Color warningText;
  final Color danger;

  /// Countdown "live audio" indicator.
  final Color amber;

  /// Glow behind the GHOSTBUSTER logo.
  final Color logoGlow;

  static const dark = GhostPalette(
    background: Color(0xFF080B09),
    surface: Color(0xFF151D18),
    surfaceRaised: Color(0xFF1B261F),
    field: Color(0xFF18221B),
    border: Color(0xFF344138),
    accent: Color(0xFF8BC49A),
    onAccent: Color(0xFF102017),
    textPrimary: Colors.white,
    muted: Color(0xFFABB4AD),
    subtle: Color(0xFF7E8981),
    hint: Color(0xFF778179),
    selectedFill: Color(0xFF304A38),
    avatarFill: Color(0xFF304A38),
    avatarIcon: Color(0xFFD8F1DC),
    warning: Color(0xFFFFB347),
    warningSurface: Color(0xFF2A2214),
    warningText: Color(0xFFF3DDB8),
    danger: Color(0xFFE53935),
    amber: Color(0xFFFFC247),
    logoGlow: Color(0xFF8BC49A),
  );

  static const light = GhostPalette(
    background: Color(0xFFF3F6F3),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFEDF2EE),
    field: Color(0xFFF7FAF7),
    border: Color(0xFFCAD5CD),
    accent: Color(0xFF2E7A46),
    onAccent: Colors.white,
    textPrimary: Color(0xFF0F1A13),
    muted: Color(0xFF536058),
    subtle: Color(0xFF66716A),
    hint: Color(0xFF7A867E),
    selectedFill: Color(0xFFD8EEDF),
    avatarFill: Color(0xFFD8EEDF),
    avatarIcon: Color(0xFF2E7A46),
    warning: Color(0xFFA65800),
    warningSurface: Color(0xFFFFF3E2),
    warningText: Color(0xFF5E3700),
    danger: Color(0xFFC62828),
    amber: Color(0xFFB07800),
    logoGlow: Color(0x552E7A46),
  );

  /// The palette for the current theme. Falls back on the theme's brightness
  /// when a test harness builds a plain `MaterialApp` without the extension.
  static GhostPalette of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<GhostPalette>() ??
        (theme.brightness == Brightness.dark ? dark : light);
  }

  @override
  GhostPalette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? field,
    Color? border,
    Color? accent,
    Color? onAccent,
    Color? textPrimary,
    Color? muted,
    Color? subtle,
    Color? hint,
    Color? selectedFill,
    Color? avatarFill,
    Color? avatarIcon,
    Color? warning,
    Color? warningSurface,
    Color? warningText,
    Color? danger,
    Color? amber,
    Color? logoGlow,
  }) {
    return GhostPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      field: field ?? this.field,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      textPrimary: textPrimary ?? this.textPrimary,
      muted: muted ?? this.muted,
      subtle: subtle ?? this.subtle,
      hint: hint ?? this.hint,
      selectedFill: selectedFill ?? this.selectedFill,
      avatarFill: avatarFill ?? this.avatarFill,
      avatarIcon: avatarIcon ?? this.avatarIcon,
      warning: warning ?? this.warning,
      warningSurface: warningSurface ?? this.warningSurface,
      warningText: warningText ?? this.warningText,
      danger: danger ?? this.danger,
      amber: amber ?? this.amber,
      logoGlow: logoGlow ?? this.logoGlow,
    );
  }

  @override
  GhostPalette lerp(ThemeExtension<GhostPalette>? other, double t) {
    if (other is! GhostPalette) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return GhostPalette(
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceRaised: mix(surfaceRaised, other.surfaceRaised),
      field: mix(field, other.field),
      border: mix(border, other.border),
      accent: mix(accent, other.accent),
      onAccent: mix(onAccent, other.onAccent),
      textPrimary: mix(textPrimary, other.textPrimary),
      muted: mix(muted, other.muted),
      subtle: mix(subtle, other.subtle),
      hint: mix(hint, other.hint),
      selectedFill: mix(selectedFill, other.selectedFill),
      avatarFill: mix(avatarFill, other.avatarFill),
      avatarIcon: mix(avatarIcon, other.avatarIcon),
      warning: mix(warning, other.warning),
      warningSurface: mix(warningSurface, other.warningSurface),
      warningText: mix(warningText, other.warningText),
      danger: mix(danger, other.danger),
      amber: mix(amber, other.amber),
      logoGlow: mix(logoGlow, other.logoGlow),
    );
  }
}

/// App-wide [ThemeData] for each brightness.
abstract final class GhostTheme {
  static ThemeData light() {
    const p = GhostPalette.light;
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: p.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: p.accent,
        brightness: Brightness.light,
      ).copyWith(
        primary: p.accent,
        onPrimary: p.onAccent,
        surface: p.surface,
        onSurface: p.textPrimary,
        error: p.danger,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      extensions: const [p],
    );
  }

  static ThemeData dark() {
    const p = GhostPalette.dark;
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0A0D0C),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3B82F6),
        secondary: Color(0xFF10B981),
        surface: Color(0xFF191D20),
        error: Color(0xFFEF4444),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A0D0C),
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      extensions: const [p],
    );
  }
}

/// Where the theme choice is saved between launches.
abstract interface class ThemeModeStore {
  Future<ThemeMode?> read();
  Future<void> write(ThemeMode mode);
}

/// Saves the theme choice on the device with `shared_preferences`.
class SharedPreferencesThemeModeStore implements ThemeModeStore {
  static const _key = 'ghostbuster.themeMode';

  @override
  Future<ThemeMode?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_key);
    for (final mode in ThemeMode.values) {
      if (mode.name == name) return mode;
    }
    return null;
  }

  @override
  Future<void> write(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

/// Holds the user's light/dark/system choice. Without a [store] the choice is
/// kept in memory only, which is what tests use.
class ThemeController extends ChangeNotifier {
  ThemeController(
      {ThemeModeStore? store, ThemeMode initialMode = ThemeMode.system})
      : _store = store,
        _mode = initialMode;

  final ThemeModeStore? _store;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  /// Restores the saved choice. A storage failure keeps the current mode.
  Future<void> load() async {
    final store = _store;
    if (store == null) return;
    try {
      final saved = await store.read();
      if (saved != null && saved != _mode) {
        _mode = saved;
        notifyListeners();
      }
    } catch (error) {
      debugPrint('ThemeController: could not read theme mode: $error');
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    try {
      await _store?.write(mode);
    } catch (error) {
      debugPrint('ThemeController: could not save theme mode: $error');
    }
  }
}
