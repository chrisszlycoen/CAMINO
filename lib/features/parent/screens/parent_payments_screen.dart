import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/camino_app_bar.dart';
import '../../../shared/widgets/camino_card.dart';
import '../../../shared/widgets/camino_button.dart';
import '../../../shared/widgets/status_badge.dart';

class ParentPaymentsScreen extends StatelessWidget {
  const ParentPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CaminoAppBar(
        title: 'Payments',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CaminoCard(
              backgroundColor: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Balance', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: AppSpacing.xs),
                  const Text('RWF 0', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.md),
                  const StatusBadge(label: 'UP TO DATE', status: BadgeStatus.success),
                  const SizedBox(height: AppSpacing.lg),
                  CaminoButton(
                    label: 'Pay Term 4 Fees',
                    type: CaminoButtonType.secondary,
                    icon: Icons.payment,
                    onPressed: () {}, 
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            const Text('Payment History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: AppSpacing.md),
            
            _PaymentTile(
              title: 'Term 3 Transport Fee',
              date: 'Oct 15, 2026',
              amount: 'RWF 45,000',
              method: 'MTN Mobile Money',
              status: 'Completed',
            ),
            _PaymentTile(
              title: 'Term 2 Transport Fee',
              date: 'May 10, 2026',

              amount: 'RWF 45,000',
              method: 'MTN Mobile Money',
              status: 'Completed',
            ),
            _PaymentTile(
              title: 'Term 1 Transport Fee',
              date: 'Jan 05, 2026',
              amount: 'RWF 45,000',
              method: 'Airtel Money',
              status: 'Completed',
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final String status;
  final String method;

  const _PaymentTile({
    required this.title,
    required this.date,
    required this.amount,
    required this.method,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: CaminoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date, style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

