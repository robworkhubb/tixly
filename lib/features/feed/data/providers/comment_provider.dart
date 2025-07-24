import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/comment.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/delete_comment_usecase.dart';
import '../../domain/usecases/get_comments_usecase.dart';
import '../../domain/usecases/update_comment_usecase.dart';

class CommentProvider extends ChangeNotifier {
  final GetCommentsUseCase _getCommentsUseCase;
  final AddCommentUseCase _addCommentUseCase;
  final DeleteCommentUseCase _deleteCommentUseCase;
  final UpdateCommentUseCase _updateCommentUseCase;

  CommentProvider({
    required GetCommentsUseCase getCommentsUseCase,
    required AddCommentUseCase addCommentUseCase,
    required DeleteCommentUseCase deleteCommentUseCase,
    required UpdateCommentUseCase updateCommentUseCase,
  }) : _getCommentsUseCase = getCommentsUseCase,
       _addCommentUseCase = addCommentUseCase,
       _deleteCommentUseCase = deleteCommentUseCase,
       _updateCommentUseCase = updateCommentUseCase;

  List<Comment> _comments = [];
  bool _isLoading = false;
  String? _error;

  List<Comment> get comments => List.unmodifiable(_comments);
  bool get isLoading => _isLoading;
  String? get error => _error;

  StreamSubscription<List<Comment>>? _commentsSubscription;

  void listenToComments(String postId) {
    _isLoading = true;
    notifyListeners();

    _commentsSubscription?.cancel();
    _commentsSubscription = _getCommentsUseCase(postId).listen(
      (comments) {
        _comments = comments;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('❌ Error listening to comments: $e');
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addComment({
    required String postId,
    required String userId,
    required String content,
  }) async {
    try {
      await _addCommentUseCase(
        postId: postId,
        userId: userId,
        content: content,
      );
      _error = null;
    } catch (e) {
      debugPrint('❌ Error adding comment: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      await _deleteCommentUseCase(postId: postId, commentId: commentId);
      _error = null;
    } catch (e) {
      debugPrint('❌ Error deleting comment: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateComment({
    required String postId,
    required String commentId,
    required String content,
  }) async {
    try {
      await _updateCommentUseCase(
        postId: postId,
        commentId: commentId,
        content: content,
      );
      _error = null;
    } catch (e) {
      debugPrint('❌ Error updating comment: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _commentsSubscription?.cancel();
    super.dispose();
  }
}
