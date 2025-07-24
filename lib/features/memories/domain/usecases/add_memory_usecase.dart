import '../repositories/memory_repository.dart';
import '../entities/memory_entity.dart';

class AddMemoryUsecase {
  final MemoryRepository repository;
  AddMemoryUsecase(this.repository);

  Future<void> call(MemoryEntity memory) => repository.addMemory(memory);
}
