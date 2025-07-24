import '../entities/memory_entity.dart';

abstract class MemoryRepository {
  Future<List<MemoryEntity>> fetchMemories(String userId);
  Future<void> addMemory(MemoryEntity memory);
  Future<void> deleteMemory(String memoryId);
}
