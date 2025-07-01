import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

enum CaminoButtonType { primary, secondary, outline, text }

class CaminoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final CaminoButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const CaminoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.type = CaminoButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        else if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Icon(icon, size: 20),
          ),
        Text(label),
      ],
    );

    Widget button;
    switch (type) {
      case CaminoButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory, // Clean iOS style
          ),
          child: buttonContent,
        );
        break;
      case CaminoButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
            foregroundColor: isDark ? Colors.white : AppColors.textPrimaryLight,
            elevation: 0,
            shadowColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight, 
              width: 1
            ),
          ),
          child: buttonContent,
        );
        break;
      case CaminoButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
            side: BorderSide(color: isDark ? AppColors.primaryLight : AppColors.primary, width: 2.0),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            splashFactory: NoSplash.splashFactory,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: buttonContent,
        );
        break;
      case CaminoButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: isDark ? AppColors.primaryLight : AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            splashFactory: NoSplash.splashFactory,
          ),
          child: buttonContent,
        );
        break;
    }

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

