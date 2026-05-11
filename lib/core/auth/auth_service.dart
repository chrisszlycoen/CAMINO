enum AuthRole { admin, student, parent, staff }

class AuthUser {
  final String id;
  final String email;
  final String name;
  final AuthRole role;
  final String? avatarUrl;

  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatarUrl,
  });
}

abstract class AuthService {
  AuthUser? get currentUser;
  bool get isAuthenticated;
  Stream<AuthUser?> get onAuthChanged;

  Future<AuthUser> login(String email, String password);
  Future<void> logout();
  Future<AuthUser> register(String email, String password, String name, AuthRole role);
}
