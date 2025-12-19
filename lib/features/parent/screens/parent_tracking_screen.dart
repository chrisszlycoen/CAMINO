import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/camino_app_bar.dart';
import '../../../shared/widgets/camino_card.dart';
import '../../../shared/widgets/mock_map_background.dart';
import '../../../data/mock_data.dart';

class ParentTrackingScreen extends StatelessWidget {
  const ParentTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final child = MockData.currentUser;
    final trip = MockData.nextTrip;

    return Scaffold(
      appBar: CaminoAppBar(
        title: 'Live Tracking',
        subtitle: 'Following ${child.name}',
      ),
      body: Stack(
        children: [
          // Full screen map placeholder
          const Positioned.fill(
            child: const MockMapBackground(),
          ),
          
          // Simulated route
          Center(
            child: IntrinsicWidth(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_bus, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(trip.bus.id, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom Info Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.md),
              child: CaminoCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${child.name} is on ${trip.bus.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const Text('En route to Kigali International Community School', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(height: 1),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(label: 'ETA', value: '12 min'),
                        _StatItem(label: 'Distance', value: '3.4 km'),
                        _StatItem(label: 'Speed', value: '28 km/h'),
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}

