import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartnote/features/settings/data/app_settings_repository.dart';

void main() {
  test('loads saved theme and locale after a new repository is created', () async {
    SharedPreferences.setMockInitialValues({
      'smartnote.theme_mode': 'dark',
      'smartnote.language_code': 'en',
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = AppSettingsRepository(preferences);

    expect(repository.loadThemeMode(), ThemeMode.dark);
    expect(repository.loadLocale(), const Locale('en'));
  });

  test('persists all supported theme modes and locales', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = AppSettingsRepository(preferences);

    await repository.saveThemeMode(ThemeMode.light);
    await repository.saveLocale(const Locale('en'));

    expect(preferences.getString('smartnote.theme_mode'), 'light');
    expect(preferences.getString('smartnote.language_code'), 'en');
  });
}
