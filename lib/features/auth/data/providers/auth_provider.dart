import 'package:flutter/material.dart';
import 'package:tixly/features/auth/domain/entities/user.dart';
import 'package:tixly/features/auth/domain/usecases/login_usecase.dart';
import 'package:tixly/features/auth/domain/usecases/logout_usecase.dart';
import 'package:tixly/features/auth/domain/usecases/register_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;
  final LogoutUsecase _logoutUsecase;
  AuthProvider({
    required LoginUsecase loginUsecase,
    required RegisterUsecase registerUsecase,
    required LogoutUsecase logoutUsecase,
  }) : _loginUsecase = loginUsecase,
       _registerUsecase = registerUsecase,
       _logoutUsecase = logoutUsecase {
    _init(); // <--- AGGIUNGI QUESTA RIGA QUI!
  }

  UserEntity? _user;

  void _init() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _user = UserEntity(
        uid: user.uid,
        displayName: user.displayName ?? '',
        email: user.email ?? '',
        profileImageUrl: user.photoURL,
      );
      notifyListeners();
    }
    // opzionale: ascolta anche lo stream
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user != null
          ? UserEntity(
              uid: user.uid,
              displayName: user.displayName ?? '',
              email: user.email ?? '',
              profileImageUrl: user.photoURL,
            )
          : null;
      notifyListeners();
    });
  }

  UserEntity? get firebaseUser => _user;

  Future<bool> login(String email, String password) async {
    final user = await _loginUsecase.login(email, password);
    debugPrint('sign in restituisce: $user');
    if (user != null) {
      _user = user;
      debugPrint('user settato: $_user');
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String email, String password) async {
    final user = await _registerUsecase.register(username, email, password);
    if (user != null) {
      _user = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() => _logoutUsecase.logout();
}
