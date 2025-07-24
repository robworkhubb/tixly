import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Firebase & Supabase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tixly/features/auth/data/services/auth_service.dart';
import 'package:tixly/features/feed/domain/usecases/add_comment_usecase.dart';
import 'package:tixly/features/feed/domain/usecases/delete_comment_usecase.dart';
import 'package:tixly/features/feed/domain/usecases/get_comments_usecase.dart';
import 'package:tixly/features/feed/domain/usecases/update_comment_usecase.dart';
import 'package:tixly/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:tixly/features/profile/domain/usecases/fetch_profile_usecase.dart';

// DI
import 'di/service_locator.dart' as di;

// Theme
import 'package:tixly/core/theme/app_theme.dart';
import 'package:tixly/core/theme/theme_mode_provider.dart';

// Providers
import 'features/auth/data/providers/auth_provider.dart' as app;
import 'features/profile/data/providers/user_provider.dart';
import 'features/feed/data/providers/post_provider.dart';
import 'features/feed/presentation/providers/comment_provider.dart';
import 'features/wallet/data/providers/wallet_provider.dart';
import 'package:tixly/features/wallet/domain/usecases/fetch_tickets_usecase.dart';
import 'package:tixly/features/wallet/domain/usecases/add_ticket_usecase.dart';
import 'package:tixly/features/wallet/domain/usecases/delete_ticket_usecase.dart';
import 'features/wallet/data/providers/event_provider.dart';
import 'features/memories/data/providers/memory_provider.dart';
import 'features/profile/data/providers/profile_provider.dart';
import 'features/wallet/data/repositories/ticket_repository_impl.dart';
import 'features/feed/data/repositories/post_repository_impl.dart';
import 'features/memories/data/repositories/memory_repository_impl.dart';

// Screens
import 'features/auth/presentation/screens/login_page.dart';
import 'features/profile/presentation/screens/home_page.dart';
import 'features/profile/presentation/screens/onboarding_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza Supabase prima di Firebase
  await Supabase.initialize(
    url: 'https://gpjdeuihwrmdqxzcmxxs.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdwamRldWlod3JtZHF4emNteHhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIwNjcwMzEsImV4cCI6MjA2NzY0MzAzMX0.TWWATPsUkcyn5FD4ggR2_utBVGiw4PHbtpQCcSjFbz0',
    debug: true, // Abilita i log di debug in development
  );

  // Inizializza Firebase
  await Firebase.initializeApp();

  // Inizializza GetIt
  await di.init();

  runApp(const TixlyApp());
}

class TixlyApp extends StatefulWidget {
  const TixlyApp({Key? key}) : super(key: key);

  @override
  State<TixlyApp> createState() => _TixlyAppState();
}

class _TixlyAppState extends State<TixlyApp> {
  bool _onBoardingSeen = false;
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    FirebaseAuth.instance.currentUser?.reload().catchError((e) async {
      if (e is FirebaseAuthException && e.code == 'user-not-found') {
        await FirebaseAuth.instance.signOut();
      }
    });
  }

  Future<void> _initPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _onBoardingSeen = prefs.getBool('onBoardingSeen') ?? false;
      _loadingPrefs = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPrefs) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MultiProvider(
      providers: [
        // Auth via GetIt
        Provider(create: (_) => di.sl<AuthService>()),
        ChangeNotifierProvider(create: (_) => di.sl<app.AuthProvider>()),

        // User Profile
        ChangeNotifierProxyProvider<app.AuthProvider, UserProvider>(
          create: (_) => UserProvider(),
          update: (ctx, auth, userProv) {
            final uid = auth.firebaseUser?.uid;
            if (uid != null) {
              userProv!.loadUser(uid);
            } else {
              userProv!.clearUser();
            }
            return userProv;
          },
        ),

        // Feed
        ChangeNotifierProvider(create: (_) => di.sl<PostProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<CommentProvider>()),

        // Altri provider
        ChangeNotifierProvider(create: (_) => di.sl<WalletProvider>()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => di.sl<MemoryProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ProfileProvider>()),
        ChangeNotifierProvider(create: (_) => ThemeModeProvider()),
      ],
      child: Consumer2<app.AuthProvider, ThemeModeProvider>(
        builder: (context, auth, themeModeProvider, _) {
          final user = auth.firebaseUser;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Tixly',
            themeMode: themeModeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            key: ValueKey(user == null ? 'login' : 'home'),
            home: _onBoardingSeen
                ? (user == null ? const LoginPage() : const HomePage())
                : OnboardingScreen(
                    onFinish: () {
                      setState(() => _onBoardingSeen = true);
                    },
                  ),
          );
        },
      ),
    );
  }
}
