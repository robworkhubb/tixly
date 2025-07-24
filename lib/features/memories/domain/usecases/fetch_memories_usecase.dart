import '../repositories/memory_repository.dart';
import '../entities/memory_entity.dart';

class FetchMemoriesUsecase {
  final MemoryRepository repository;
  FetchMemoriesUsecase(this.repository);

  Future<List<MemoryEntity>> call(String userId) =>
      repository.fetchMemories(userId);
}
