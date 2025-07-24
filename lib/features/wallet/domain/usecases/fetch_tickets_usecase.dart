import '../repositories/ticket_repository.dart';
import '../entities/ticket_entity.dart';

class FetchTicketsUsecase {
  final TicketRepository repository;
  FetchTicketsUsecase(this.repository);

  Future<List<TicketEntity>> call(String userId) =>
      repository.fetchTickets(userId);
}
