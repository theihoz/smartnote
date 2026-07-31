import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const canvas = Color(0xFFFDFCF8);
  static const indigo = Color(0xFF5A5791);
  static const lavender = Color(0xFFEFEDF4);
  static const coral = Color(0xFFE58F89);
  static const peach = Color(0xFFFFE2DE);
  static const sage = Color(0xFFDCE9DE);
  static const ink = Color(0xFF292524);
  static const muted = Color(0xFF78716C);

  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: indigo,
          brightness: Brightness.light,
          surface: Colors.white,
        ).copyWith(
          primary: indigo,
          primaryContainer: lavender,
          secondary: coral,
          secondaryContainer: peach,
          tertiaryContainer: sage,
          surfaceContainerLowest: canvas,
          outline: const Color(0xFFD8D1C7),
        );
    return _base(scheme).copyWith(scaffoldBackgroundColor: canvas);
  }

  static ThemeData get dark {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFFC8C3F2),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFFC8C3F2),
          primaryContainer: const Color(0xFF403D70),
          secondary: const Color(0xFFFFB7B2),
          surface: const Color(0xFF292624),
          surfaceContainerLowest: const Color(0xFF1E1C1A),
          outline: const Color(0xFF746C65),
        );
    return _base(
      scheme,
    ).copyWith(scaffoldBackgroundColor: const Color(0xFF1E1C1A));
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Outfit',
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: 'Outfit',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
