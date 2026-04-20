import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

enum CaminoButtonType { primary, secondary, outline, text }

class CaminoButton extends StatelessWidget {
  static const double height = 56;

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

    final Color primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final Color borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final Color textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final Color surfaceElevated = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;

    final TextStyle labelStyle = theme.textTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ) ??
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);

    final EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.md,
    );

    Widget buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                switch (type) {
                  CaminoButtonType.secondary => textPrimary,
                  CaminoButtonType.outline => primaryColor,
                  CaminoButtonType.text => primaryColor,
                  CaminoButtonType.primary => Colors.white,
                },
              ),
            ),
          )
        else if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Icon(icon, size: 20),
          ),
        Text(label, style: labelStyle),
      ],
    );

    Widget button;
    switch (type) {
      case CaminoButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(height),
            padding: contentPadding,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: labelStyle,
            backgroundColor: primaryColor,
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
            minimumSize: const Size.fromHeight(height),
            padding: contentPadding,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: labelStyle,
            backgroundColor: surfaceElevated,
            foregroundColor: textPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            side: BorderSide(
              color: borderColor,
              width: 1,
            ),
          ),
          child: buttonContent,
        );
        break;
      case CaminoButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(height),
            padding: contentPadding,
            textStyle: labelStyle,
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor, width: 2.0),
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
            minimumSize: const Size.fromHeight(height),
            padding: contentPadding,
            textStyle: labelStyle,
            foregroundColor: primaryColor,
            splashFactory: NoSplash.splashFactory,
          ),
          child: buttonContent,
        );
        break;
    }

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

