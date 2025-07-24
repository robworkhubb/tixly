import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../models/ticket_model.dart';

class TicketRepositoryImpl implements TicketRepository {
  final _db = FirebaseFirestore.instance;

  @override
  Future<List<TicketEntity>> fetchTickets(String userId) async {
    final snap = await _db
        .collection('tickets')
        .where('userId', isEqualTo: userId)
        .orderBy('eventDate')
        .get();
    return snap.docs
        .map((d) => TicketModel.fromMap(d.data(), d.id).toEntity())
        .toList();
  }

  @override
  Future<void> addTicket(TicketEntity ticket) async {
    final model = TicketModel(
      id: ticket.id,
      eventId: ticket.eventName,
      userId: ticket.userId,
      type: ticket.type, // Usa il tipo corretto
      fileUrl: ticket.fileUrl,
      rawFileUrl: ticket.imageUrl,
      createdAt: DateTime.now(),
      eventDate: ticket.eventDate,
    );
    await _db.collection('tickets').add(model.toMap());
  }

  @override
  Future<void> deleteTicket(String ticketId) async {
    await _db.collection('tickets').doc(ticketId).delete();
  }
}
