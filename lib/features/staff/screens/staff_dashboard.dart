import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/camino_app_bar.dart';
import '../../../shared/widgets/status_badge.dart';

class StaffDashboard extends StatelessWidget {
  const StaffDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceElevated = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: CaminoAppBar(
        title: 'Morning Shift',
        subtitle: 'BUS #12 • ROUTE A',
        leading: CircleAvatar(
          backgroundColor: surfaceElevated,
          radius: 18,
          child: const Icon(Icons.directions_bus, color: AppColors.primary, size: 18),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // TOP: Massive Circular Capacity Ring
                    Expanded(
                      flex: 5,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const StatusBadge(label: 'BOARDING ACTIVE', status: BadgeStatus.info),
                            const SizedBox(height: AppSpacing.xxl),
                            CircularPercentIndicator(
                              radius: 120.0, 
                              lineWidth: 24.0,
                              animation: true,
                              percent: 32 / 45,
                              circularStrokeCap: CircularStrokeCap.round,
                              progressColor: AppColors.primary,
                              backgroundColor: surfaceElevated,
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Text(
                                      '32',
                                      style: TextStyle(
                                        fontSize: 72,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -2,
                                        color: textPrimary,
                                        height: 1.0,
                                    ),
                                  ),
                                    Text(
                                      '/45 BOARDED',
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 2,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on, color: textSecondary, size: 16),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  'Currently at Amahoro Stadium',
                                  style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // BOTTOM: Massive Tactile "SCAN QR" Area
                    Expanded(
                      flex: 3,
                      child: Material(
                        color: AppColors.primary,
                        child: InkWell(
                          onTap: () {}, // Trigger scanner
                          splashColor: Colors.white24,
                          highlightColor: Colors.white12,
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.qr_code_scanner,
                                    size: 64,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                const Text(
                                  'TAP TO SCAN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 3,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'OPTIMIZED FOR ONE-HANDED USE',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

