import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tixly/features/wallet/data/models/ticket_model.dart';
import 'package:tixly/features/wallet/presentation/screens/ticket_detail_screen.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onEdit;
  final VoidCallback? onTap;

  const TicketCard({
    Key? key,
    required this.ticket,
    required this.onEdit,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPdf = ticket.type == TicketType.pdf;
    final colorScheme = Theme.of(context).colorScheme;

    Widget leading;
    if (isPdf) {
      leading = Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
        ),
      );
    } else if ((ticket.type == TicketType.image ||
            ticket.type == TicketType.qr) &&
        ticket.fileUrl != null) {
      debugPrint('Mostro miniatura: ${ticket.fileUrl}');
      leading = ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: ticket.fileUrl!,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              Container(color: Colors.grey[200], width: 50, height: 50),
          errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
        ),
      );
    } else {
      leading = const Icon(
        Icons.confirmation_number,
        size: 40,
        color: Colors.grey,
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: isPdf
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TicketDetailScreen(ticket: ticket),
                  ),
                );
              }
            : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.eventId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ticket.eventDate.day}/${ticket.eventDate.month}/${ticket.eventDate.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            ],
          ),
        ),
      ),
    );
  }
}
