import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/camino_app_bar.dart';

class ParentAlertsScreen extends StatelessWidget {
  const ParentAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CaminoAppBar(
        title: 'Alerts',
        showNotification: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _AlertTile(
            title: 'Child Boarded',
            message: 'Jean safely boarded Bus #12 at Home Stop.',
            time: '8:05 AM',
            icon: Icons.check_circle,
            color: AppColors.success,
            isNew: true,
          ),
          _AlertTile(
            title: 'Bus Approaching',
            message: 'Bus #12 is 5 minutes away from Home Stop.',
            time: '8:00 AM',
            icon: Icons.near_me,
            color: AppColors.info,
          ),
          _AlertTile(
            title: 'Payment Successful',
            message: 'We received your payment of RWF 45,000 for Term 3.',
            time: 'Oct 15',
            icon: Icons.payment,
            color: AppColors.primary,
          ),
          _AlertTile(
            title: 'Child Arrived at School',
            message: 'Jean safely arrived at Kigali International Community School.',
            time: 'Yesterday',
            icon: Icons.school,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  final bool isNew;

  const _AlertTile({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    this.isNew = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final bgColor = isDark ? Colors.transparent : AppColors.surfaceLight;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isNew ? color.withValues(alpha: 0.05) : bgColor,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: isNew ? color.withValues(alpha: 0.3) : borderColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: isNew ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isNew ? color : textColor,
                        fontWeight: isNew ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor,
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
