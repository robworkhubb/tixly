import 'package:tixly/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> register(String username, String email, String password);
  Future<void> logout();
  Stream<UserEntity?> get userChanges;
}
