import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/camino_button.dart';
import '../../../shared/widgets/camino_text_field.dart';

class LoginScreen extends StatefulWidget {
  final String role; // 'student', 'parent', 'staff'

  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();
    
    setState(() => _isLoading = true);
    
    // Simulate network delay
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // Navigate to respective dashboard
      context.go('/${widget.role}/home');
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    String roleTitle = "Login";
    String roleGreeting = "Welcome Back.";
    
    switch (widget.role) {
      case 'student':
        roleTitle = "Student Portal";
        break;
      case 'parent':
        roleTitle = "Parent Access";
        break;
      case 'staff':
        roleTitle = "Staff Operations";
        roleGreeting = "Ready for shift?";
        break;
    }

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
              
              // Logo
              Image.asset(
                isDark ? 'assets/images/caminodark.png' : 'assets/images/camino.png',
                height: 64,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Hero Typography Section
              Text(
                roleGreeting,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Sign in to your $roleTitle account to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
              
              const SizedBox(height: 64),
              
              // Premium Inputs
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
                obscureText: true,
                controller: _passwordController,
              ),
              
              const SizedBox(height: AppSpacing.md),
              Center(
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Action Area
              CaminoButton(
                label: 'Sign In',
                onPressed: _handleLogin,
                isLoading: _isLoading,
                icon: Icons.arrow_forward_rounded,
              ),
              
              const SizedBox(height: AppSpacing.xl),
              
              CaminoButton(
                label: 'Switch Role',
                type: CaminoButtonType.text,
                onPressed: () => context.pop(),
              ),
              
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    ));
  }
}
