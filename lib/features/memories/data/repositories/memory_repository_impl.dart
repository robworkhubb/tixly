import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/core/data/datasources/supabase_storage_service.dart';
import 'package:tixly/features/memories/data/models/memory_model.dart';

class MemoryRepositoryImpl {
  final _db = FirebaseFirestore.instance;
  final SupabaseStorageService _storage;

  MemoryRepositoryImpl({SupabaseStorageService? storage}) : _storage = storage ?? SupabaseStorageService();

  Future<List<MemoryModel>> fetchMemories(String userId) async {
    final snap = await _db
        .collection('memories')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();
    return snap.docs
        .map((doc) => MemoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
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
  }

  Future<void> deleteMemory(String id, String userId) async {
    final doc = await _db.collection('memories').doc(id).get();
    if (doc.exists) {
      final data = doc.data()!;
      final imageUrl = data['imageUrl'] as String?;
      if (imageUrl != null) {
        await _storage.deleteFile('memories', imageUrl);
      }
      await _db.collection('memories').doc(id).delete();
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
    }
  }

  // (Opzionale) Paginazione
  Future<List<MemoryModel>> fetchMemoriesPaginated(String userId, {DocumentSnapshot? lastDoc, int limit = 10}) async {
    Query query = _db.collection('memories')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .limit(limit);
    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }
    final snap = await query.get();
    return snap.docs
        .map((doc) => MemoryModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
