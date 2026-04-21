import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/camino_app_bar.dart';
import '../../../shared/widgets/camino_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaminoAppBar(
        title: 'Settings',
        showNotification: false,
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          CaminoCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.language,
                  title: 'Language',
                  value: 'English',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _SettingsRow(
                  icon: Icons.notifications_active,
                  title: 'Notifications',
                  onTap: () {},
                ),
                const Divider(height: 1),
                _SettingsRow(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () => context.push('/help'),
                ),
                const Divider(height: 1),
                _SettingsRow(
                  icon: Icons.info_outline,
                  title: 'About CAMINO',
                  onTap: () => context.push('/about'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) Text(value!),
          if (value != null) const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}

