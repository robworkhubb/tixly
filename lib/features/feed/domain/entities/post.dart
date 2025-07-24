class PostEntity {
  final String id;
  final String userId;
  final String content;
  final String? mediaUrl;
  final DateTime timestamp;
  int likes;

  PostEntity({
    required this.id,
    required this.userId,
    required this.content,
    required this.mediaUrl,
    required this.likes,
    required this.timestamp,
  });
  PostEntity copyWith({
    String? id,
    String? userId,
    String? content,
    String? mediaUrl,
    int? likes,
    DateTime? timestamp,
  }) {
    return PostEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      likes: likes ?? this.likes,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
