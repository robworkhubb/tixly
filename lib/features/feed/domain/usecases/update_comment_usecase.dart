import '../repositories/comment_repository.dart';

class UpdateCommentUseCase {
  final CommentRepository _repository;

  UpdateCommentUseCase(this._repository);

  Future<void> call({
    required String postId,
    required String commentId,
    required String content,
  }) {
    return _repository.updateComment(
      postId: postId,
      commentId: commentId,
      content: content,
    );
  }
}
