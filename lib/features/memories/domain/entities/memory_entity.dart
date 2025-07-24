class MemoryEntity {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? imageUrl;
  final DateTime date;

  MemoryEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.imageUrl,
    required this.date,
  });
}
