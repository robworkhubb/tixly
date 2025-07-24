import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tixly/features/feed/data/models/post_model.dart';
import 'package:tixly/features/feed/data/providers/post_provider.dart';
import 'package:tixly/features/profile/data/providers/user_provider.dart';

import '../screens/comment_sheet.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final String? currentUid;

  const PostCard({Key? key, required this.post, required this.currentUid})
    : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
    final userProv = context.watch<UserProvider>();

    // Se non abbiamo ancora caricato il profilo dell'autore, chiamalo:
    if (!userProv.cache.containsKey(widget.post.userId)) {
      context.read<UserProvider>().loadProfile(widget.post.userId);
    }

    // Prendi il profilo: o dalla cache o null
    final author = userProv.cache[widget.post.userId];

    final authorName = author?.displayName ?? 'Utente Sconosciuto';
    final authorImage = author?.profileImageUrl;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header con avatar e nome autore
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: authorImage != null
                      ? NetworkImage(authorImage)
                      : null,
                  child: authorImage == null
                      ? Text(authorName.isNotEmpty ? authorName[0] : '?')
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  authorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Immagine del post
          if (widget.post.mediaUrl?.isNotEmpty == true)
            CachedNetworkImage(
              imageUrl: widget.post.mediaUrl!,
              fit: BoxFit.cover,
              height: 300,
              placeholder: (context, url) => Container(
                height: 300,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 300,
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Errore caricamento immagine',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

          // Contenuto testuale
          if (widget.post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(widget.post.content),
            ),

          // Footer con like e commenti
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.post.id)
                      .collection('likes')
                      .doc(widget.currentUid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final isLiked = snapshot.data?.exists ?? false;
                    return IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                      ),
                      onPressed: widget.currentUid == null
                          ? null
                          : () => context.read<PostProvider>().toggleLike(
                              widget.post.id,
                              widget.currentUid!,
                            ),
                    );
                  },
                ),
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.post.id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final likes = snapshot.data?['likes'] as int? ?? 0;
                    return Text('$likes');
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => CommentSheet(postId: widget.post.id),
                    );
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.post.id)
                      .collection('comments')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final count = snapshot.data?.docs.length ?? 0;
                    return Text('$count');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
