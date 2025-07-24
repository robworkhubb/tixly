import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../services/profile_service.dart';
import '../models/user_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _service;
  ProfileRepositoryImpl(this._service);

  @override
  Future<UserEntity> fetchProfile(String userId) async {
    final userModel = await _service.getProfile(userId);
    return userModel.toEntity();
  }

  @override
  Future<void> updateProfile(UserEntity user) async {
    await _service.updateProfile(
      UserModel(
        id: user.id,
        displayName: user.displayName,
        email: user.email,
        profileImageUrl: user.profileImageUrl,
        avatarPath: user.profileImageUrl,
        darkMode: false,
      ),
    );
  }
}
