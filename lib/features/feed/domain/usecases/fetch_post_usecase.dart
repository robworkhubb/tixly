import '../../domain/entities/post.dart';
import '../../data/repositories/post_repository.dart';

class FetchPostsUseCase {
  final PostRepository repository;
  FetchPostsUseCase(this.repository);

  Stream<List<PostEntity>> call({PostEntity? last, int limit = 10}) {
    return repository.fetchPosts(last: last, limit: limit);
  }
}
