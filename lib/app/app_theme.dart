import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const canvas = Color(0xFFFFF8F6);
  static const indigo = Color(0xFF423F78);
  static const lavender = Color(0xFFEFEDF4);
  static const coral = Color(0xFF904A46);
  static const peach = Color(0xFFFFDAD7);
  static const sage = Color(0xFFE3E1E8);
  static const ink = Color(0xFF1E1B1A);
  static const muted = Color(0xFF47464F);
  static const surfaceContainerLow = Color(0xFFFBF2F0);
  static const surfaceContainerHigh = Color(0xFFEFE6E4);

  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: indigo,
          brightness: Brightness.light,
          surface: canvas,
        ).copyWith(
          primary: indigo,
          primaryContainer: const Color(0xFF5A5791),
          onPrimaryContainer: const Color(0xFFD6D3FF),
          secondary: coral,
          secondaryContainer: const Color(0xFFFEA49D),
          tertiaryContainer: sage,
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: surfaceContainerLow,
          surfaceContainerHigh: surfaceContainerHigh,
          outline: const Color(0xFF787680),
          outlineVariant: const Color(0xFFC8C5D1),
        );
    return _base(scheme).copyWith(scaffoldBackgroundColor: canvas);
  }

  static ThemeData get dark {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFFC4C0FF),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFFC4C0FF),
          primaryContainer: const Color(0xFF434078),
          secondary: const Color(0xFFFFB3AE),
          surface: const Color(0xFF1E1B1A),
          surfaceContainerLowest: const Color(0xFF171514),
          surfaceContainerLow: const Color(0xFF292624),
          outline: const Color(0xFF938F99),
        );
    return _base(
      scheme,
    ).copyWith(scaffoldBackgroundColor: const Color(0xFF1E1B1A));
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Outfit',
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        color: scheme.brightness == Brightness.light
            ? lavender.withValues(alpha: 0.8)
            : scheme.surfaceContainerLow,
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
        indicatorColor: scheme.secondaryContainer,
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
