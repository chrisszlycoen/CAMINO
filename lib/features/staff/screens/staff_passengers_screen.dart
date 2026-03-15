import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/camino_app_bar.dart';
import '../../../shared/widgets/status_badge.dart';

class StaffPassengersScreen extends StatelessWidget {
  const StaffPassengersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceElevated = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      appBar: const CaminoAppBar(
        title: 'Passengers',
        subtitle: 'Bus #12 • Route A',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Search by name or ID...',
                hintStyle: TextStyle(color: textSecondary),
                prefixIcon: Icon(Icons.search, color: textSecondary),
                filled: true,
                fillColor: surfaceElevated,
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusLg,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('32 / 45 Boarded', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                DropdownButton<String>(
                  value: 'All',
                  dropdownColor: surfaceElevated,
                  style: TextStyle(color: textColor),
                  items: [
                    DropdownMenuItem(value: 'All', child: Text('All', style: TextStyle(color: textColor))),
                    DropdownMenuItem(value: 'Boarded', child: Text('Boarded', style: TextStyle(color: textColor))),
                    DropdownMenuItem(value: 'Missing', child: Text('Missing', style: TextStyle(color: textColor))),
                  ],
                  onChanged: (v) {},
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _PassengerTile(name: 'Jean Ndikumana', id: 'RW-STU-104', stop: 'Gishushu', isBoarded: true),
                _PassengerTile(name: 'Mia Thompson', id: 'RW-STU-105', stop: 'Gishushu', isBoarded: true),
                _PassengerTile(name: 'Noah Davis', id: 'RW-STU-106', stop: 'Gishushu', isBoarded: true),
                _PassengerTile(name: 'Alex Roberts', id: 'RW-STU-110', stop: 'Kacyiru', isBoarded: false),
                _PassengerTile(name: 'Sarah Lee', id: 'RW-STU-112', stop: 'Kacyiru', isBoarded: false),
                _PassengerTile(name: 'Daniel Kim', id: 'RW-STU-115', stop: 'Nyabugogo', isBoarded: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PassengerTile extends StatelessWidget {
  final String name;
  final String id;
  final String stop;
  final bool isBoarded;

  const _PassengerTile({required this.name, required this.id, required this.stop, required this.isBoarded});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceElevated = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: surfaceElevated,
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isBoarded ? AppColors.success.withValues(alpha: 0.2) : surface,
          child: Icon(
            isBoarded ? Icons.check : Icons.person,
            color: isBoarded ? AppColors.success : textSecondary,
          ),
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.w600, color: isBoarded ? textColor : textSecondary)),
        subtitle: Text('$id • $stop', style: TextStyle(color: isBoarded ? textSecondary : textSecondary.withValues(alpha: 0.5))),
        trailing: isBoarded 
            ? const StatusBadge(label: 'Boarded', status: BadgeStatus.success, isOutline: true)
            : const StatusBadge(label: 'Waiting', status: BadgeStatus.warning, isOutline: true),
      ),
    );
  }
}
