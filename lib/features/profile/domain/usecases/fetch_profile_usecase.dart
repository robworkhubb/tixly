import '../repositories/profile_repository.dart';
import '../entities/user_entity.dart';

class FetchProfileUsecase {
  final ProfileRepository repository;
  FetchProfileUsecase(this.repository);

  Future<UserEntity> call(String userId) => repository.fetchProfile(userId);
}
