import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/camino_app_bar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../data/mock_data.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;
    final trip = MockData.nextTrip;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CaminoAppBar(
        title: 'Boarding Pass',
        subtitle: 'STUDENT TRANSPORT',
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          radius: 18,
          child: Icon(Icons.person, color: Colors.white, size: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.sm,
          bottom: 120, // Space for bottom nav
        ),
        child: Column(
          children: [
            // Apple Wallet Style Boarding Pass
            Container(
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 30,
                    offset: Offset(0, 15),
                  )
                ],
              ),
              child: ClipPath(
                clipper: _TicketClipper(),
                child: Container(
                  width: double.infinity,
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  child: Column(
                    children: [
                      // Top Section: Route
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _RouteNode('KGL', trip.fromStop),
                                const Icon(Icons.flight_takeoff, color: Colors.white54), // Bus icon? Transport
                                _RouteNode('SCH', trip.toStop, isRight: true),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _InfoBlock('DATE', 'Today, ${trip.time}'),
                                _InfoBlock('BUS', trip.bus.id, isRight: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Middle Section: Passenger & QR
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('PASSENGER', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                    const SizedBox(height: 4),
                                    Text(user.name.toUpperCase(), style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimaryLight, fontWeight: FontWeight.w800, fontSize: 18)),
                                    const SizedBox(height: 12),
                                    Text('STATUS', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                    const SizedBox(height: 4),
                                    const StatusBadge(label: 'READY TO BOARD', status: BadgeStatus.success),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: QrImageView(
                                    data: user.id,
                                    version: QrVersions.auto,
                                    size: 100,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                          ],
                        ),
                      ),
                      
                      const _DashedSeparator(),
                      
                      // Bottom Section: Action or Info

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                        child: Center(
                          child: Text(
                            'VALID FOR BOARDING',
                            style: TextStyle(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            const SizedBox(height: AppSpacing.lg),
            
            // Uber-Style Vertical Timeline
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'LIVE ROUTE',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            _TimelineNode(title: trip.fromStop, time: trip.time, isCompleted: true, isFirst: true),
            _TimelineNode(title: 'Amahoro Stadium Hub', time: '06:45 AM', isCompleted: true),
            _TimelineNode(title: 'Kigali Heights', time: '07:05 AM', isActive: true),
            _TimelineNode(title: trip.toStop, time: '07:30 AM (ETA)', isLast: true),
          ],
        ),
      ),
    );
  }
}

class _RouteNode extends StatelessWidget {
  final String code;
  final String name;
  final bool isRight;

  const _RouteNode(this.code, this.name, {this.isRight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          code,
          style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1),
        ),
        Text(
          name,
          style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final bool isRight;

  const _InfoBlock(this.label, this.value, {this.isRight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _DashedSeparator extends StatelessWidget {
  const _DashedSeparator();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 8.0;
        const dashHeight = 2.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? AppColors.borderDark : AppColors.borderLight),
              ),
            );
          }),
        );
      },
    );
  }
}

class _TimelineNode extends StatelessWidget {
  final String title;
  final String time;
  final bool isCompleted;
  final bool isActive;
  final bool isFirst;
  final bool isLast;

  const _TimelineNode({
    required this.title,
    required this.time,
    this.isCompleted = false,
    this.isActive = false,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final surfaceElevated = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Time
        SizedBox(
          width: 70,
          child: Text(
            time.split(' ')[0], 
            style: TextStyle(
              color: isActive ? textPrimary : textSecondary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
        // Middle Column: Line and Dot
        Column(
          children: [
            Container(
              width: 2,
              height: isFirst ? 16 : 0,
              color: Colors.transparent,
            ),
            Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.primary : (isCompleted ? AppColors.primaryLight : surfaceElevated),
                border: Border.all(
                  color: isActive ? Colors.transparent : (isCompleted ? Colors.transparent : border),
                  width: 2,
                ),
                boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.5), blurRadius: 8)] : null,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.primaryLight : border,
              ),
          ],
        ),
        // Right Column: Title
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? textPrimary : (isCompleted ? textPrimary : textSecondary),
                fontWeight: isActive ? FontWeight.w800 : (isCompleted ? FontWeight.w600 : FontWeight.w500),
                fontSize: isActive ? 16 : 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const cornerRadius = 24.0;
    const notchRadius = 16.0;
    final notchY = size.height - 50.0; // Position of the dashed line separator

    // Start at top-left
    path.moveTo(0, cornerRadius);
    path.arcToPoint(const Offset(cornerRadius, 0), radius: const Radius.circular(cornerRadius), clockwise: true);
    
    // Top to top-right
    path.lineTo(size.width - cornerRadius, 0);
    path.arcToPoint(Offset(size.width, cornerRadius), radius: const Radius.circular(cornerRadius), clockwise: true);
    
    // Right side down to notch
    path.lineTo(size.width, notchY - notchRadius);
    path.arcToPoint(
      Offset(size.width, notchY + notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false, // Cut inward
    );
    
    // Right notch down to bottom-right
    path.lineTo(size.width, size.height - cornerRadius);
    path.arcToPoint(Offset(size.width - cornerRadius, size.height), radius: const Radius.circular(cornerRadius), clockwise: true);
    
    // Bottom to bottom-left
    path.lineTo(cornerRadius, size.height);
    path.arcToPoint(Offset(0, size.height - cornerRadius), radius: const Radius.circular(cornerRadius), clockwise: true);
    
    // Left side up to notch
    path.lineTo(0, notchY + notchRadius);
    path.arcToPoint(
      Offset(0, notchY - notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false, // Cut inward
    );
    
    // Left notch up to top-left
    path.lineTo(0, cornerRadius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
