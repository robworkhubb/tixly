import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/core/data/datasources/supabase_storage_service.dart';
import '../../domain/entities/post.dart';
import '../../data/repositories/post_repository.dart';
import '../models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  final FirebaseFirestore _db;
  final SupabaseStorageService _storage;
  final String bucket;

  PostRepositoryImpl({
    required FirebaseFirestore firestore,
    required SupabaseStorageService storage,
    this.bucket = 'posts',
  }) : _db = firestore,
       _storage = storage;

  @override
  Stream<List<PostEntity>> fetchPosts({PostEntity? last, int limit = 10}) {
    var query = _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (last != null) {
      query = query.startAfter([Timestamp.fromDate(last.timestamp)]);
    }

    return query.snapshots().map((snap) {
      return snap.docs
          .map((doc) => Post.fromMap(doc.data(), doc.id).toEntity())
          .toList();
    });
  }

  @override
  Future<List<PostEntity>> fetchPostsPaginated({PostEntity? last, int limit = 10}) async {
    var query = _db
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .limit(limit);
    if (last != null) {
      query = query.startAfter([Timestamp.fromDate(last.timestamp)]);
    }
    final snap = await query.get();
    return snap.docs
        .map((doc) => Post.fromMap(doc.data(), doc.id).toEntity())
        .toList();
  }

  @override
  Future<void> addPost(PostEntity post, {String? filePath}) async {
    try {
      String? mediaUrl;

      if (filePath != null) {
        final file = File(filePath);
        final result = await _storage.uploadFile(
          file: file,
          bucket: bucket,
          userId: post.userId,
          isPdf: false,
        );

        mediaUrl = result['url'];
      }

      final newPost = post.copyWith(mediaUrl: mediaUrl);
      await _db.collection('posts').add(Post.fromEntity(newPost).toMap());
    } catch (e) {
      throw Exception('Errore durante l\'aggiunta del post: $e');
    }
  }

  @override
  Future<void> toggleLike(String postId, String userId) async {
    try {
      final postRef = _db.collection('posts').doc(postId);
      final likeRef = postRef.collection('likes').doc(userId);
      final likeDoc = await likeRef.get();

      await _db.runTransaction((transaction) async {
        if (likeDoc.exists) {
          transaction.delete(likeRef);
          transaction.update(postRef, {'likes': FieldValue.increment(-1)});
        } else {
          transaction.set(likeRef, {'timestamp': FieldValue.serverTimestamp()});
          transaction.update(postRef, {'likes': FieldValue.increment(1)});
        }
      });
    } catch (e) {
      throw Exception('Errore durante il toggle del like: $e');
    }
  }
}
