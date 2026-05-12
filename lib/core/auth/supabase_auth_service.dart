import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;
import 'auth_service.dart';
import 'auth_guard.dart';

class SupabaseAuthService implements AuthService {
  AuthUser? _currentUser;
  final _controller = StreamController<AuthUser?>.broadcast();
  final _supabase = Supabase.instance.client;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  Stream<AuthUser?> get onAuthChanged => _controller.stream;

  SupabaseAuthService() {
    _supabase.auth.onAuthStateChange.listen((event) async {
      final session = event.session;
      if (session?.user != null) {
        await _fetchAndSetUser(session!.user);
      } else {
        _currentUser = null;
        _controller.add(null);
        authGuard.setUser(null);
      }
    });
    _initFromSession();
  }

  Future<void> _initFromSession() async {
    final session = _supabase.auth.currentSession;
    if (session?.user != null) {
      await _fetchAndSetUser(session!.user);
    }
  }

  Future<void> _fetchAndSetUser(User user) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .single();

      _currentUser = AuthUser(
        id: user.id,
        email: user.email ?? '',
        name: data['name'] as String? ?? '',
        role: AuthRole.values.firstWhere(
          (r) => r.name == data['role'],
          orElse: () => AuthRole.student,
        ),
        requiresPasswordChange: data['requires_password_change'] as bool? ?? true,
        requiresNameChange: data['requires_name_change'] as bool? ?? true,
      );

      _controller.add(_currentUser);
      authGuard.setUser(_currentUser);
    } catch (e) {
      _currentUser = null;
      _controller.add(null);
      authGuard.setUser(null);
    }
  }

  @override
  Future<AuthUser> login(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) {
      throw Exception('Invalid email or password');
    }
    await _fetchAndSetUser(response.user!);
    if (_currentUser == null) {
      throw Exception('Failed to load profile');
    }
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    _controller.add(null);
    authGuard.setUser(null);
  }

  @override
  Future<AuthUser> register(String email, String password, String name, AuthRole role) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role.name},
    );
    if (response.user == null) {
      throw Exception('Registration failed');
    }
    await _fetchAndSetUser(response.user!);
    if (_currentUser == null) {
      throw Exception('Failed to load profile');
    }
    return _currentUser!;
  }

  void dispose() {
    _controller.close();
  }
}
