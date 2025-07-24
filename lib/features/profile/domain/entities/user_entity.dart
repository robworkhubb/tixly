class UserEntity {
  final String id;
  final String email;
  final String displayName;
  final String? profileImageUrl;

  UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? profileImageUrl,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
