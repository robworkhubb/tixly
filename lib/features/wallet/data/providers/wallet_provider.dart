// ignore_for_file: unnecessary_cast

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/features/wallet/data/models/ticket_model.dart';
import 'package:tixly/core/data/datasources/supabase_storage_service.dart';
import 'package:tixly/features/wallet/data/repositories/ticket_repository_impl.dart';
import '../../domain/usecases/fetch_tickets_usecase.dart';
import '../../domain/usecases/add_ticket_usecase.dart';
import '../../domain/usecases/delete_ticket_usecase.dart';
import '../../domain/entities/ticket_entity.dart';

class WalletProvider with ChangeNotifier {
  static const int _perPage = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;
  final List<TicketModel> _tickets = [];

  final FetchTicketsUsecase fetchTicketsUsecase;
  final AddTicketUsecase addTicketUsecase;
  final DeleteTicketUsecase deleteTicketUsecase;
  final TicketRepositoryImpl ticketRepository;

  WalletProvider({
    required this.fetchTicketsUsecase,
    required this.addTicketUsecase,
    required this.deleteTicketUsecase,
    required this.ticketRepository,
  });

  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  List<TicketModel> get tickets => List.unmodifiable(_tickets);

  Future<void> fetchTickets(String userId, {bool clear = true}) async {
    _isLoading = true;
    notifyListeners();
    final tickets = await fetchTicketsUsecase(userId);
    if (clear) _tickets.clear();
    _tickets.addAll(
      tickets.map(
        (e) => TicketModel(
          id: e.id,
          eventId: e.eventName,
          userId: e.userId,
          type: e.type,
          fileUrl: e.fileUrl,
          rawFileUrl: e.imageUrl,
          createdAt: DateTime.now(),
          eventDate: e.eventDate,
        ),
      ),
    );
    _hasMore = tickets.length >= _perPage ? true : false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTicketsPaginated(String userId, {bool clear = false}) async {
    _isLoading = true;
    notifyListeners();
    final tickets = await ticketRepository.fetchTicketsPaginated(userId, lastDoc: _lastDoc, limit: _perPage);
    if (clear) _tickets.clear();
    _tickets.addAll(
      tickets.map(
        (e) => TicketModel(
          id: e.id,
          eventId: e.eventName,
          userId: e.userId,
          type: e.type,
          fileUrl: e.fileUrl,
          rawFileUrl: e.imageUrl,
          createdAt: DateTime.now(),
          eventDate: e.eventDate,
        ),
      ),
    );
    _hasMore = tickets.length >= _perPage ? true : false;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTicket({
    required String eventId,
    required String userId,
    required TicketType type,
    File? file,
    required DateTime eventDate,
  }) async {
    try {
      await ticketRepository.addTicketWithFile(
        eventId: eventId,
        userId: userId,
        type: type,
        file: file,
        eventDate: eventDate,
      );
      await fetchTickets(userId, clear: true);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTicket(String ticketId, String userId) async {
    await deleteTicketUsecase(ticketId);
    notifyListeners();
  }

  Future<void> updateTicket({
    required String id,
    required String userId,
    String? eventId,
    TicketType? type,
    File? newFile,
    DateTime? eventDate,
  }) async {
    try {
      await ticketRepository.updateTicketWithFile(
        id: id,
        userId: userId,
        eventId: eventId,
        type: type,
        newFile: newFile,
        eventDate: eventDate,
      );
      await fetchTickets(userId, clear: true);
    } catch (e) {
      rethrow;
    }
  }
}
