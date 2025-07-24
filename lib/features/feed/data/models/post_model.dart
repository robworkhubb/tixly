import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/features/feed/domain/entities/post.dart';

class Post {
  final String id;
  final String userId;
  final String content;
  final String? mediaUrl;
  final DateTime timestamp;
  int likes;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.mediaUrl,
    required this.likes,
    required this.timestamp,
  });

  // Factory constructor to create a Post from a PostEntity
  factory Post.fromEntity(PostEntity entity) {
    return Post(
      id: entity.id,
      userId: entity.userId,
      content: entity.content,
      mediaUrl: entity.mediaUrl,
      likes: entity.likes,
      timestamp: entity.timestamp,
    );
  }

  factory Post.fromMap(Map<String, dynamic> data, String docId) {
    return Post(
      id: docId,
      userId: data['userId'],
      content: data['content'],
      mediaUrl: data['mediaUrl'],
      likes: (data['likes'] ?? 0) as int,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'content': content,
      'mediaUrl': mediaUrl,
      'likes': likes,
      'timestamp': timestamp,
    };
  }

  PostEntity toEntity() {
    return PostEntity(
      id: id,
      userId: userId,
      content: content,
      mediaUrl: mediaUrl,
      likes: likes,
      timestamp: timestamp,
    );
  }
}
