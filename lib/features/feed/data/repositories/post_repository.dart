import '../../domain/entities/post.dart';

abstract class PostRepository {
  Stream<List<PostEntity>> fetchPosts({PostEntity? last, int limit});
  Future<void> addPost(PostEntity post, {String? filePath});
  Future<void> toggleLike(String postId, String userId);
}
