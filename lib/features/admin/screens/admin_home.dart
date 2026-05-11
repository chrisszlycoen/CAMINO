import 'package:flutter/material.dart';
import '../widgets/admin_sidebar.dart';
import 'admin_login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'admin_users_screen.dart';
import 'admin_buses_screen.dart';
import 'admin_routes_screen.dart';
import 'admin_schedules_screen.dart';
import 'admin_analytics_screen.dart';
import 'admin_alerts_screen.dart';
import 'admin_settings_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_provider.dart';

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  AdminPage _currentPage = AdminPage.dashboard;

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return const AdminLoginScreen();
    }

    final screen = _buildScreen();

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            AdminSidebar(
              currentPage: _currentPage,
              onPageChanged: (page) => setState(() => _currentPage = page),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: screen),
          ],
        ),
      ),
    );
  }

  Widget _buildScreen() {
    switch (_currentPage) {
      case AdminPage.dashboard:
        return const AdminDashboardScreen();
      case AdminPage.users:
        return const AdminUsersScreen();
      case AdminPage.buses:
        return const AdminBusesScreen();
      case AdminPage.routes:
        return const AdminRoutesScreen();
      case AdminPage.schedules:
        return const AdminSchedulesScreen();
      case AdminPage.analytics:
        return const AdminAnalyticsScreen();
      case AdminPage.alerts:
        return const AdminAlertsScreen();
      case AdminPage.settings:
        return const AdminSettingsScreen();
    }
  }
}
