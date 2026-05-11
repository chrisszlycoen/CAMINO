import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/camino_button.dart';
import '../../../shared/widgets/camino_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final user = await ref.read(authServiceProvider).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      _redirectToRoleHome(user.role);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _redirectToRoleHome(AuthRole role) {
    switch (role) {
      case AuthRole.admin:
        context.go('/admin/dashboard');
        break;
      case AuthRole.student:
        context.go('/student/home');
        break;
      case AuthRole.staff:
        context.go('/staff/home');
        break;
      case AuthRole.parent:
        context.go('/parent/home');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Image.asset(
                    isDark ? 'assets/images/caminodark.png' : 'assets/images/camino.png',
                    height: 64,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Welcome Back.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textColor, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1.5, height: 1.1),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Sign in to your CAMINO account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subtitleColor, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: -0.2),
                  ),
                  const SizedBox(height: 64),
                  CaminoTextField(
                    label: 'Email Address',
                    hint: 'name@example.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  CaminoTextField(
                    label: 'Password',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    controller: _passwordController,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  Center(
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: const Text('Forgot password?', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 48),
                  CaminoButton(label: 'Sign In', onPressed: _handleLogin, isLoading: _isLoading, icon: Icons.arrow_forward_rounded),
                  const SizedBox(height: AppSpacing.xl),
                  Column(
                    children: [
                      Text('Demo accounts:', style: TextStyle(color: subtitleColor, fontSize: 11)),
                      const SizedBox(height: 4),
                      Text('admin@camino.rw / student@camino.rw / staff@camino.rw / parent@camino.rw', textAlign: TextAlign.center, style: TextStyle(color: subtitleColor, fontSize: 10)),
                      Text('Password for all: 123 (or role123)', style: TextStyle(color: subtitleColor, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
