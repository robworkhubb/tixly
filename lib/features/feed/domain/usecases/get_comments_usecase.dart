import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

class GetCommentsUseCase {
  final CommentRepository _repository;

  GetCommentsUseCase(this._repository);

  Stream<List<Comment>> call(String postId) {
    return _repository.getComments(postId);
  }
}
