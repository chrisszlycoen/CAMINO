import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/camino_button.dart';
import '../../../shared/widgets/mock_map_background.dart'; // Added import
import '../../../data/mock_data.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final child = MockData.currentUser; // Mock child data
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final shadow = isDark ? [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10)] : AppColors.premiumShadowLight;
    final bgColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    
    return Scaffold(
      body: Stack(
        children: [
          // 1. Edge-to-Edge Map Background Placeholder
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.4, // Map takes up top 60% visually
            child: const MockMapBackground(),
          ),
          
          // Floating overlay: Route path & Bus marker on the map
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: MediaQuery.of(context).size.width * 0.4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: shadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.directions_bus, color: AppColors.primary, size: 24),
                  const SizedBox(width: 8),
                  Text('Bus #12', style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 16)),
                ],
              ),
            ),
          ),
          
          // Floating App Bar (Status Bar + Greeting)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + AppSpacing.md,
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning,',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          shadows: [Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4)],
                        ),
                      ),
                      Text(
                        'Sarah',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),

          // 2. Sculpted Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: borderColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Tracking Status Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tracking',
                            style: TextStyle(
                              fontSize: 24,
                              color: textColor,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('View Route', style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      
                      // Child Carousel (Single item for now)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 28,
                                  backgroundColor: AppColors.primary,
                                  child: Icon(Icons.child_care, color: Colors.white, size: 28),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${child.name} • ${child.grade}', style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.5)),
                                      const SizedBox(height: 4),
                                      const StatusBadge(label: 'ON BOARD', status: BadgeStatus.success),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('ETA', style: TextStyle(color: textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                                    const Text('12m', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.primary)),
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              child: Divider(color: borderColor, height: 1),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 16, color: textSecondary),
                                    const SizedBox(width: 4),
                                    Text('Approaching Kigali Heights', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                Text('28 km/h', style: TextStyle(color: textColor.withValues(alpha: 0.5), fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.xxl),
                      
                      // Quick Actions & Payment
                      Text(
                        'Account & Payments',
                        style: TextStyle(
                          fontSize: 20,
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: borderColor, width: 1),
                          boxShadow: shadow,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Term 3 Balance', style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold)),
                                    Text('45,000 RWF', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: -1)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text('DUE OCT 15', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w800, fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            CaminoButton(
                              label: 'Pay Now with MoMo',
                              onPressed: () {},
                              icon: Icons.account_balance_wallet,
                            ),
                          ],
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
    );
  }
} // Removes trailing _GridPainter

