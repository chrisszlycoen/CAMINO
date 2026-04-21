import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/mock_data.dart';
import '../../../shared/widgets/camino_app_bar.dart';
import '../../../shared/widgets/camino_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/models/models.dart';

enum NotificationAudience { student, parent }

class NotificationDetailScreen extends StatelessWidget {
  final NotificationAudience audience;
  final String notificationId;

  const NotificationDetailScreen({
    super.key,
    required this.audience,
    required this.notificationId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final CaminoNotification? notification = _findNotification(notificationId);

    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: CaminoAppBar(
        title: audience == NotificationAudience.student ? 'Notifications' : 'Alerts',
        showNotification: false,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: notification == null
            ? Center(
                child: Text(
                  'This message is no longer available.',
                  style: theme.textTheme.bodyLarge?.copyWith(color: textSecondary),
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CaminoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          notification.timeLabel,
                          style: theme.textTheme.bodySmall?.copyWith(color: textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          notification.message,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: StatusBadge(
                      label: notification.isUnread ? 'UNREAD' : 'READ',
                      status: notification.isUnread ? BadgeStatus.info : BadgeStatus.normal,
                      isOutline: notification.isUnread,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  static CaminoNotification? _findNotification(String id) {
    for (final n in MockData.notifications) {
      if (n.id == id) return n;
    }
    return null;
  }
}

