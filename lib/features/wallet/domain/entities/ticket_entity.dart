import '../../data/models/ticket_model.dart';

class TicketEntity {
  final String id;
  final String userId;
  final String eventName;
  final DateTime eventDate;
  final String? fileUrl;
  final String? imageUrl;
  final TicketType type;

  TicketEntity({
    required this.id,
    required this.userId,
    required this.eventName,
    required this.eventDate,
    this.fileUrl,
    this.imageUrl,
    required this.type,
  });
}
