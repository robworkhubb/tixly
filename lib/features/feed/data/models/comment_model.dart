import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/comment.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime timestamp;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.timestamp,
  });

  factory CommentModel.fromComment(Comment comment) {
    return CommentModel(
      id: comment.id,
      postId: comment.postId,
      userId: comment.userId,
      content: comment.content,
      timestamp: comment.timestamp,
    );
  }

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      postId: data['postId'] as String,
      userId: data['userId'] as String,
      content: data['content'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  Comment toEntity() {
    return Comment(
      id: id,
      postId: postId,
      userId: userId,
      content: content,
      timestamp: timestamp,
    );
  }
}
