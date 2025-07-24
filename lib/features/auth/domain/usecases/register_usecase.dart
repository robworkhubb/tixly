import 'package:tixly/features/auth/domain/entities/user.dart';

import '../../data/repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository _repository;

  RegisterUsecase(this._repository);

  Future<UserEntity?> register(
    String username,
    String email,
    String password,
  ) async {
    return await _repository.register(username, email, password);
  }
}
