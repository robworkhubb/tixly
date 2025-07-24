import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ticket_entity.dart';

enum TicketType { pdf, image, qr }

class TicketModel {
  final String id;
  final String eventId;
  final String userId;
  final TicketType type;
  final String? fileUrl;
  final String? rawFileUrl;
  final DateTime createdAt;
  final DateTime eventDate;

  TicketModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.type,
    this.fileUrl,
    this.rawFileUrl,
    required this.createdAt,
    required this.eventDate,
  });

  factory TicketModel.fromMap(Map<String, dynamic> data, String docId) {
    return TicketModel(
      id: docId,
      eventId: data['eventId'] as String,
      userId: data['userId'] as String,
      type: TicketType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => TicketType.pdf,
      ),
      fileUrl: data['fileUrl'] as String?,
      rawFileUrl: data['rawFileUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      eventDate: (data['eventDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'type': type.name,
      'fileUrl': fileUrl,
      'rawFileUrl': rawFileUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'eventDate': eventDate,
    };
  }

  TicketEntity toEntity() => TicketEntity(
    id: id,
    userId: userId,
    eventName: eventId,
    eventDate: eventDate,
    fileUrl: fileUrl,
    imageUrl: rawFileUrl,
    type: type.name == 'pdf' ? TicketType.pdf : TicketType.image,
  );

  static TicketModel fromEntity(TicketEntity entity) => TicketModel(
    id: entity.id,
    eventId: entity.eventName,
    userId: entity.userId,
    type: entity.type, // Usa il tipo corretto
    fileUrl: entity.fileUrl,
    rawFileUrl: entity.imageUrl,
    createdAt: DateTime.now(),
    eventDate: entity.eventDate,
  );
}
