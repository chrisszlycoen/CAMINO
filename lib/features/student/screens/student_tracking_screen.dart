import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/camino_app_bar.dart';
import '../../../shared/widgets/camino_card.dart';
import '../../../shared/widgets/mock_map_background.dart';
import '../../../data/mock_data.dart';

class StudentTrackingScreen extends StatelessWidget {
  const StudentTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trip = MockData.nextTrip;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CaminoAppBar(
        title: 'Live Tracking',
        leading: Container(
          decoration: BoxDecoration(color: AppColors.backgroundDark.withOpacity(0.8), shape: BoxShape.circle),
          child: const BackButton(),
        ),
      ),
      body: Stack(
        children: [
          // Map Background
          const Positioned.fill(
            child: const MockMapBackground(),
          ),
          
          // Route path placeholder (simulated)
          Center(
            child: Icon(Icons.directions_bus, color: AppColors.primary, size: 48),
          ),
          
          // Bottom Info Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.md),
              padding: const EdgeInsets.only(bottom: 80), // Space for bottom nav
              child: CaminoCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(trip.bus.id, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: const Text('En Route', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.textSecondaryDark, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Text('Current Stop: ${trip.fromStop}'),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ETA', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                            const Text('5 min', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Distance', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                            const Text('1.2 km', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Speed', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                            const Text('35 km/h', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
