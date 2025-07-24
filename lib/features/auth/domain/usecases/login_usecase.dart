import '../../data/repositories/auth_repository.dart';
import '../entities/user.dart';

class LoginUsecase {
  final AuthRepository _repository;

  LoginUsecase(this._repository);

  Future<UserEntity?> login(String email, String password) async {
    return await _repository.login(email, password);
  }
}
