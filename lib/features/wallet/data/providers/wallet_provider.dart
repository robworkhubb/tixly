// ignore_for_file: unnecessary_cast

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tixly/features/wallet/data/models/ticket_model.dart';
import 'package:tixly/core/data/datasources/supabase_storage_service.dart';
import '../../domain/usecases/fetch_tickets_usecase.dart';
import '../../domain/usecases/add_ticket_usecase.dart';
import '../../domain/usecases/delete_ticket_usecase.dart';
import '../../domain/entities/ticket_entity.dart';

class WalletProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _storage = SupabaseStorageService();

  static const int _perPage = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;
  final List<TicketModel> _tickets = [];

  final FetchTicketsUsecase fetchTicketsUsecase;
  final AddTicketUsecase addTicketUsecase;
  final DeleteTicketUsecase deleteTicketUsecase;

  WalletProvider({
    required this.fetchTicketsUsecase,
    required this.addTicketUsecase,
    required this.deleteTicketUsecase,
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

  Future<void> addTicket({
    required String eventId,
    required String userId,
    required TicketType type,
    File? file,
    required DateTime eventDate,
  }) async {
    try {
      String? fileUrl;
      String? rawFileUrl;

      if (file != null) {
        final isPdf = type == TicketType.pdf;
        final result = await _storage.uploadFile(
          file: file,
          bucket: 'tickets',
          userId: userId,
          isPdf: isPdf,
        );
        fileUrl = result['url'];
        rawFileUrl = result['url'];
      }

      final docData = {
        'eventId': eventId,
        'userId': userId,
        'type': type.name,
        'fileUrl': fileUrl,
        'rawFileUrl': rawFileUrl,
        'eventDate': eventDate,
        'createdAt': Timestamp.now(),
      };

      await _db.collection('tickets').add(docData);
      await fetchTickets(userId, clear: true);
    } catch (e) {
      debugPrint('❌ Errore addTicket: $e');
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
      final docRef = _db.collection('tickets').doc(id);
      final oldDoc = await docRef.get();
      final oldData = oldDoc.data() ?? {};

      final data = <String, dynamic>{};

      if (eventId != null) data['eventId'] = eventId;
      if (type != null) data['type'] = type.name;
      if (eventDate != null) data['eventDate'] = Timestamp.fromDate(eventDate);

      if (newFile != null && type != null) {
        final isPdf = type == TicketType.pdf;
        final result = await _storage.uploadFile(
          file: newFile,
          bucket: 'tickets',
          userId: userId,
          isPdf: isPdf,
        );
        data['fileUrl'] = result['url'];
        data['rawFileUrl'] = result['url'];
      } else {
        // Mantieni i vecchi URL se non c'è un nuovo file
        data['fileUrl'] = oldData['fileUrl'];
        data['rawFileUrl'] = oldData['rawFileUrl'];
      }

      if (data.isNotEmpty) {
        await docRef.update(data);
        await fetchTickets(userId, clear: true);
      }
    } catch (e) {
      debugPrint('❌ updateTicket error: $e');
      rethrow;
    }
  }
}
