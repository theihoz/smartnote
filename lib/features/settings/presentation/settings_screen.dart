import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../app/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/feature_text.dart';
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
                leading: const Icon(Icons.lock_outline_rounded),
                title: Text(
                  featureText(context, vi: 'Khóa ghi chú', en: 'Note lock'),
                ),
                subtitle: Text(
                  featureText(
                    context,
                    vi: 'PIN chung 4–6 số, chống thử sai',
                    en: 'One 4–6 digit PIN with retry protection',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/security'),
              ),
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: Text(
                  featureText(
                    context,
                    vi: 'Tài khoản đồng bộ',
                    en: 'Sync account',
                  ),
                ),
                subtitle: Text(
                  featureText(
                    context,
                    vi: 'Đăng nhập bằng email và mật khẩu',
                    en: 'Sign in with email and password',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/auth'),
              ),
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
                        ref.read(appSettingsStoreProvider).saveThemeMode(value),
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
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(l10n.dark),
                    ),
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
                  supabaseEnabled ? l10n.cloudReady : l10n.cloudUnavailable,
                ),
                trailing: FilledButton.tonal(
                  onPressed: supabaseEnabled ? () {} : null,
                  child: Text(l10n.sync),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.ios_share_rounded),
                title: Text(
                  featureText(context, vi: 'Xuất ghi chú', en: 'Export notes'),
                ),
                subtitle: Text(
                  featureText(
                    context,
                    vi: 'Chọn nhiều ghi chú, PDF hoặc Markdown',
                    en: 'Select multiple notes as PDF or Markdown',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/export'),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: Text(featureText(context, vi: 'Thùng rác', en: 'Trash')),
                subtitle: Text(
                  featureText(
                    context,
                    vi: 'Khôi phục ghi chú trong vòng 30 ngày',
                    en: 'Restore notes within 30 days',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/trash'),
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
