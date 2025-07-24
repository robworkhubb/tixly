import 'package:flutter/material.dart';
import 'package:tixly/features/memories/data/models/memory_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MemoryCard extends StatelessWidget {
  final MemoryModel memory;
  const MemoryCard({Key? key, required this.memory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🔥 debug veloce: controlla cosa arriva davvero
    // debugPrint(
    //   'MemoryCard[${memory.id}] '
    //   'imageUrl=${memory.imageUrl} '
    //   'rating=${memory.rating}',
    // );

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1) Immagine da URL
          if (memory.imageUrl?.isNotEmpty == true)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: memory.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
              ),
            ),

          // 2) Testi e stelle
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  memory.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: colorScheme.onBackground,
                  ),
                ),
                Text(
                  memory.artist,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? colorScheme.onBackground.withOpacity(0.85)
                        : Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  memory.description,
                  style: TextStyle(
                    fontSize: 15,
                    color: colorScheme.onBackground,
                  ),
                ),
                // Data e luogo
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: colorScheme.onBackground,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      memory.dateFormatted,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: colorScheme.onBackground,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        memory.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stelline: solo se rating > 0
                if (memory.rating > 0)
                  Row(
                    children: List.generate(5, (i) {
                      return Icon(
                        i < memory.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 20,
                      );
                    }),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
