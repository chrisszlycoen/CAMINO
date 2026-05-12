import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/camino_button.dart';
import '../../../shared/widgets/camino_text_field.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSetup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('Not authenticated');

      final supabase = Supabase.instance.client;
      final updates = <String, dynamic>{};

      if (user.requiresNameChange && _nameController.text.trim().isNotEmpty) {
        updates['name'] = _nameController.text.trim();
        updates['requires_name_change'] = false;
      }

      if (user.requiresPasswordChange && _passwordController.text.isNotEmpty) {
        await supabase.auth.updateUser(UserAttributes(
          password: _passwordController.text,
        ));
        updates['requires_password_change'] = false;
      }

      if (updates.isNotEmpty) {
        await supabase.from('profiles').update(updates).eq('id', user.id);
      }

      if (!mounted) return;

      final updatedUser = user.copyWith(
        name: updates['name'] as String? ?? user.name,
        requiresPasswordChange: false,
        requiresNameChange: false,
      );

      ref.read(authServiceProvider).login(updatedUser.email, _passwordController.text.isNotEmpty
          ? _passwordController.text
          : '');
      if (mounted) context.go('/admin/dashboard');
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    if (user == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.directions_bus, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Complete Your Setup',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1.5, height: 1.1),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Set your name and password before continuing.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: subtitleColor, fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 48),

                  if (user.requiresNameChange) ...[
                    CaminoTextField(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      prefixIcon: Icons.person_outline,
                      controller: _nameController,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  if (user.requiresPasswordChange) ...[
                    CaminoTextField(
                      label: 'New Password',
                      hint: 'Min. 6 characters',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscurePassword,
                      controller: _passwordController,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    CaminoTextField(
                      label: 'Confirm Password',
                      hint: 'Repeat your password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _obscureConfirm,
                      controller: _confirmPasswordController,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) {
                        if (_passwordController.text != v) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w500)),
                    ),

                  CaminoButton(
                    label: 'Complete Setup',
                    onPressed: _handleSetup,
                    isLoading: _isLoading,
                    icon: Icons.check_circle_outline,
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
