import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_service.dart';
import '../auth/auth_guard.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/student/screens/student_home.dart';
import '../../features/staff/screens/staff_home.dart';
import '../../features/parent/screens/parent_home.dart';
import '../../features/common/screens/notification_detail_screen.dart';
import '../../features/common/screens/settings_screen.dart';
import '../../features/common/screens/help_support_screen.dart';
import '../../features/common/screens/about_screen.dart';
import '../../features/parent/screens/linked_children_screen.dart';
import '../../features/admin/screens/admin_home.dart';
import '../../features/admin/screens/admin_login_screen.dart';

String _homeForRole(AuthRole role) {
  switch (role) {
    case AuthRole.admin: return '/admin/dashboard';
    case AuthRole.student: return '/student/home';
    case AuthRole.staff: return '/staff/home';
    case AuthRole.driver: return '/staff/home';
    case AuthRole.parent: return '/parent/home';
  }
}

final appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: authGuard,
  redirect: (BuildContext context, GoRouterState state) {
    final user = authGuard.currentUser;
    final isLoggedIn = user != null;
    final location = state.uri.toString();

    final publicPaths = ['/', '/login', '/forgot-password'];

    // Not logged in → only public paths allowed
    if (!isLoggedIn) {
      if (publicPaths.contains(location)) return null;
      return '/login';
    }

    // Logged in → never see login/splash
    if (location == '/' || location == '/login') {
      return _homeForRole(user.role);
    }

    // RBAC: define which paths each role can access
    final roleAllowed = <AuthRole, List<String>>{
      AuthRole.admin:  ['/admin', '/settings', '/help', '/about'],
      AuthRole.student: ['/student', '/settings', '/help', '/about'],
      AuthRole.staff:   ['/staff', '/settings', '/help', '/about'],
      AuthRole.driver:  ['/staff', '/settings', '/help', '/about'],
      AuthRole.parent:  ['/parent', '/settings', '/help', '/about'],
    };

    final allowed = roleAllowed[user.role]!;
    final isAllowed = allowed.any((p) => location.startsWith(p));

    if (!isAllowed) {
      return _homeForRole(user.role);
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),

    // Student routes
    GoRoute(path: '/student/home', builder: (context, state) => const StudentHomeScreen()),
    GoRoute(path: '/student/qr', builder: (context, state) => const StudentHomeScreen(initialIndex: 1)),
    GoRoute(path: '/student/track', builder: (context, state) => const StudentHomeScreen(initialIndex: 2)),
    GoRoute(path: '/student/notifications', builder: (context, state) => const StudentHomeScreen(initialIndex: 3)),
    GoRoute(path: '/student/profile', builder: (context, state) => const StudentHomeScreen(initialIndex: 4)),
    GoRoute(path: '/student/notifications/:id', builder: (context, state) {
      final id = state.pathParameters['id'] ?? '';
      return NotificationDetailScreen(audience: NotificationAudience.student, notificationId: id);
    }),

    // Parent routes
    GoRoute(path: '/parent/home', builder: (context, state) => const ParentHomeScreen()),
    GoRoute(path: '/parent/track', builder: (context, state) => const ParentHomeScreen(initialIndex: 1)),
    GoRoute(path: '/parent/payments', builder: (context, state) => const ParentHomeScreen(initialIndex: 2)),
    GoRoute(path: '/parent/alerts', builder: (context, state) => const ParentHomeScreen(initialIndex: 3)),
    GoRoute(path: '/parent/profile', builder: (context, state) => const ParentHomeScreen(initialIndex: 4)),
    GoRoute(path: '/parent/alerts/:id', builder: (context, state) {
      final id = state.pathParameters['id'] ?? '';
      return NotificationDetailScreen(audience: NotificationAudience.parent, notificationId: id);
    }),
    GoRoute(path: '/parent/linked-children', builder: (context, state) => const LinkedChildrenScreen()),

    // Staff routes
    GoRoute(path: '/staff/home', builder: (context, state) => const StaffHomeScreen()),
    GoRoute(path: '/staff/scan', builder: (context, state) => const StaffHomeScreen(initialIndex: 1)),
    GoRoute(path: '/staff/passengers', builder: (context, state) => const StaffHomeScreen(initialIndex: 2)),
    GoRoute(path: '/staff/route', builder: (context, state) => const StaffHomeScreen(initialIndex: 3)),
    GoRoute(path: '/staff/profile', builder: (context, state) => const StaffHomeScreen(initialIndex: 4)),

    // Admin routes
    GoRoute(path: '/admin/login', builder: (context, state) => const AdminLoginScreen()),
    GoRoute(path: '/admin/dashboard', builder: (context, state) => const AdminHomeScreen()),
    GoRoute(path: '/admin', redirect: (context, state) => '/admin/dashboard'),

    // Common utility pages
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(path: '/help', builder: (context, state) => const HelpSupportScreen()),
    GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
  ],
);
