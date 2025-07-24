import '../entities/ticket_entity.dart';

abstract class TicketRepository {
  Future<List<TicketEntity>> fetchTickets(String userId);
  Future<void> addTicket(TicketEntity ticket);
  Future<void> deleteTicket(String ticketId);
}
