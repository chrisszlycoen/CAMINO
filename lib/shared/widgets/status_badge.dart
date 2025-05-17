import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

enum BadgeStatus { success, warning, error, info, normal }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeStatus status;
  final bool isOutline;

  const StatusBadge({
    super.key,
    required this.label,
    this.status = BadgeStatus.normal,
    this.isOutline = false,
  });

  Color _getBackgroundColor(ThemeData theme) {
    if (isOutline) return Colors.transparent;
    final isDark = theme.brightness == Brightness.dark;

    switch (status) {
      case BadgeStatus.success:
        return isDark ? AppColors.success.withOpacity(0.2) : AppColors.success.withOpacity(0.1);
      case BadgeStatus.warning:
        return isDark ? AppColors.warning.withOpacity(0.2) : AppColors.warning.withOpacity(0.1);
      case BadgeStatus.error:
        return isDark ? AppColors.error.withOpacity(0.2) : AppColors.error.withOpacity(0.1);
      case BadgeStatus.info:
        return isDark ? AppColors.info.withOpacity(0.2) : AppColors.info.withOpacity(0.1);
      case BadgeStatus.normal:
        return isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;
    }
  }

  Color _getTextColor(ThemeData theme) {
    switch (status) {
      case BadgeStatus.success:
        return AppColors.success;
      case BadgeStatus.warning:
        return AppColors.warning;
      case BadgeStatus.error:
        return AppColors.error;
      case BadgeStatus.info:
        return AppColors.info;
      case BadgeStatus.normal:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = _getTextColor(theme);
    final backgroundColor = _getBackgroundColor(theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
        border: isOutline ? Border.all(color: textColor, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == BadgeStatus.success) ...[
            Container(
              width: 6,
              height: 6, 
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

