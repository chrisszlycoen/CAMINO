import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/camino_app_bar.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../data/mock_data.dart';

class StudentQRPassScreen extends StatelessWidget {
  const StudentQRPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;
    final trip = MockData.nextTrip;

    return Scaffold(
      appBar: const CaminoAppBar(
        title: 'Boarding Pass',
        subtitle: 'Ready to scan',
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppSpacing.borderRadiusLg,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'SCAN TO BOARD',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    QrImageView(
                      data: user.id,
                      version: QrVersions.auto,
                      size: 250,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      user.id,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              
              const StatusBadge(label: 'READY TO BOARD', status: BadgeStatus.success),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Bus ${trip.bus.id} is arriving in 5 mins',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
