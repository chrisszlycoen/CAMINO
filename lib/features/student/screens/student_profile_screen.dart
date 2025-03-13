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

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = MockData.currentUser;
    final themeMode = ref.watch(themeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

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
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.id,
                    style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Gamification Stats
            Row(
              children: [
                Expanded(
                  child: CaminoCard(
                    child: Column(
                      children: [
                        const Icon(Icons.stars, color: AppColors.secondary, size: 32),
                        const SizedBox(height: AppSpacing.xs),
                        Text('${user.points}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                        Text('Points', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: CaminoCard(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.xs),
                        const Icon(Icons.local_fire_department, color: AppColors.error, size: 32),
                        Text('${user.streakDays}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                        Text('Day Streak', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Details List
            CaminoCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ProfileListItem(icon: Icons.school, title: 'School', value: user.school),
                  Divider(height: 1, color: borderColor.withValues(alpha: 0.5)),
                  _ProfileListItem(icon: Icons.class_, title: 'Grade', value: user.grade),
                  Divider(height: 1, color: borderColor.withValues(alpha: 0.5)),
                  const _ProfileListItem(icon: Icons.language, title: 'Language', value: 'English', isEditable: true),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // App Settings
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
                            Icon(Icons.dark_mode_outlined, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, size: 24),
                            const SizedBox(width: AppSpacing.md),
                            Text('Dark Mode', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Switch(
                          value: themeMode == ThemeMode.dark || (themeMode == ThemeMode.system && Theme.of(context).brightness == Brightness.dark),
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) {
                            ref.read(themeProvider.notifier).setTheme(val ? ThemeMode.dark : ThemeMode.light);
                          },
                        ),
                      ],
                    ),
                  ),
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

class _ProfileListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isEditable;

  const _ProfileListItem({
    required this.icon,
    required this.title,
    required this.value,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : AppColors.textPrimaryLight;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
      child: Row(
        children: [
          Icon(icon, color: textSecondary, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textSecondary, fontSize: 12)),
                Text(value, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: textPrimary)),
              ],
            ),
          ),
          if (isEditable)
            Icon(Icons.chevron_right, color: textSecondary),
        ],
      ),
    );
  }
}
