import 'dart:async';
import 'auth_service.dart';

class MockAuthService implements AuthService {
  AuthUser? _currentUser;
  final _controller = StreamController<AuthUser?>.broadcast();

  static const _validCredentials = {
    'admin@camino.rw': {'password': 'admin123', 'name': 'Admin User', 'role': 'admin'},
    'staff@camino.rw': {'password': 'staff123', 'name': 'Jean Baptiste', 'role': 'staff'},
  };

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  Stream<AuthUser?> get onAuthChanged => _controller.stream;

  MockAuthService() {
    _currentUser = null;
  }

  @override
  Future<AuthUser> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final creds = _validCredentials[email.toLowerCase().trim()];
    if (creds == null || creds['password'] != password) {
      throw Exception('Invalid email or password');
    }

    final role = AuthRole.values.firstWhere(
      (r) => r.name == creds['role'],
      orElse: () => AuthRole.admin,
    );

    _currentUser = AuthUser(
      id: email == 'admin@camino.rw' ? 'ADM-001' : 'STF-001',
      email: email,
      name: creds['name'] as String,
      role: role,
    );

    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<AuthUser> register(String email, String password, String name, AuthRole role) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _currentUser = AuthUser(
      id: 'USR-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      role: role,
    );
    _controller.add(_currentUser);
    return _currentUser!;
  }

  void dispose() {
    _controller.close();
  }
}
