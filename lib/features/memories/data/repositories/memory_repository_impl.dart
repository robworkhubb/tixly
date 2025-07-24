import '../../domain/entities/memory_entity.dart';
import '../../domain/repositories/memory_repository.dart';
import '../models/memory_model.dart';
import '../providers/memory_provider.dart';

class MemoryRepositoryImpl implements MemoryRepository {
  final MemoryProvider _provider;
  MemoryRepositoryImpl(this._provider);

  @override
  Future<List<MemoryEntity>> fetchMemories(String userId) async {
    await _provider.fetchMemories(userId);
    return _provider.memories.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addMemory(MemoryEntity memory) async {
    await _provider.addMemory(
      userId: memory.userId,
      title: memory.title,
      artist: '',
      location: '',
      description: memory.description ?? '',
      date: memory.date,
      imageFile: null,
      rating: 0,
    );
  }

  @override
  Future<void> deleteMemory(String memoryId) async {
    // Serve anche userId per aggiornare la lista dopo delete
    // Qui si assume che l'ultimo utente caricato sia quello giusto
    final memory = _provider.memories.firstWhere(
      (m) => m.id == memoryId,
      orElse: () => throw Exception('Memory not found'),
    );
    final userId = memory.userId;
    await _provider.deleteMemory(memoryId, userId);
  }
}
