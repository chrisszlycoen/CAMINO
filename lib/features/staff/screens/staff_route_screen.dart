import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/mock_map_background.dart';
import '../../../shared/widgets/camino_app_bar.dart';

class StaffRouteScreen extends StatelessWidget {
  const StaffRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceElevated = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final shadow = isDark ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)] : AppColors.premiumShadowLight;

    return Scaffold(
      appBar: const CaminoAppBar(
        title: 'Route Overview',
        subtitle: 'Route A',
      ),
      body: Stack(
        children: [
          // Full screen map placeholder
          const Positioned.fill(
            child: const MockMapBackground(),
          ),
          
          // Timeline Overlay

          Align(
            alignment: Alignment.centerLeft,

            child: Container(
              width: 300,
              margin: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: surfaceElevated.withValues(alpha: 0.95),
                borderRadius: AppSpacing.borderRadiusLg,
                boxShadow: shadow,
              ),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                shrinkWrap: true,
                children: [
                  Text('Stops', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor)),
                  const SizedBox(height: AppSpacing.md),
                  const _RouteStopTile(name: 'Home Stop', time: '8:00 AM', status: 'Completed', isFirst: true),
                  const _RouteStopTile(name: 'Gishushu Stop', time: '8:15 AM', status: 'In Progress'),
                  const _RouteStopTile(name: 'Kacyiru', time: '8:25 AM', status: 'Upcoming'),
                  const _RouteStopTile(name: 'Nyabugogo', time: '8:40 AM', status: 'Upcoming'),
                  const _RouteStopTile(name: 'Kigali Int. Community School', time: '9:00 AM', status: 'Upcoming', isLast: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteStopTile extends StatelessWidget {
  final String name;
  final String time;
  final String status;
  final bool isFirst;
  final bool isLast;

  const _RouteStopTile({
    required this.name,
    required this.time,
    required this.status,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = status == 'Completed';
    final bool isInProgress = status == 'In Progress';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimaryLight;
    final Color markerColor = isCompleted ? AppColors.success : (isInProgress ? AppColors.primary : borderColor);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 30,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (!isFirst && !isLast)
                  Container(width: 2, color: isCompleted ? AppColors.success : borderColor),
                if (isFirst)
                  Positioned(bottom: 0, top: 20, child: Container(width: 2, color: AppColors.success)),
                if (isLast)
                  Positioned(top: 0, bottom: 20, child: Container(width: 2, color: borderColor)),
                  
                Container(
                  width: isInProgress ? 16 : 12,
                  height: isInProgress ? 16 : 12,
                  decoration: BoxDecoration(
                    color: markerColor,
                    shape: BoxShape.circle,
                    border: isInProgress ? Border.all(color: Colors.white, width: 2) : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: TextStyle(fontWeight: isInProgress ? FontWeight.bold : FontWeight.w500, color: isInProgress ? textPrimary : textSecondary)),
                  Text(time, style: TextStyle(color: textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
