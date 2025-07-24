import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../models/comment_model.dart';

class CommentRepositoryImpl implements CommentRepository {
  final FirebaseFirestore _firestore;

  CommentRepositoryImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Stream<List<Comment>> getComments(String postId) {
    try {
      return _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => CommentModel.fromFirestore(doc).toEntity())
                .toList();
          });
    } catch (e) {
      debugPrint('❌ Error getting comments: $e');
      rethrow;
    }
  }

  @override
  Future<void> addComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    try {
      final comment = CommentModel(
        id: '', // Firestore genererà l'ID
        postId: postId,
        userId: userId,
        content: content,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add(comment.toMap());
    } catch (e) {
      debugPrint('❌ Error adding comment: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      debugPrint('❌ Error deleting comment: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateComment({
    required String postId,
    required String commentId,
    required String content,
  }) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({'content': content});
    } catch (e) {
      debugPrint('❌ Error updating comment: $e');
      rethrow;
    }
  }
}
