import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../../app/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../sync/data/supabase_config.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final supabaseEnabled = SupabaseConfig.fromEnvironment() != null;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            l10n.settings,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          _Section(
            title: l10n.themeSection,
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: Text(l10n.themeMode),
                subtitle: Text(switch (themeMode) {
                  ThemeMode.light => l10n.light,
                  ThemeMode.dark => l10n.dark,
                  _ => l10n.system,
                }),
                trailing: DropdownButton<ThemeMode>(
                  value: themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeModeProvider.notifier).state = value;
                      unawaited(
                        ref
                            .read(appSettingsStoreProvider)
                            .saveThemeMode(value),
                      );
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(l10n.system),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(l10n.light),
                    ),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.dark)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language_rounded),
                title: Text(l10n.language),
                trailing: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'vi', label: Text('VI')),
                    ButtonSegment(value: 'en', label: Text('EN')),
                  ],
                  selected: {locale.languageCode},
                  onSelectionChanged: (value) {
                    ref.read(localeProvider.notifier).state = Locale(
                      value.single,
                    );
                    unawaited(
                      ref
                          .read(appSettingsStoreProvider)
                          .saveLocale(Locale(value.single)),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _Section(
            title: l10n.storageSection,
            children: [
              ListTile(
                leading: Icon(
                  supabaseEnabled
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_off_outlined,
                ),
                title: Text(l10n.cloudSync),
                subtitle: Text(
                  supabaseEnabled
                      ? l10n.cloudReady
                      : l10n.cloudUnavailable,
                ),
                trailing: FilledButton.tonal(
                  onPressed: supabaseEnabled ? () {} : null,
                  child: Text(l10n.sync),
                ),
              ),
              ListTile(
                leading: Icon(Icons.storage_rounded),
                title: Text(l10n.localStorage),
                subtitle: Text(l10n.localStorageDescription),
                trailing: Icon(Icons.check_circle_rounded, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _Section(
            title: l10n.about,
            children: [
              ListTile(
                leading: Icon(Icons.info_outline_rounded),
                title: const Text('SmartNote'),
                subtitle: Text(l10n.version),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Card(child: Column(children: children)),
      ],
    );
  }
}
