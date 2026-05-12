enum AuthRole { admin, student, parent, staff, driver }

class AuthUser {
  final String id;
  final String email;
  final String name;
  final AuthRole role;
  final String? avatarUrl;
  final bool requiresPasswordChange;
  final bool requiresNameChange;

  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.requiresPasswordChange = true,
    this.requiresNameChange = true,
  });

  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    AuthRole? role,
    String? avatarUrl,
    bool? requiresPasswordChange,
    bool? requiresNameChange,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      requiresPasswordChange: requiresPasswordChange ?? this.requiresPasswordChange,
      requiresNameChange: requiresNameChange ?? this.requiresNameChange,
    );
  }
}

abstract class AuthService {
  AuthUser? get currentUser;
  bool get isAuthenticated;
  Stream<AuthUser?> get onAuthChanged;

  Future<AuthUser> login(String email, String password);
  Future<void> logout();
  Future<AuthUser> register(String email, String password, String name, AuthRole role);
}
