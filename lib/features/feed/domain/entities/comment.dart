class Comment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime timestamp;

  const Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.timestamp,
  });

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    DateTime? timestamp,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
