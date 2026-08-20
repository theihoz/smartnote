import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_theme.dart';
import '../../../app/providers.dart';
import '../../../l10n/feature_text.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  String? _statusMessage;
  bool _isSuccessMessage = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final service = ref.read(syncAuthServiceProvider);

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      await service.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      context.go('/');
    } catch (error) {
      setState(() {
        _isSuccessMessage = false;
        _statusMessage = featureText(
          context,
          vi: 'Đăng nhập thất bại: Kiểm tra lại thông tin hoặc kết nối mạng.',
          en: 'Authentication failed: Please check credentials or network.',
        );
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    final service = ref.read(syncAuthServiceProvider);
    setState(() => _isLoading = true);
    await service.signOut();
    if (mounted) {
      setState(() {
        _isLoading = false;
        _statusMessage = null;
        _emailController.clear();
        _passwordController.clear();
      });
    }
  }

  void _showForgotPasswordDialog() {
    final controller = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.lock_reset_rounded, color: AppTheme.indigo),
            const SizedBox(width: 8),
            Text(featureText(context, vi: 'Đặt lại mật khẩu', en: 'Reset password')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              featureText(
                context,
                vi: 'Nhập email của bạn để nhận liên kết khôi phục mật khẩu:',
                en: 'Enter your email address to receive a reset link:',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(featureText(context, vi: 'Hủy', en: 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = controller.text.trim();
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      featureText(
                        context,
                        vi: 'Vui lòng nhập một địa chỉ email hợp lệ.',
                        en: 'Please enter a valid email address.',
                      ),
                    ),
                  ),
                );
                return;
              }

              try {
                await ref
                    .read(syncAuthServiceProvider)
                    .sendPasswordResetEmail(email: email);
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.indigo,
                    content: Text(
                      featureText(
                        context,
                        vi: 'Đã gửi liên kết khôi phục mật khẩu tới $email',
                        en: 'Password reset link sent to $email',
                      ),
                    ),
                  ),
                );
              } catch (_) {
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      featureText(
                        context,
                        vi: 'Không thể gửi email khôi phục. Vui lòng thử lại.',
                        en: 'Could not send the reset email. Please try again.',
                      ),
                    ),
                  ),
                );
              }
            },
            child: Text(featureText(context, vi: 'Gửi yêu cầu', en: 'Send request')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authService = ref.watch(syncAuthServiceProvider);
    final currentUserEmail = authService.currentEmail;
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colors.primaryContainer.withValues(alpha: 0.34),
                colors.surface,
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: isWide && currentUserEmail == null
                    ? Row(
                        children: [
                          const Expanded(child: _AuthBrandPanel()),
                          const SizedBox(width: 28),
                          Expanded(child: _buildAuthCard(context, colors)),
                        ],
                      )
                    : ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: currentUserEmail != null && currentUserEmail.isNotEmpty
                            ? _buildLoggedInCard(context, currentUserEmail)
                            : _buildAuthCard(context, colors),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoggedInCard(BuildContext context, String email) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.peach,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 48,
                color: AppTheme.coral,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              email,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.mint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_done_rounded, size: 16, color: Colors.teal),
                  const SizedBox(width: 6),
                  Text(
                    featureText(
                      context,
                      vi: 'Đã kết nối đồng bộ đám mây',
                      en: 'Cloud Sync Connected',
                    ),
                    style: const TextStyle(
                      color: Colors.teal,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              featureText(
                context,
                vi: 'Tất cả ghi chú của bạn được bảo mật và sao lưu tự động trên hệ thống SmartNote Cloud.',
                en: 'All your notes are secured and auto-backed up on SmartNote Cloud.',
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.coral),
                  foregroundColor: AppTheme.coral,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isLoading ? null : _signOut,
                icon: const Icon(Icons.logout_rounded),
                label: Text(
                  featureText(context, vi: 'Đăng xuất tài khoản', en: 'Sign Out'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthCard(BuildContext context, ColorScheme colors) {
    final theme = Theme.of(context);
    return Card(
      color: colors.surfaceContainerLowest,
      shadowColor: colors.primary.withValues(alpha: 0.16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.edit_note_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SmartNote', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      Text(featureText(context, vi: 'Ghi chú thông minh', en: 'Smart notes'), style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                featureText(context, vi: 'Chào mừng trở lại', en: 'Welcome back'),
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 7),
              Text(
                featureText(context, vi: 'Đăng nhập bằng email để tiếp tục với ghi chú của bạn.', en: 'Sign in with your email to continue to your notes.'),
                style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant, height: 1.35),
              ),
              const SizedBox(height: 24),

              // Email Text Field
              TextFormField(
                key: const Key('auth-email'),
                controller: _emailController,
                focusNode: _emailFocusNode,
                autofocus: true,
                enabled: !_isLoading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
                decoration: InputDecoration(
                  labelText: featureText(context, vi: 'Địa chỉ email', en: 'Email address'),
                  hintText: 'you@example.com',
                  prefixIcon: const Icon(Icons.email_outlined),
                  suffixIcon: _emailController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => setState(() => _emailController.clear()),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return featureText(
                      context,
                      vi: 'Vui lòng nhập Email',
                      en: 'Please enter your Email',
                    );
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                    return featureText(
                      context,
                      vi: 'Định dạng Email không hợp lệ',
                      en: 'Invalid Email format',
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Password Text Field
              TextFormField(
                key: const Key('auth-password'),
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                enabled: !_isLoading,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: featureText(context, vi: 'Mật khẩu', en: 'Password'),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return featureText(
                      context,
                      vi: 'Vui lòng nhập Mật khẩu',
                      en: 'Please enter Password',
                    );
                  }
                  if (value.length < 6) {
                    return featureText(
                      context,
                      vi: 'Mật khẩu phải từ 6 ký tự trở lên',
                      en: 'Password must be at least 6 characters',
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Options Row: Remember Me & Forgot Password
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (val) => setState(() => _rememberMe = val ?? true),
                    activeColor: colors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Text(
                    featureText(context, vi: 'Ghi nhớ', en: 'Remember'),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _showForgotPasswordDialog,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      featureText(
                        context,
                        vi: 'Quên mật khẩu?',
                        en: 'Forgot password?',
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              // Status / Error Banner Message
              if (_statusMessage != null) ...[
                const SizedBox(height: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isSuccessMessage
                        ? AppTheme.mint.withValues(alpha: 0.6)
                        : colors.errorContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccessMessage
                            ? Icons.check_circle_outline_rounded
                            : Icons.error_outline_rounded,
                        color: _isSuccessMessage ? Colors.teal : colors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: TextStyle(
                            color: _isSuccessMessage
                                ? Colors.teal.shade900
                                : colors.onErrorContainer,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Primary Action Submit Button
              SizedBox(
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: colors.primary,
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          featureText(context, vi: 'Đăng nhập bằng email', en: 'Sign in with email'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined, size: 16, color: colors.primary),
                  const SizedBox(width: 6),
                  Text(
                    featureText(context, vi: 'Dữ liệu của bạn được mã hóa và bảo mật.', en: 'Your data is encrypted and secure.'),
                    style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthBrandPanel extends StatelessWidget {
  const _AuthBrandPanel();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 540),
      padding: const EdgeInsets.all(42),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5C5799), AppTheme.indigo],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFFDAD7), size: 30),
          ),
          const Spacer(),
          Text(
            featureText(context, vi: 'Mọi ý tưởng,\nluôn trong tầm tay.', en: 'Every idea,\nalways within reach.'),
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            featureText(
              context,
              vi: 'Đăng nhập để ghi chú, sắp xếp và đồng bộ những điều quan trọng với bạn.',
              en: 'Sign in to capture, organize, and sync what matters to you.',
            ),
            style: theme.textTheme.titleSmall?.copyWith(
              color: const Color(0xFFE9E7FF),
              height: 1.45,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_done_outlined, color: Color(0xFFFFDAD7)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    featureText(context, vi: 'Đồng bộ an toàn trên mọi thiết bị', en: 'Secure sync across your devices'),
                    style: theme.textTheme.bodyMedium?.copyWith(color: colors.onPrimary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
