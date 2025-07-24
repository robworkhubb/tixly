// lib/widgets/comment_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tixly/features/feed/data/models/comment_model.dart';
import 'package:tixly/features/profile/data/providers/user_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommentCard extends StatelessWidget {
  final CommentModel comment;

  const CommentCard({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();
    final currentUser = userProv.user;

    // Se è un commento di un altro utente e non è già in cache, lo carichiamo
    if (comment.userId != currentUser?.id &&
        !userProv.cache.containsKey(comment.userId)) {
      // Non serve await qui: al termine del fetch, notifyListeners ricostruirà il widget
      context.read<UserProvider>().loadProfile(comment.userId);
    }

    // Recupera il profilo: se è il corrente, uso currentUser, altrimenti dalla cache
    final author = (comment.userId == currentUser?.id)
        ? currentUser
        : userProv.cache[comment.userId];

    final authorName = author?.displayName ?? 'Utente Sconosciuto';
    final authorAvatar = author?.profileImageUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar: prima immagine, poi iniziale se non c'è URL
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[200],
            child: authorAvatar != null
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: authorAvatar,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const CircularProgressIndicator(strokeWidth: 2),
                      errorWidget: (_, __, ___) => Text(authorName.isNotEmpty ? authorName[0] : '?'),
                    ),
                  )
                : Text(authorName.isNotEmpty ? authorName[0] : '?'),
          ),
          const SizedBox(width: 8),
          // Contenuto commento
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(comment.content),
                const SizedBox(height: 4),
                Text(
                  TimeOfDay.fromDateTime(comment.timestamp).format(context),
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
