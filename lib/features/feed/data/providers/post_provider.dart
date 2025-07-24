import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tixly/core/data/datasources/supabase_storage_service.dart';
import '../../domain/entities/post.dart';
import '../../domain/usecases/fetch_post_usecase.dart';
import '../../domain/usecases/add_post_usecase.dart';
import '../../domain/usecases/toggle_like_usecase.dart';

class PostProvider extends ChangeNotifier {
  final FetchPostsUseCase _fetchPosts;
  final AddPostUseCase _addPost;
  final ToggleLikeUseCase _toggleLike;
  final _storage = SupabaseStorageService();

  List<PostEntity> _posts = [];
  bool _isLoading = false;

  StreamSubscription<List<PostEntity>>? _postSubscription;

  PostProvider({
    required FetchPostsUseCase fetchPostsUseCase,
    required AddPostUseCase addPostUseCase,
    required ToggleLikeUseCase toggleLikeUseCase,
  }) : _fetchPosts = fetchPostsUseCase,
       _addPost = addPostUseCase,
       _toggleLike = toggleLikeUseCase;

  List<PostEntity> get posts => _posts;
  bool get isLoading => _isLoading;

  void listenToPosts() {
    _isLoading = true;
    notifyListeners();

    _postSubscription?.cancel();
    _postSubscription = _fetchPosts().listen((fetchedPosts) {
      _posts = fetchedPosts;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> createPost(PostEntity post, {String? filePath}) async {
    try {
      String? mediaUrl;

      if (filePath != null) {
        final file = File(filePath);
        final result = await _storage.uploadFile(
          file: file,
          bucket: 'posts',
          userId: post.userId,
          isPdf: false,
        );

        mediaUrl = result['url'];
      }

      final newPost = post.copyWith(mediaUrl: mediaUrl);
      await _addPost(newPost);
    } catch (e) {
      debugPrint('❌ createPost error: $e');
      rethrow;
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      await _toggleLike(postId, userId);
    } catch (e) {
      debugPrint('❌ toggleLike error: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _postSubscription?.cancel();
    super.dispose();
  }
}
