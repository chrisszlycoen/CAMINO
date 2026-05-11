import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/admin_stats_card.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/theme/app_colors.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.backgroundDark : const Color(0xFFF5F5F7);
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          AdminPageHeader(title: 'Settings', subtitle: 'System configuration'),
          const SizedBox(height: 24),

          // Profile section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (user?.name ?? 'A')[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.name ?? 'Admin', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textColor)),
                      Text(user?.email ?? '', style: TextStyle(color: secondaryColor)),
                      Text('Role: Administrator', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('Edit Profile'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // System settings
          _buildSection(context, 'System Settings', [
            _SettingTile(icon: Icons.language, title: 'Language', value: 'English', onTap: () {}),
            _SettingTile(icon: Icons.notifications_active, title: 'Push Notifications', value: 'Enabled', onTap: () {}),
            _SettingTile(icon: Icons.sms, title: 'SMS Gateway', value: 'MTN Rwanda • Active', onTap: () {}),
            _SettingTile(icon: Icons.payment, title: 'Payment Gateway', value: 'MTN MoMo • Airtel', onTap: () {}),
          ]),
          const SizedBox(height: 24),

          // Notification preferences
          _buildSection(context, 'Notification Preferences', [
            _buildSwitchTile(context, 'Boarding Confirmation', 'Parent receives SMS when child boards', true),
            _buildSwitchTile(context, 'Delay Alerts', 'Notify when bus is delayed > 10 min', true),
            _buildSwitchTile(context, 'Payment Reminders', 'Send reminder before fee due date', false),
            _buildSwitchTile(context, 'Emergency Broadcasts', 'Push alerts for critical incidents', true),
          ]),
          const SizedBox(height: 24),

          // Data management
          _buildSection(context, 'Data Management', [
            _SettingTile(icon: Icons.download, title: 'Export Users CSV', onTap: () {}),
            _SettingTile(icon: Icons.assessment, title: 'Generate Reports', onTap: () {}),
            _SettingTile(icon: Icons.backup, title: 'Backup Data', subtitle: 'Last backup: Today 03:00 AM', onTap: () {}),
          ]),
          const SizedBox(height: 24),

          // Danger zone
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Danger Zone', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.error)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
                        title: const Text('Reset System?'),
                        content: const Text('This will clear all data. This action cannot be undone.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Reset Everything')),
                        ],
                      ));
                    },
                    icon: const Icon(Icons.warning, color: AppColors.error),
                    label: const Text('Reset All Data', style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.surfaceDark : Colors.white;

    return Container(
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, letterSpacing: 0.5)),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, String title, String subtitle, bool value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
                Text(subtitle, style: TextStyle(color: secondaryColor, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: value, onChanged: (v) {}, activeColor: AppColors.primary),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingTile({required this.icon, required this.title, this.value, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimaryLight;
    final secondaryColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: textColor)),
      subtitle: subtitle != null ? Text(subtitle!, style: TextStyle(color: secondaryColor, fontSize: 12)) : null,
      trailing: value != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value!, style: TextStyle(color: secondaryColor)),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondaryDark),
              ],
            )
          : const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondaryDark),
      onTap: onTap,
    );
  }
}
