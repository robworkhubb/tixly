import '../repositories/ticket_repository.dart';

class DeleteTicketUsecase {
  final TicketRepository repository;
  DeleteTicketUsecase(this.repository);

  Future<void> call(String ticketId) => repository.deleteTicket(ticketId);
}
