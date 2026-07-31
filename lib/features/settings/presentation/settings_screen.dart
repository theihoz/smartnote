import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../sync/data/supabase_config.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final supabaseEnabled = SupabaseConfig.fromEnvironment() != null;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Cài đặt',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'Giao diện',
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: const Text('Chế độ màu'),
                subtitle: Text(switch (themeMode) {
                  ThemeMode.light => 'Sáng',
                  ThemeMode.dark => 'Tối',
                  _ => 'Theo hệ thống',
                }),
                trailing: DropdownButton<ThemeMode>(
                  value: themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(themeModeProvider.notifier).state = value;
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('Hệ thống'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Sáng'),
                    ),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Tối')),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language_rounded),
                title: const Text('Ngôn ngữ'),
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
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _Section(
            title: 'Dữ liệu và đồng bộ',
            children: [
              ListTile(
                leading: Icon(
                  supabaseEnabled
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_off_outlined,
                ),
                title: const Text('Supabase'),
                subtitle: Text(
                  supabaseEnabled
                      ? 'Đã cấu hình • SQLite vẫn là nguồn offline'
                      : 'Chưa cấu hình • Ứng dụng đang chạy cục bộ',
                ),
                trailing: FilledButton.tonal(
                  onPressed: supabaseEnabled ? () {} : null,
                  child: const Text('Đồng bộ'),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.storage_rounded),
                title: Text('SQLite cục bộ'),
                subtitle: Text('CRUD ghi chú, tag, checklist và đường dẫn ảnh'),
                trailing: Icon(Icons.check_circle_rounded, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const _Section(
            title: 'Ứng dụng',
            children: [
              ListTile(
                leading: Icon(Icons.info_outline_rounded),
                title: Text('SmartNote'),
                subtitle: Text('Phiên bản 1.0.0 • vn.edu.smartnote'),
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
