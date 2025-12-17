import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/camino_app_bar.dart';
import '../../../shared/widgets/camino_card.dart';
import '../../../shared/widgets/camino_button.dart';
import '../../../core/theme/theme_provider.dart';

class StaffProfileScreen extends ConsumerWidget {
  const StaffProfileScreen({super.key});

  @override 
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      appBar: const CaminoAppBar(
        title: 'Profile',
        showNotification: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            // User Header
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.secondary,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Alex Roberts',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Transport Coordinator',
                    style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Shift Details
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Current Assignment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: AppSpacing.sm),
            CaminoCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ProfileListItem(icon: Icons.directions_bus, title: 'Bus', value: 'Bus #12'),
                  Divider(height: 1, color: dividerColor, thickness: 0.5),
                  _ProfileListItem(icon: Icons.route, title: 'Route', value: 'Route A'),
                  Divider(height: 1, color: dividerColor, thickness: 0.5),
                  _ProfileListItem(icon: Icons.schedule, title: 'Shift', value: '6:30 AM - 9:30 AM'),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // App Settings
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Settings & Info', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: AppSpacing.sm),
            CaminoCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                   Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.dark_mode_outlined, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, size: 24),
                            const SizedBox(width: AppSpacing.md),
                            Text('Dark Mode', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Switch(
                          value: themeMode == ThemeMode.dark || (themeMode == ThemeMode.system && isDark),
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) {
                            ref.read(themeProvider.notifier).setTheme(val ? ThemeMode.dark : ThemeMode.light);
                          },
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: dividerColor, thickness: 0.5),
                  _ProfileListItem(icon: Icons.language, title: 'Language', value: 'English', isEditable: true),
                  Divider(height: 1, color: dividerColor, thickness: 0.5),
                  _ProfileListItem(icon: Icons.wifi_off, title: 'Offline Mode Data Sync', isEditable: true),
                  Divider(height: 1, color: dividerColor, thickness: 0.5),
                  _ProfileListItem(icon: Icons.support_agent, title: 'Dispatch Support', isEditable: true),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            CaminoButton(
              label: 'End Shift & Logout',
              type: CaminoButtonType.outline,
              onPressed: () {
                context.go('/');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final bool isEditable;

  const _ProfileListItem({
    required this.icon,
    required this.title,
    this.value,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) Text(value!, style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          if (value != null) const SizedBox(width: AppSpacing.sm),
          if (isEditable) Icon(Icons.chevron_right, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, size: 20),
        ],
      ),
    );
  }
}

