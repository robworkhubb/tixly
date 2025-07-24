import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:tixly/features/wallet/data/models/ticket_model.dart';

class TicketDetailScreen extends StatelessWidget {
  final TicketModel ticket;

  const TicketDetailScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPdf = ticket.type == TicketType.pdf;
    final url = isPdf ? ticket.rawFileUrl! : ticket.fileUrl!;

    return Scaffold(
      appBar: AppBar(title: Text(ticket.eventId)),
      body: FutureBuilder<File>(
        future: DefaultCacheManager().getSingleFile(url),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || !snap.hasData) {
            return const Center(child: Text('Errore caricamento file'));
          }
          final file = snap.data!;
          if (isPdf) {
            return PDFView(
              filePath: file.path,
              enableSwipe: true,
              swipeHorizontal: false,
            );
          }
          // Gestione immagini: controllo se il file è effettivamente un'immagine
          return FutureBuilder<Size?>(
            future: _getImageSize(file),
            builder: (ctx, imgSnap) {
              if (imgSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (imgSnap.hasError || imgSnap.data == null) {
                return const Center(child: Text('Errore caricamento immagine'));
              }
              return Center(child: Image.file(file, fit: BoxFit.contain));
            },
          );
        },
      ),
    );
  }
}

// Funzione di utilità per controllare se il file è un'immagine valida
Future<Size?> _getImageSize(File file) async {
  try {
    final bytes = await file.readAsBytes();
    final image = await decodeImageFromList(bytes);
    return Size(image.width.toDouble(), image.height.toDouble());
  } catch (e) {
    debugPrint('Errore decodifica immagine: $e');
    return null;
  }
}
