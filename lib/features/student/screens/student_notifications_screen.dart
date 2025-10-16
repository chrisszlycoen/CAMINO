import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/camino_app_bar.dart';

class StudentNotificationsScreen extends StatelessWidget {
  const StudentNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CaminoAppBar(
        title: 'Notifications',
        showNotification: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _NotificationTile(
            title: 'Bus #12 is arriving',
            message: 'Your bus will reach Gishushu Stop in 5 mins.',
            time: 'Just now',
            icon: Icons.directions_bus,
            color: AppColors.primary,
            isNew: true,
          ),
          _NotificationTile(
            title: 'Payment Received',
            message: 'Term 3 transport fee has been received.',
            time: '2 days ago',
            icon: Icons.check_circle,
            color: AppColors.success,
          ),
          _NotificationTile(
            title: 'Schedule Change',
            message: 'Tomorrow\'s afternoon trip #13 is delayed by 15 mins.',
            time: 'Oct 23',
            icon: Icons.schedule,
            color: AppColors.warning,
          ),
          _NotificationTile(
            title: 'New Gamification Badge!',
            message: 'You earned the "Punctual Penguin" badge for 10 straight days of on-time boarding.',
            time: 'Oct 20',
            icon: Icons.military_tech,
            color: AppColors.secondary,
          ),
        ], 
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  final bool isNew;

  const _NotificationTile({
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

