import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/camino_app_bar.dart';
import '../../../shared/widgets/camino_card.dart';
import '../../../shared/widgets/camino_button.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../data/mock_data.dart';

class ParentProfileScreen extends ConsumerWidget {
  const ParentProfileScreen({super.key});

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
                    backgroundColor: AppColors.info,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Sarah Ndikumana',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    '+250 788 123 456',
                    style: TextStyle(color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Linked Children Title
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Linked Children', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: AppSpacing.sm),
            CaminoCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(MockData.currentUser.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${MockData.currentUser.school} - ${MockData.currentUser.grade}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Settings List
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
                  _SettingsListItem(icon: Icons.language, title: 'Language', value: 'English', onTap: () {}),
                  Divider(height: 1, color: dividerColor, thickness: 0.5),
                  _SettingsListItem(icon: Icons.notifications_active, title: 'Notification Preferences', onTap: () {}),
                  Divider(height: 1, color: dividerColor, thickness: 0.5),
                  _SettingsListItem(icon: Icons.contact_support, title: 'Contact Support', onTap: () {}),
                  Divider(height: 1, color: dividerColor, thickness: 0.5),
                  _SettingsListItem(icon: Icons.privacy_tip, title: 'Privacy Policy', onTap: () {}),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            CaminoButton(
              label: 'Logout',
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

class _SettingsListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  const _SettingsListItem({
    required this.icon,
    required this.title,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) Text(value!, style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
          if (value != null) const SizedBox(width: AppSpacing.sm),
          Icon(Icons.chevron_right, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}

