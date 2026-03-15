import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/role_selection_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/student/screens/student_home.dart';
import '../../features/parent/screens/parent_home.dart';
import '../../features/staff/screens/staff_home.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/login/:role',
      builder: (context, state) {
        final role = state.pathParameters['role'] ?? 'student';
        return LoginScreen(role: role);
      },
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    // Placeholder routes for main app dashboards
    GoRoute(
      path: '/student/home',
      builder: (context, state) => const StudentHomeScreen(),
    ),
    GoRoute(
      path: '/parent/home',
      builder: (context, state) => const ParentHomeScreen(),
    ),
    GoRoute(
      path: '/staff/home',
      builder: (context, state) => const StaffHomeScreen(),
    ),
  ],
);
