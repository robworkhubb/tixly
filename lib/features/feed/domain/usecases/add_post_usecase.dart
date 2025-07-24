import '../../domain/entities/post.dart';
import '../../data/repositories/post_repository.dart';

class AddPostUseCase {
  final PostRepository repository;
  AddPostUseCase(this.repository);

  Future<void> call(PostEntity post, {String? filePath}) {
    return repository.addPost(post, filePath: filePath);
  }
}
