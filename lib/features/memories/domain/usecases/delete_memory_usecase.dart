import '../repositories/memory_repository.dart';

class DeleteMemoryUsecase {
  final MemoryRepository repository;
  DeleteMemoryUsecase(this.repository);

  Future<void> call(String memoryId) => repository.deleteMemory(memoryId);
}
