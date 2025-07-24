import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:tixly/features/feed/data/repositories/post_repository_impl.dart';
import '../../domain/entities/post.dart';

class PostProvider extends ChangeNotifier {
  final PostRepositoryImpl postRepository;
  StreamSubscription<List<PostEntity>>? _postsSubscription;
  static const int _pageSize = 10;

  List<PostEntity> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  PostEntity? _lastPost;
  String? _error;
  bool _initialLoadDone = false;

  PostProvider({required this.postRepository}) {
    _initPostsStream();
  }

  List<PostEntity> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  bool get initialLoadDone => _initialLoadDone;

  void _initPostsStream() {
    _postsSubscription?.cancel();
    _postsSubscription = postRepository.fetchPosts(limit: _pageSize).listen(
      (newPosts) {
        _posts = newPosts;
        _hasMore = newPosts.length >= _pageSize;
        if (newPosts.isNotEmpty) {
          _lastPost = newPosts.last;
        }
        _error = null;
        _initialLoadDone = true;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _initialLoadDone = true;
        notifyListeners();
      },
    );
  }

  Future<void> fetchPostsPaginated({bool clear = false}) async {
    if (_isLoading || (!_hasMore && !clear)) return;

    try {
      _isLoading = true;
      if (clear) {
        _lastPost = null;
        _posts = [];
        _initPostsStream();
      }
      notifyListeners();

      final newPosts = await postRepository.fetchPostsPaginated(
        last: _lastPost,
        limit: _pageSize,
      );

      if (clear) {
        _posts = newPosts;
      } else {
        _posts.addAll(newPosts);
      }

      _hasMore = newPosts.length >= _pageSize;
      if (newPosts.isNotEmpty) {
        _lastPost = newPosts.last;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _initialLoadDone = true;
      notifyListeners();
    }
  }

  Future<void> createPost(PostEntity post, {String? filePath}) async {
    try {
      await postRepository.addPost(post, filePath: filePath);
      await fetchPostsPaginated(clear: true);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      await postRepository.toggleLike(postId, userId);
      // Aggiorniamo solo il contatore locale
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      if (postIndex != -1) {
        final updatedPost = _posts[postIndex].copyWith(
          likes: _posts[postIndex].likes + 1,
        );
        _posts[postIndex] = updatedPost;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }
}
