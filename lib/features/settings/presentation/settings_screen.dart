import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/feature_text.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Header section
          Text(
            l10n.settings,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your workspace preferences, security, and data.',
            style: TextStyle(color: theme.colorScheme.outline),
          ),
          const SizedBox(height: 24),

          _BentoCard(
            title: 'Account',
            icon: Icons.account_circle_rounded,
            iconColor: theme.colorScheme.primary,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline_rounded),
                title: Text(featureText(context, vi: 'Tài khoản & đăng nhập', en: 'Account & sign in')),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/auth'),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Security Bento Card
          _BentoCard(
            title: 'Security',
            icon: Icons.shield_rounded,
            iconColor: theme.colorScheme.primary,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_rounded, size: 20),
                ),
                title: Text(
                  featureText(
                    context,
                    vi: 'Khóa ghi chú & PIN',
                    en: 'Security & PIN Lock',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  featureText(
                    context,
                    vi: 'Yêu cầu mã PIN 4–6 số khi mở ứng dụng',
                    en: 'Require PIN to open SmartNote',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/security'),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Appearance Bento Card
          _BentoCard(
            title: 'Appearance',
            icon: Icons.palette_rounded,
            iconColor: theme.colorScheme.secondary,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    themeMode == ThemeMode.dark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    size: 20,
                  ),
                ),
                title: Text(
                  l10n.themeMode,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  themeMode == ThemeMode.dark
                      ? 'Currently Dark'
                      : 'Currently Light',
                ),
                trailing: Switch(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (isDark) {
                    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
                    ref.read(themeModeProvider.notifier).state = newMode;
                    unawaited(
                      ref.read(appSettingsStoreProvider).saveThemeMode(newMode),
                    );
                  },
                ),
              ),
              const Divider(indent: 56, height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.language_rounded, size: 20),
                ),
                title: Text(
                  l10n.language,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
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

          // Data Management Bento Card
          _BentoCard(
            title: 'Data Management',
            icon: Icons.storage_rounded,
            iconColor: theme.colorScheme.primary,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.download_rounded, size: 20),
                ),
                title: Text(
                  featureText(context, vi: 'Xuất ghi chú', en: 'Export Data'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('PDF / Markdown / JSON'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/export'),
              ),
              const Divider(indent: 56, height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(
                      alpha: 0.5,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_rounded,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                ),
                title: Text(
                  featureText(context, vi: 'Thùng rác', en: 'Trash Bin'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.error,
                  ),
                ),
                subtitle: Text(
                  featureText(
                    context,
                    vi: 'Khôi phục ghi chú trong 30 ngày',
                    en: 'Restore notes within 30 days',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/trash'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Version & Branding
          Center(
            child: Column(
              children: [
                Text(
                  'SmartNote',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'VERSION 1.0.0 • BÀI GIỮA KỲ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.outline,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
