import '../entities/comment.dart';

abstract class CommentRepository {
  /// Recupera i commenti di un post
  Stream<List<Comment>> getComments(String postId);

  /// Aggiunge un nuovo commento
  Future<void> addComment({
    required String postId,
    required String userId,
    required String content,
  });

  /// Elimina un commento
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  });

  /// Aggiorna un commento
  Future<void> updateComment({
    required String postId,
    required String commentId,
    required String content,
  });
}
