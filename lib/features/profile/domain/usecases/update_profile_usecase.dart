import '../repositories/profile_repository.dart';
import '../entities/user_entity.dart';

class UpdateProfileUsecase {
  final ProfileRepository repository;
  UpdateProfileUsecase(this.repository);

  Future<void> call(UserEntity user) => repository.updateProfile(user);
}
