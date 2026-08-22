import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../application/auth_controller.dart';
import '../data/auth_api_client.dart';
import '../../../l10n/feature_text.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.controller});
  final AuthController controller;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool register = false;
  bool hidePassword = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    try {
      if (register) {
        await widget.controller.register(email.text, password.text);
        if (mounted) context.go('/');
      } else {
        await widget.controller.login(email.text, password.text);
        if (mounted) context.go('/');
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final user = controller.session?.kind == AuthKind.user;
    if (user) return _AccountView(controller: controller);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.primaryContainer.withValues(alpha: .42),
              colors.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: .24),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        size: 40,
                        color: colors.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'SmartNote',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.primary,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      featureText(
                        context,
                        vi: 'Ghi nhanh ý tưởng, đồng bộ mọi lúc.',
                        en: 'Capture ideas and keep them in sync.',
                      ),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 0,
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: .78,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                        side: BorderSide(
                          color: colors.outlineVariant.withValues(alpha: .5),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: AnimatedBuilder(
                          animation: controller,
                          builder: (context, _) => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                register
                                    ? featureText(
                                        context,
                                        vi: 'Tạo tài khoản',
                                        en: 'Create account',
                                      )
                                    : featureText(
                                        context,
                                        vi: 'Chào mừng đến SmartNote',
                                        en: 'Welcome to SmartNote',
                                      ),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                controller: email,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.email],
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: password,
                                obscureText: hidePassword,
                                autofillHints: const [AutofillHints.password],
                                decoration: InputDecoration(
                                  labelText: featureText(
                                    context,
                                    vi: 'Mật khẩu',
                                    en: 'Password',
                                  ),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(
                                      () => hidePassword = !hidePassword,
                                    ),
                                    icon: Icon(
                                      hidePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              if (controller.error != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    controller.error!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              FilledButton(
                                onPressed: controller.busy ? null : submit,
                                child: Text(
                                  controller.busy
                                      ? featureText(
                                          context,
                                          vi: 'Đang xử lý…',
                                          en: 'Please wait…',
                                        )
                                      : register
                                      ? featureText(
                                          context,
                                          vi: 'Đăng ký',
                                          en: 'Register',
                                        )
                                      : featureText(
                                          context,
                                          vi: 'Đăng nhập',
                                          en: 'Sign in',
                                        ),
                                ),
                              ),
                              TextButton(
                                onPressed: controller.busy
                                    ? null
                                    : () =>
                                          setState(() => register = !register),
                                child: Text(
                                  register
                                      ? featureText(
                                          context,
                                          vi: 'Đã có tài khoản? Đăng nhập',
                                          en: 'Already registered? Sign in',
                                        )
                                      : featureText(
                                          context,
                                          vi: 'Chưa có tài khoản? Đăng ký',
                                          en: 'Need an account? Register',
                                        ),
                                ),
                              ),
                              const Divider(height: 28),
                              OutlinedButton.icon(
                                onPressed: controller.busy
                                    ? null
                                    : () async {
                                        try {
                                          await controller.continueAsGuest();
                                          if (context.mounted) context.go('/');
                                        } catch (_) {}
                                      },
                                icon: const Icon(Icons.person_outline),
                                label: Text(
                                  featureText(
                                    context,
                                    vi: 'Tiếp tục với Guest',
                                    en: 'Continue as Guest',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _TeamCredits(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TeamCredits extends StatelessWidget {
  const _TeamCredits();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: .72),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            featureText(context, vi: 'BÀI GIỮA KỲ', en: 'MIDTERM PROJECT'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 6,
            children: [
              Text('Diệp Yến Khoa'),
              Text('Nguyễn Trường Diễm Quỳnh'),
              Text('Trần Thái Hòa'),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountView extends StatelessWidget {
  const _AccountView({required this.controller});
  final AuthController controller;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(featureText(context, vi: 'Tài khoản', en: 'Account')),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(controller.session!.email!),
          subtitle: Text(
            featureText(
              context,
              vi: 'Tài khoản SmartNote',
              en: 'SmartNote account',
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _changePassword(context),
          child: Text(
            featureText(context, vi: 'Đổi mật khẩu', en: 'Change password'),
          ),
        ),
        FilledButton.tonal(
          onPressed: () async {
            await controller.logout();
            if (context.mounted) context.go('/auth');
          },
          child: Text(featureText(context, vi: 'Đăng xuất', en: 'Sign out')),
        ),
      ],
    ),
  );

  Future<void> _changePassword(BuildContext context) async {
    final current = TextEditingController();
    final next = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          featureText(context, vi: 'Đổi mật khẩu', en: 'Change password'),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: current,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: featureText(
                    context,
                    vi: 'Mật khẩu hiện tại',
                    en: 'Current password',
                  ),
                ),
              ),
              TextField(
                controller: next,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: featureText(
                    context,
                    vi: 'Mật khẩu mới',
                    en: 'New password',
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(featureText(context, vi: 'Hủy', en: 'Cancel')),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await controller.changePassword(current.text, next.text);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } catch (_) {}
            },
            child: Text(featureText(context, vi: 'Lưu', en: 'Save')),
          ),
        ],
      ),
    );
    current.dispose();
    next.dispose();
  }
}
