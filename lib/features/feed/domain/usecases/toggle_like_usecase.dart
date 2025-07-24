import '../../data/repositories/post_repository.dart';

class ToggleLikeUseCase {
  final PostRepository repository;
  ToggleLikeUseCase(this.repository);

  Future<void> call(String postId, String userId) {
    return repository.toggleLike(postId, userId);
  }
}
