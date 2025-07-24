import '../../data/repositories/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository _repository;

  LogoutUsecase(this._repository);

  Future<void> logout() async {
    await _repository.logout();
  }
}
