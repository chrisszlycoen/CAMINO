import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';
import 'mock_auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return MockAuthService();
});

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.onAuthChanged;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final value = ref.watch(authStateProvider);
  return value.asData?.value != null;
});

final currentUserProvider = Provider<AuthUser?>((ref) {
  final value = ref.watch(authStateProvider);
  return value.asData?.value;
});
