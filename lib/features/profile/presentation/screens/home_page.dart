import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:tixly/features/feed/presentation/screens/feed_screen.dart';
import 'package:tixly/features/feed/presentation/widgets/create_post_sheet.dart';
import 'package:tixly/features/memories/presentation/screens/diary_screen.dart';
import 'package:tixly/features/profile/presentation/screens/profile_screen.dart';
import 'package:tixly/features/wallet/presentation/screens/wallet_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // 0 = Feed, 1 = Diario, 2 = Wallet, 3 = Profilo

  final List<Widget> _screens = [
    FeedScreen(),
    DiaryScreen(),
    SizedBox(),
    WalletScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.fixedCircle,
        backgroundColor: Theme.of(context).colorScheme.primary,
        activeColor: Colors.white,
        initialActiveIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (_) => const CreatePostSheet(),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          TabItem(icon: Icons.home, title: 'Feed'),
          TabItem(icon: Icons.book, title: 'Diary'),
          TabItem(icon: Icons.add),
          TabItem(icon: Icons.wallet, title: 'Wallet'),
          TabItem(icon: Icons.person, title: 'Profile'),
        ],
      ),
    );
  }
}
