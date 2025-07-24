import 'package:tixly/features/auth/domain/entities/user.dart';

import '../services/auth_service.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _srv;

  AuthRepositoryImpl(this._srv);

  @override
  Future<UserEntity?> login(String email, String password) async {
    final firebaseUser = await _srv.signIn(email, password);
    if (firebaseUser == null) return null;
    return UserEntity(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName ?? '',
      profileImageUrl: firebaseUser.photoURL,
    );
  }

  @override
  Future<UserEntity?> register(
    String username,
    String email,
    String password,
  ) async {
    final firebaseUser = await _srv.signUp(
      email: email,
      password: password,
      displayName: username,
    );

    if (firebaseUser == null) return null;
    return UserEntity(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName ?? '',
      profileImageUrl: firebaseUser.photoURL,
    );
  }

  @override
  Future<void> logout() async {
    await _srv.signOut();
  }

  @override
  Stream<UserEntity?> get userChanges => _srv.userChanges.map((firebaseUser) {
    if (firebaseUser == null) return null;
    return UserEntity(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName ?? '',
      profileImageUrl: firebaseUser.photoURL,
    );
  });
}
