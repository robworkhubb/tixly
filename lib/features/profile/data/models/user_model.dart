import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? profileImageUrl;
  final String? avatarPath;
  final bool darkMode;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
    this.avatarPath,
    this.darkMode = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      avatarPath: data['avatarPath'],
      darkMode: data['darkMode'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'avatarPath': avatarPath,
      'darkMode': darkMode,
    };
  }

  UserModel copyWith({
    String? email,
    String? displayName,
    String? profileImageUrl,
    String? avatarPath,
    bool? darkMode,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      avatarPath: avatarPath ?? this.avatarPath,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}

extension UserModelMapper on UserModel {
  UserEntity toEntity() => UserEntity(
    id: id,
    email: email,
    displayName: displayName,
    profileImageUrl: profileImageUrl,
  );

  static UserModel fromEntity(UserEntity entity) => UserModel(
    id: entity.id,
    email: entity.email,
    displayName: entity.displayName,
    profileImageUrl: entity.profileImageUrl,
  );
}
