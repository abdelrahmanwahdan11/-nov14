import 'dart:math';

import 'package:flutter/material.dart';

const _lightPalette = _ThemePalette(
  background: Color(0xFFF4F1EE),
  surface: Color(0xFFFFFFFF),
  textPrimary: Color(0xFF111827),
  textSecondary: Color(0xFF6B7280),
  success: Color(0xFF22C55E),
  warning: Color(0xFFF59E0B),
  error: Color(0xFFEF4444),
);

const _darkPalette = _ThemePalette(
  background: Color(0xFF0F1115),
  surface: Color(0xFF171A21),
  textPrimary: Color(0xFFE5E7EB),
  textSecondary: Color(0xFF9CA3AF),
  success: Color(0xFF22C55E),
  warning: Color(0xFFF59E0B),
  error: Color(0xFFEF4444),
);

class ThemeController extends ChangeNotifier {
  ThemeController({Color? seed, bool darkMode = false})
      : _primarySeed = seed ?? const Color(0xFF4C6EF5),
        _isDark = darkMode,
        _mode = darkMode ? ThemeMode.dark : ThemeMode.light;

  Color _primarySeed;
  bool _isDark;

  Color get primarySeed => _primarySeed;
  bool get isDark => _isDark;

  ThemeMode _mode;
  ThemeMode get mode => _mode;

  void toggleDark(bool value) {
    _isDark = value;
    _mode = value ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setMode(ThemeMode mode) {
    _mode = mode;
    if (mode == ThemeMode.dark) {
      _isDark = true;
    } else if (mode == ThemeMode.light) {
      _isDark = false;
    }
    notifyListeners();
  }

  void updateSeed(Color color) {
    _primarySeed = color;
    notifyListeners();
  }

  ThemeData theme(Brightness brightness) {
    final palette = brightness == Brightness.dark ? _darkPalette : _lightPalette;
    final seed = _primarySeed;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Manrope',
      colorScheme: ColorScheme.fromSeed(
        brightness: brightness,
        seedColor: seed,
        primary: seed,
        secondary: Color.lerp(seed, palette.success, .3)!,
        surface: palette.surface,
        background: palette.background,
        error: palette.error,
      ),
      scaffoldBackgroundColor: palette.background,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontWeight: FontWeight.w500),
      ),
      cardTheme: CardTheme(
        color: palette.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surface.withOpacity(.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: TextStyle(color: palette.textSecondary),
        secondaryLabelStyle: TextStyle(color: palette.textPrimary),
      ),
    );
    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: palette.textPrimary,
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: seed),
    );
  }
}

class _ThemePalette {
  const _ThemePalette({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.error,
  });

  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color warning;
  final Color error;
}

Color randomAccent() {
  final swatches = [
    const Color(0xFF4C6EF5),
    const Color(0xFF22C55E),
    const Color(0xFF8B5CF6),
    const Color(0xFFF97316),
    const Color(0xFF0EA5E9),
  ];
  return swatches[Random().nextInt(swatches.length)];
}
