import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tixly/core/theme/blur_app_bar.dart';
import 'package:tixly/features/feed/data/models/post_model.dart';
import 'package:tixly/features/feed/presentation/widgets/create_post_sheet.dart';
import 'package:tixly/features/feed/presentation/widgets/post_card.dart';
import 'package:tixly/features/profile/data/providers/user_provider.dart';

import '../../domain/entities/post.dart';
import '../../data/providers/post_provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    // Avvia lo stream dei post
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().listenToPosts();
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    // Riascolta (riavvia lo stream)
    context.read<PostProvider>().listenToPosts();
    // Ricarica eventuali dati utente
    final uid = context.read<UserProvider>().user!.id;
    await context.read<UserProvider>().loadUser(uid);
  }

  Future<void> _onAddPressed() async {
    final uid = context.read<UserProvider>().user!.id;
    final result = await showModalBottomSheet<Map<String, String?>>(
      context: context,
      builder: (_) => const CreatePostSheet(),
    );

    if (result != null) {
      final content = result['content']!;
      final filePath = result['filePath'];

      final newPost = PostEntity(
        id: '',
        userId: uid,
        content: content,
        mediaUrl: null,
        likes: 0,
        timestamp: DateTime.now(),
      );

      await context.read<PostProvider>().createPost(
        newPost,
        filePath: filePath,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProv = context.watch<PostProvider>();
    final posts = postProv.posts;
    final uid = context.watch<UserProvider>().user?.id;

    Widget body;
    if (postProv.isLoading && posts.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (posts.isEmpty) {
      body = ListView(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: Text('Nessun post ancora')),
        ],
      );
    } else {
      body = ListView.builder(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: posts.length,
        itemBuilder: (ctx, i) {
          return PostCard(post: Post.fromEntity(posts[i]), currentUid: uid);
        },
      );
    }

    return Scaffold(
      appBar: BlurAppBar(
        title: const Text(
          'Feed',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF499F68)
            : const Color(0xFF623CEA),
      ),
      body: RefreshIndicator(onRefresh: _onRefresh, child: body),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddPressed,
        child: const Icon(Icons.add),
      ),
    );
  }
}
