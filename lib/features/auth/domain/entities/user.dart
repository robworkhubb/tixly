class UserEntity {
  final String uid;
  final String? email;
  final String displayName;
  final String? profileImageUrl;
  final bool darkMode;

  UserEntity({
    required this.uid,
    this.email,
    required this.displayName,
    this.profileImageUrl,
    this.darkMode = false,
  });
}
