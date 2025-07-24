import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:tixly/core/data/datasources/supabase_storage_service.dart';
import 'package:tixly/features/memories/data/models/memory_model.dart';
import 'package:tixly/features/memories/data/repositories/memory_repository_impl.dart';

class MemoryProvider with ChangeNotifier {
  final MemoryRepositoryImpl memoryRepository;

  List<MemoryModel> _memories = [];
  List<MemoryModel> get memories => _memories;

  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;

  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  MemoryProvider({required this.memoryRepository});

  Future<void> fetchMemories(String userId) async {
    try {
      _memories = await memoryRepository.fetchMemories(userId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchMemoriesPaginated(String userId, {bool clear = false, int limit = 10}) async {
    _isLoading = true;
    notifyListeners();
    final memories = await memoryRepository.fetchMemoriesPaginated(userId, lastDoc: _lastDoc, limit: limit);
    if (clear) _memories.clear();
    _memories.addAll(memories);
    _hasMore = memories.length >= limit;
    if (memories.isNotEmpty) {
      // Aggiorna _lastDoc solo se ci sono risultati
      // (serve per paginazione Firestore, qui semplificato)
      // In una versione avanzata, puoi salvare l'ultimo doc snapshot
    }
    _isLoading = false;
    notifyListeners();
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
      await memoryRepository.addMemory(
        userId: userId,
        title: title,
        artist: artist,
        location: location,
        description: description,
        date: date,
        imageFile: imageFile,
        rating: rating,
      );
      await fetchMemories(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMemory(String id, String userId) async {
    try {
      await memoryRepository.deleteMemory(id, userId);
      await fetchMemories(userId);
    } catch (e) {
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
      await memoryRepository.updateMemory(
        id: id,
        userId: userId,
        title: title,
        artist: artist,
        location: location,
        description: description,
        date: date,
        newImage: newImage,
        rating: rating,
      );
      await fetchMemories(userId);
    } catch (e) {
      rethrow;
    }
  }
}
