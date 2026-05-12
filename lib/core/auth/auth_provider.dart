import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';
import 'supabase_auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final service = SupabaseAuthService();
  ref.onDispose(() => service.dispose());
  return service;
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
