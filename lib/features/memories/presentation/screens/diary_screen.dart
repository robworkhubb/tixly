import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tixly/core/theme/blur_app_bar.dart';
import 'package:tixly/features/auth/data/providers/auth_provider.dart';
import 'package:tixly/features/memories/data/providers/memory_provider.dart';
import 'package:tixly/features/memories/presentation/widgets/create_memory_sheet.dart';
import 'package:tixly/features/memories/presentation/widgets/memory_card.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().firebaseUser?.uid;
      if (userId != null) {
        context.read<MemoryProvider>().fetchMemories(userId);
      }
    });
  }

  void _onScroll() {
    final prov = context.read<MemoryProvider>();
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (prov.hasMore && !prov.isLoading) {
        final userId = context.read<AuthProvider>().firebaseUser?.uid;
        if (userId != null) {
          prov.fetchMemoriesPaginated(userId);
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MemoryProvider>();
    final memories = prov.memories;
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading = prov.isLoading;
    final hasMore = prov.hasMore;

    return Scaffold(
      appBar: BlurAppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diary',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Rivivi i tuoi concerti e salva i momenti più belli',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF499F68)
            : const Color(0xFF623CEA),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final userId = context.read<AuthProvider>().firebaseUser!.uid;
                  prov.fetchMemoriesPaginated(userId, clear: true);
                },
                child: memories.isEmpty && isLoading
                    ? ListView.builder(
                        itemCount: 5,
                        itemBuilder: (_, __) => const _MemorySkeleton(),
                      )
                    : memories.isEmpty
                        ? Center(
                            child: Text(
                              'Non hai ancora salvato ricordi. \n Aggiungine e rivivi le tue esperienze!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: memories.length + (hasMore ? 1 : 0),
                            itemBuilder: (context, i) {
                              if (i < memories.length) {
                                final m = memories[i];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: MemoryCard(memory: m),
                                );
                              } else {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                );
                              }
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateMemorySheet,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void _openCreateMemorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CreateMemorySheet(),
    );
  }
}

class _MemorySkeleton extends StatelessWidget {
  const _MemorySkeleton();
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
    );
  }
}
