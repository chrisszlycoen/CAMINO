import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/mock_data.dart';
import '../../../shared/widgets/camino_app_bar.dart';

class ParentAlertsScreen extends StatelessWidget {
  const ParentAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = MockData.notifications;

    return Scaffold(
      appBar: const CaminoAppBar(
        title: 'Alerts',
        showNotification: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: items.map((n) {
          final cfg = _categoryConfig(n.category);
          return _AlertTile(
            title: n.title,
            message: n.message,
            time: n.timeLabel,
            icon: cfg.icon,
            color: cfg.color,
            isNew: n.isUnread,
            onTap: () => context.push('/parent/alerts/${n.id}'),
          );
        }).toList(),
      ),
    );
  }
}

({IconData icon, Color color}) _categoryConfig(String category) {
  switch (category) {
    case 'bus':
      return (icon: Icons.directions_bus, color: AppColors.primary);
    case 'payment':
      return (icon: Icons.payment, color: AppColors.success);
    case 'schedule':
      return (icon: Icons.schedule, color: AppColors.warning);
    default:
      return (icon: Icons.notifications, color: AppColors.info);
  }
}

class _AlertTile extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  final bool isNew;
  final VoidCallback onTap;

  const _AlertTile({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    required this.onTap,
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
      decoration: BoxDecoration(
        color: isNew ? color.withValues(alpha: 0.05) : bgColor,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: isNew ? color.withValues(alpha: 0.3) : borderColor,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusMd,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
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
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            time,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.normal,
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
          ),
        ),
      ),
    );
  }
}

