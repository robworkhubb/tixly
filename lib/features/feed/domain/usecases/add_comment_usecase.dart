import '../repositories/comment_repository.dart';

class AddCommentUseCase {
  final CommentRepository _repository;

  AddCommentUseCase(this._repository);

  Future<void> call({
    required String postId,
    required String userId,
    required String content,
  }) {
    return _repository.addComment(
      postId: postId,
      userId: userId,
      content: content,
    );
  }
}
