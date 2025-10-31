import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/camino_button.dart';
import '../../../shared/widgets/camino_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isLoading = false;
  bool _isSent = false;
  final TextEditingController _emailController = TextEditingController();

  void _handleReset() {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);
    
    // Simulate network delay
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isSent = true;
      });
    });
  }

  @override
  void dispose() {

    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: BackButton(
          color: textColor,
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              const SizedBox(height: AppSpacing.xl),
              
              // Logo
              Image.asset(
                isDark ? 'assets/images/caminodark.png' : 'assets/images/camino.png',
                height: 64,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Hero Typography
              Text(
                'Password Recovery.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _isSent 
                    ? 'Check your inbox for a reset link.'
                    : 'Enter your email address to receive password reset instructions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 56),
              
              if (!_isSent) ...[
                CaminoTextField(
                  label: 'Email Address',
                  hint: 'name@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                const SizedBox(height: 48),
                CaminoButton(
                  label: 'Send Instructions',
                  onPressed: _handleReset,
                  isLoading: _isLoading,
                  icon: Icons.mark_email_read_outlined,
                ),
              ] else ...[
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 80,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                CaminoButton(
                  label: 'Return to Login',
                  onPressed: () => context.pop(),
                  type: CaminoButtonType.outline,
                ),
              ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
