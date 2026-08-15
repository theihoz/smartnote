import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/feature_text.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLoading = false;
  bool _createAccount = false;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final accountCreatedMessage = featureText(
      context,
      vi: 'Đã tạo tài khoản. Hãy kiểm tra email xác nhận.',
      en: 'Account created. Check your email to confirm it.',
    );
    final signedInMessage = featureText(
      context,
      vi: 'Đăng nhập thành công.',
      en: 'Signed in successfully.',
    );
    final signInErrorPrefix = featureText(
      context,
      vi: 'Không thể đăng nhập',
      en: 'Could not sign in',
    );
    final service = ref.read(syncAuthServiceProvider);
    if (service == null) {
      setState(() {
        _message = featureText(
          context,
          vi: 'Supabase chưa được cấu hình cho bản build này.',
          en: 'Supabase is not configured for this build.',
        );
      });
      return;
    }
    if (!_email.text.contains('@') || _password.text.length < 6) {
      setState(() {
        _message = featureText(
          context,
          vi: 'Email hoặc mật khẩu chưa hợp lệ.',
          en: 'Email or password is invalid.',
        );
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      if (_createAccount) {
        await service.signUp(
          email: _email.text.trim(),
          password: _password.text,
        );
        _message = accountCreatedMessage;
      } else {
        await service.signIn(
          email: _email.text.trim(),
          password: _password.text,
        );
        _message = signedInMessage;
      }
    } catch (error) {
      _message = '$signInErrorPrefix: $error';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          featureText(
            context,
            vi: 'Đăng nhập SmartNote',
            en: 'Sign in to SmartNote',
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.cloud_sync_rounded,
                      size: 52,
                      color: colors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _createAccount
                          ? featureText(
                              context,
                              vi: 'Tạo tài khoản đồng bộ',
                              en: 'Create a sync account',
                            )
                          : featureText(
                              context,
                              vi: 'Đồng bộ ghi chú an toàn',
                              en: 'Sync notes securely',
                            ),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      key: const Key('auth-email'),
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('auth-password'),
                      controller: _password,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: featureText(
                          context,
                          vi: 'Mật khẩu',
                          en: 'Password',
                        ),
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                      ),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 12),
                      Text(_message!, style: TextStyle(color: colors.primary)),
                    ],
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: Text(
                        _createAccount
                            ? featureText(
                                context,
                                vi: 'Tạo tài khoản',
                                en: 'Create account',
                              )
                            : featureText(
                                context,
                                vi: 'Đăng nhập',
                                en: 'Sign in',
                              ),
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => setState(
                              () => _createAccount = !_createAccount,
                            ),
                      child: Text(
                        _createAccount
                            ? featureText(
                                context,
                                vi: 'Đã có tài khoản? Đăng nhập',
                                en: 'Already registered? Sign in',
                              )
                            : featureText(
                                context,
                                vi: 'Chưa có tài khoản? Đăng ký',
                                en: 'No account yet? Sign up',
                              ),
                      ),
                    ),
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
