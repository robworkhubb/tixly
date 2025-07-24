import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tixly/core/data/datasources/supabase_storage_service.dart';
import 'package:tixly/features/memories/data/models/memory_model.dart';

class MemoryProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _storage = SupabaseStorageService();

  List<MemoryModel> _memories = [];
  List<MemoryModel> get memories => _memories;

  Future<void> fetchMemories(String userId) async {
    try {
      final snap = await _db
          .collection('memories')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
      _memories = snap.docs
          .map((doc) => MemoryModel.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ fetchMemories error: $e');
      rethrow;
    }
  }

  Future<void> addMemory({
    required String userId,
    required String title,
    required String artist,
    required String location,
    required String description,
    required DateTime date,
    File? imageFile,
    required int rating,
  }) async {
    try {
      String? imageUrl;

      if (imageFile != null) {
        final result = await _storage.uploadFile(
          file: imageFile,
          bucket: 'memories',
          userId: userId,
          isPdf: false,
        );
        imageUrl = result['url'];
      }

      await _db.collection('memories').add({
        'userId': userId,
        'title': title,
        'artist': artist,
        'location': location,
        'description': description,
        'date': Timestamp.fromDate(date),
        'imageUrl': imageUrl,
        'rating': rating,
      });

      await fetchMemories(userId);
    } catch (e) {
      debugPrint('❌ addMemory error: $e');
      rethrow;
    }
  }

  Future<void> deleteMemory(String id, String userId) async {
    try {
      final doc = await _db.collection('memories').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        final imageUrl = data['imageUrl'] as String?;

        if (imageUrl != null) {
          await _storage.deleteFile('memories', imageUrl);
        }

        await _db.collection('memories').doc(id).delete();
        await fetchMemories(userId);
      }
    } catch (e) {
      debugPrint('❌ deleteMemory error: $e');
      rethrow;
    }
  }

  Future<void> updateMemory({
    required String id,
    required String userId,
    String? title,
    String? artist,
    String? location,
    String? description,
    DateTime? date,
    File? newImage,
    int? rating,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (title != null) data['title'] = title;
      if (artist != null) data['artist'] = artist;
      if (location != null) data['location'] = location;
      if (description != null) data['description'] = description;
      if (date != null) data['date'] = Timestamp.fromDate(date);
      if (rating != null) data['rating'] = rating;

      if (newImage != null) {
        final result = await _storage.uploadFile(
          file: newImage,
          bucket: 'memories',
          userId: userId,
          isPdf: false,
        );
        data['imageUrl'] = result['url'];
      }

      if (data.isNotEmpty) {
        await _db.collection('memories').doc(id).update(data);
        await fetchMemories(userId);
      }
    } catch (e) {
      debugPrint('❌ updateMemory error: $e');
      rethrow;
    }
  }
}
