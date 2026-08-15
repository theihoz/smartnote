import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/feature_text.dart';

class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  final _pin = TextEditingController();
  final _confirm = TextEditingController();
  String? _message;

  @override
  void dispose() {
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final service = ref.read(pinLockServiceProvider);
    if (service == null) return;
    if (_pin.text != _confirm.text ||
        !RegExp(r'^\d{4,6}$').hasMatch(_pin.text)) {
      setState(() {
        _message = featureText(
          context,
          vi: 'PIN phải trùng nhau và có 4–6 chữ số.',
          en: 'PINs must match and contain 4–6 digits.',
        );
      });
      return;
    }
    await service.setPin(_pin.text);
    _pin.clear();
    _confirm.clear();
    setState(() {
      _message = featureText(
        context,
        vi: 'Đã lưu PIN khóa ghi chú.',
        en: 'Note lock PIN saved.',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(pinLockServiceProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(featureText(context, vi: 'Khóa ghi chú', en: 'Note lock')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_person_outlined, size: 52),
                  const SizedBox(height: 12),
                  Text(
                    service?.isConfigured == true
                        ? featureText(
                            context,
                            vi: 'Đổi PIN chung',
                            en: 'Change shared PIN',
                          )
                        : featureText(
                            context,
                            vi: 'Tạo PIN chung',
                            en: 'Create shared PIN',
                          ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    featureText(
                      context,
                      vi: 'PIN chỉ lưu trên thiết bị. Sau 5 lần sai, ứng dụng khóa thử lại trong 30 giây.',
                      en: 'The PIN stays on this device. Five failed attempts pause retries for 30 seconds.',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _pin,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: featureText(
                        context,
                        vi: 'PIN mới',
                        en: 'New PIN',
                      ),
                    ),
                  ),
                  TextField(
                    controller: _confirm,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: featureText(
                        context,
                        vi: 'Nhập lại PIN',
                        en: 'Confirm PIN',
                      ),
                    ),
                  ),
                  if (_message != null) Text(_message!),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: service == null ? null : _save,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(
                      featureText(context, vi: 'Lưu PIN', en: 'Save PIN'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
