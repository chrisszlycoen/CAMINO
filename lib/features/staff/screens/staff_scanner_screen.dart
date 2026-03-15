import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/camino_app_bar.dart';

class StaffScannerScreen extends StatelessWidget {
  const StaffScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceElevated = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final shadow = isDark ? [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 10)] : AppColors.premiumShadowLight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CaminoAppBar(
        title: 'Scan Pass',
        showNotification: false,
      ),
      body: Stack(
        children: [
          // Camera Placeholder Background
          Container(
            color: Colors.black87,
            child: const Center(
              child: Text('CAMERA VIEWFINDER', style: TextStyle(color: Colors.white54, letterSpacing: 2)),
            ),
          ),
          
          // Scanner Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, color: AppColors.primary.withValues(alpha: 0.5), size: 100),
                ],
              ),
            ),
          ),
          
          // Scanning Line Animation (Simulated)
          Center(
            child: Container(
              width: 250,
              height: 3,
              color: AppColors.primary,
              margin: const EdgeInsets.only(bottom: 150), // Positioned halfway up the box
            ),
          ),

          // Instructions Floating Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 100, left: AppSpacing.md, right: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: surfaceElevated,
                borderRadius: AppSpacing.borderRadiusMd,
                boxShadow: shadow,
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: textSecondary),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text('Align the student\'s QR code within the frame to scan automatically.', style: TextStyle(color: textColor)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
