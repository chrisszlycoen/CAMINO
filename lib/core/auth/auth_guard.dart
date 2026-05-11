import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class AuthGuard extends ChangeNotifier {
  AuthUser? _user;

  AuthUser? get currentUser => _user;
  bool get isAuthenticated => _user != null;

  void setUser(AuthUser? user) {
    _user = user;
    notifyListeners();
  }
}

final authGuard = AuthGuard();
