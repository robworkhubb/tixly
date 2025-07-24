// lib/core/di/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Auth
import 'package:tixly/features/auth/data/services/auth_service.dart';
import 'package:tixly/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tixly/features/auth/domain/usecases/login_usecase.dart';
import 'package:tixly/features/auth/domain/usecases/register_usecase.dart';
import 'package:tixly/features/auth/domain/usecases/logout_usecase.dart';
import 'package:tixly/features/auth/data/providers/auth_provider.dart' as auth;
import 'package:tixly/features/auth/data/repositories/auth_repository.dart'
    as repo;

// Feed
import 'package:tixly/features/feed/data/repositories/post_repository_impl.dart';
import 'package:tixly/features/feed/data/repositories/post_repository.dart'
    as post;
import 'package:tixly/features/feed/domain/usecases/fetch_post_usecase.dart';
import 'package:tixly/features/feed/domain/usecases/add_post_usecase.dart';
import 'package:tixly/features/feed/domain/usecases/toggle_like_usecase.dart';
import 'package:tixly/features/feed/data/providers/post_provider.dart';

// Comments
import 'package:tixly/features/feed/data/repositories/comment_repository_impl.dart';
import 'package:tixly/features/feed/domain/repositories/comment_repository.dart';
import 'package:tixly/features/feed/domain/usecases/add_comment_usecase.dart';
import 'package:tixly/features/feed/domain/usecases/delete_comment_usecase.dart';
import 'package:tixly/features/feed/domain/usecases/get_comments_usecase.dart';
import 'package:tixly/features/feed/domain/usecases/update_comment_usecase.dart';
import 'package:tixly/features/feed/presentation/providers/comment_provider.dart';

// Storage
import 'package:tixly/core/data/datasources/supabase_storage_service.dart';
import 'package:tixly/core/data/repositories/storage_repository_impl.dart';
import 'package:tixly/core/domain/repositories/storage_repository.dart';

// Profile
import 'package:tixly/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:tixly/features/profile/data/services/profile_service.dart';
import 'package:tixly/features/profile/domain/repositories/profile_repository.dart'
    as profile;
import 'package:tixly/features/profile/domain/usecases/fetch_profile_usecase.dart';
import 'package:tixly/features/profile/domain/usecases/update_profile_usecase.dart';

// Wallet
import 'package:tixly/features/wallet/data/repositories/ticket_repository_impl.dart';
import 'package:tixly/features/wallet/domain/repositories/ticket_repository.dart'
    as wallet;
import 'package:tixly/features/wallet/domain/usecases/fetch_tickets_usecase.dart';
import 'package:tixly/features/wallet/domain/usecases/add_ticket_usecase.dart';
import 'package:tixly/features/wallet/domain/usecases/delete_ticket_usecase.dart';
import 'package:tixly/features/wallet/data/providers/wallet_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 1. Services & Data Sources
  sl.registerLazySingleton<AuthService>(() => AuthService());
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<SupabaseStorageService>(
    () => SupabaseStorageService(),
  );

  // 2. Repositories
  sl.registerLazySingleton<StorageRepository>(
    () => StorageRepositoryImpl(sl<SupabaseStorageService>()),
  );

  sl.registerLazySingleton<repo.AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthService>()),
  );

  sl.registerLazySingleton<post.PostRepository>(
    () => PostRepositoryImpl(
      firestore: sl<FirebaseFirestore>(),
      storage: sl<SupabaseStorageService>(),
    ),
  );

  sl.registerLazySingleton<CommentRepository>(
    () => CommentRepositoryImpl(firestore: sl<FirebaseFirestore>()),
  );

  // Profile
  sl.registerLazySingleton<profile.ProfileRepository>(
    () => ProfileRepositoryImpl(ProfileService()),
  );
  sl.registerLazySingleton(
    () => FetchProfileUsecase(sl<profile.ProfileRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdateProfileUsecase(sl<profile.ProfileRepository>()),
  );

  // Wallet
  sl.registerLazySingleton<wallet.TicketRepository>(
    () =>
        TicketRepositoryImpl(), // aggiorna il costruttore per non richiedere WalletProvider
  );
  sl.registerLazySingleton(
    () => FetchTicketsUsecase(sl<wallet.TicketRepository>()),
  );
  sl.registerLazySingleton(
    () => AddTicketUsecase(sl<wallet.TicketRepository>()),
  );
  sl.registerLazySingleton(
    () => DeleteTicketUsecase(sl<wallet.TicketRepository>()),
  );

  // 3. Use Cases
  // Auth
  sl.registerLazySingleton(() => LoginUsecase(sl<repo.AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUsecase(sl<repo.AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUsecase(sl<repo.AuthRepository>()));

  // Feed
  sl.registerLazySingleton(() => FetchPostsUseCase(sl<post.PostRepository>()));
  sl.registerLazySingleton(() => AddPostUseCase(sl<post.PostRepository>()));
  sl.registerLazySingleton(() => ToggleLikeUseCase(sl<post.PostRepository>()));

  // Comments
  sl.registerLazySingleton(() => GetCommentsUseCase(sl<CommentRepository>()));
  sl.registerLazySingleton(() => AddCommentUseCase(sl<CommentRepository>()));
  sl.registerLazySingleton(() => DeleteCommentUseCase(sl<CommentRepository>()));
  sl.registerLazySingleton(() => UpdateCommentUseCase(sl<CommentRepository>()));

  // 4. Providers
  sl.registerFactory(
    () => auth.AuthProvider(
      loginUsecase: sl<LoginUsecase>(),
      registerUsecase: sl<RegisterUsecase>(),
      logoutUsecase: sl<LogoutUsecase>(),
    ),
  );

  sl.registerFactory(
    () => PostProvider(
      fetchPostsUseCase: sl<FetchPostsUseCase>(),
      addPostUseCase: sl<AddPostUseCase>(),
      toggleLikeUseCase: sl<ToggleLikeUseCase>(),
    ),
  );

  sl.registerFactory(
    () => CommentProvider(
      getCommentsUseCase: sl<GetCommentsUseCase>(),
      addCommentUseCase: sl<AddCommentUseCase>(),
      deleteCommentUseCase: sl<DeleteCommentUseCase>(),
      updateCommentUseCase: sl<UpdateCommentUseCase>(),
    ),
  );
}
