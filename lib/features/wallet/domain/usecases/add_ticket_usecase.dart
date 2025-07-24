import '../repositories/ticket_repository.dart';
import '../entities/ticket_entity.dart';

class AddTicketUsecase {
  final TicketRepository repository;
  AddTicketUsecase(this.repository);

  Future<void> call(TicketEntity ticket) => repository.addTicket(ticket);
}
