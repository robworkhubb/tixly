import '../entities/user_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity> fetchProfile(String userId);
  Future<void> updateProfile(UserEntity user);
}
