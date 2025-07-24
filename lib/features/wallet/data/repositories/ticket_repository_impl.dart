import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ticket_entity.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../models/ticket_model.dart';
import 'package:tixly/core/data/datasources/supabase_storage_service.dart';

class TicketRepositoryImpl implements TicketRepository {
  final _db = FirebaseFirestore.instance;
  final SupabaseStorageService _storage;

  TicketRepositoryImpl({SupabaseStorageService? storage}) : _storage = storage ?? SupabaseStorageService();

  @override
  Future<List<TicketEntity>> fetchTickets(String userId) async {
    final snap = await _db
        .collection('tickets')
        .where('userId', isEqualTo: userId)
        .orderBy('eventDate')
        .get();
    return snap.docs
        .map((d) => TicketModel.fromMap(d.data() as Map<String, dynamic>, d.id).toEntity())
        .toList();
  }

  Future<List<TicketEntity>> fetchTicketsPaginated(String userId, {DocumentSnapshot? lastDoc, int limit = 10}) async {
    Query query = _db.collection('tickets')
        .where('userId', isEqualTo: userId)
        .orderBy('eventDate')
        .limit(limit);
    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }
    final snap = await query.get();
    return snap.docs
        .map((d) => TicketModel.fromMap(d.data() as Map<String, dynamic>, d.id).toEntity())
        .toList();
  }

  Future<Map<String, String>> uploadTicketFile({
    required File file,
    required String userId,
    required TicketType type,
  }) async {
    final isPdf = type == TicketType.pdf;
    return await _storage.uploadFile(
      file: file,
      bucket: 'tickets',
      userId: userId,
      isPdf: isPdf,
    );
  }

  Future<void> addTicketWithFile({
    required String eventId,
    required String userId,
    required TicketType type,
    File? file,
    required DateTime eventDate,
  }) async {
    String? fileUrl;
    String? rawFileUrl;
    if (file != null) {
      final result = await uploadTicketFile(file: file, userId: userId, type: type);
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
  }

  Future<void> updateTicketWithFile({
    required String id,
    required String userId,
    String? eventId,
    TicketType? type,
    File? newFile,
    DateTime? eventDate,
  }) async {
    final docRef = _db.collection('tickets').doc(id);
    final oldDoc = await docRef.get();
    final oldData = oldDoc.data() ?? {};
    final data = <String, dynamic>{};
    if (eventId != null) data['eventId'] = eventId;
    if (type != null) data['type'] = type.name;
    if (eventDate != null) data['eventDate'] = Timestamp.fromDate(eventDate);
    if (newFile != null && type != null) {
      final result = await uploadTicketFile(file: newFile, userId: userId, type: type);
      data['fileUrl'] = result['url'];
      data['rawFileUrl'] = result['url'];
    } else {
      data['fileUrl'] = oldData['fileUrl'];
      data['rawFileUrl'] = oldData['rawFileUrl'];
    }
    if (data.isNotEmpty) {
      await docRef.update(data);
    }
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
