import '../repositories/comment_repository.dart';

class DeleteCommentUseCase {
  final CommentRepository _repository;

  DeleteCommentUseCase(this._repository);

  Future<void> call({required String postId, required String commentId}) {
    return _repository.deleteComment(postId: postId, commentId: commentId);
  }
}
