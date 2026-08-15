import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AppSettingsStore {
  ThemeMode loadThemeMode();

  Future<void> saveThemeMode(ThemeMode mode);

  Locale loadLocale();

  Future<void> saveLocale(Locale locale);
}

class AppSettingsRepository implements AppSettingsStore {
  const AppSettingsRepository(this._preferences);

  static const _themeKey = 'smartnote.theme_mode';
  static const _localeKey = 'smartnote.language_code';
  final SharedPreferences _preferences;

  @override
  ThemeMode loadThemeMode() {
    return switch (_preferences.getString(_themeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) {
    return _preferences.setString(_themeKey, mode.name);
  }

  @override
  Locale loadLocale() {
    final code = _preferences.getString(_localeKey);
    return code == 'en' ? const Locale('en') : const Locale('vi');
  }

  @override
  Future<void> saveLocale(Locale locale) {
    return _preferences.setString(_localeKey, locale.languageCode);
  }
}

class MemoryAppSettingsStore implements AppSettingsStore {
  ThemeMode themeMode = ThemeMode.system;
  Locale locale = const Locale('vi');

  @override
  ThemeMode loadThemeMode() => themeMode;

  @override
  Future<void> saveThemeMode(ThemeMode mode) async => themeMode = mode;

  @override
  Locale loadLocale() => locale;

  @override
  Future<void> saveLocale(Locale value) async => locale = value;
}
