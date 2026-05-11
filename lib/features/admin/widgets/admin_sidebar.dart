import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/auth_provider.dart';

enum AdminPage {
  dashboard('Dashboard', Icons.dashboard_outlined, Icons.dashboard),
  users('Users', Icons.people_outline, Icons.people),
  buses('Buses', Icons.directions_bus_outlined, Icons.directions_bus),
  routes('Routes', Icons.map_outlined, Icons.map),
  schedules('Schedules', Icons.schedule_outlined, Icons.schedule),
  analytics('Analytics', Icons.analytics_outlined, Icons.analytics),
  alerts('Alerts', Icons.warning_amber_outlined, Icons.warning_amber),
  settings('Settings', Icons.settings_outlined, Icons.settings);

  final String label;
  final IconData icon;
  final IconData activeIcon;
  const AdminPage(this.label, this.icon, this.activeIcon);
}

class AdminSidebar extends ConsumerWidget {
  final AdminPage currentPage;
  final ValueChanged<AdminPage> onPageChanged;

  const AdminSidebar({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFF0A3D2F);
    final selectedColor = isDark ? const Color(0xFF16213E) : Colors.white.withValues(alpha: 0.15);

    return Container(
      width: 260,
      color: bgColor,
      child: Column(
        children: [
          // Logo area
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.directions_bus, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CAMINO', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    Text('Admin Portal', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white12, height: 1),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: AdminPage.values.map((page) {
                final isSelected = page == currentPage;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onPageChanged(page),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? selectedColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? page.activeIcon : page.icon,
                            color: isSelected ? Colors.white : Colors.white60,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            page.label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // User info at bottom
          const Divider(color: Colors.white12, height: 1),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    (authUser?.name ?? 'A')[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(authUser?.name ?? 'Admin', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(authUser?.email ?? '', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white54, size: 18),
                  onPressed: () async {
                    await ref.read(authServiceProvider).logout();
                    if (context.mounted) context.go('/admin/login');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
