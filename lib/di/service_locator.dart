import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Auth
import 'package:tixly/features/auth/data/services/auth_service.dart';
import 'package:tixly/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tixly/features/auth/domain/usecases/login_usecase.dart';
import 'package:tixly/features/auth/domain/usecases/register_usecase.dart';
import 'package:tixly/features/auth/domain/usecases/logout_usecase.dart';
import 'package:tixly/features/auth/data/providers/auth_provider.dart' as auth;
import 'package:tixly/features/auth/data/repositories/auth_repository.dart' as repo;

// Feed
import 'package:tixly/features/feed/data/repositories/post_repository_impl.dart';
import 'package:tixly/features/feed/data/repositories/post_repository.dart' as post;
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
import 'package:tixly/features/profile/domain/repositories/profile_repository.dart' as profile;
import 'package:tixly/features/profile/domain/usecases/fetch_profile_usecase.dart';
import 'package:tixly/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:tixly/features/profile/data/providers/profile_provider.dart';

// Wallet
import 'package:tixly/features/wallet/data/repositories/ticket_repository_impl.dart';
import 'package:tixly/features/wallet/domain/repositories/ticket_repository.dart' as wallet;
import 'package:tixly/features/wallet/domain/usecases/fetch_tickets_usecase.dart';
import 'package:tixly/features/wallet/domain/usecases/add_ticket_usecase.dart';
import 'package:tixly/features/wallet/domain/usecases/delete_ticket_usecase.dart';
import 'package:tixly/features/wallet/data/providers/wallet_provider.dart';

// Memories
import 'package:tixly/features/memories/data/repositories/memory_repository_impl.dart';
import 'package:tixly/features/memories/data/providers/memory_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 1. Services & Data Sources
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<SupabaseStorageService>(() => SupabaseStorageService());
  sl.registerLazySingleton<AuthService>(() => AuthService());

  // 2. Core Repositories
  sl.registerLazySingleton<StorageRepository>(() => StorageRepositoryImpl(sl<SupabaseStorageService>()));

  // 3. Feature Repositories
  // Auth
  sl.registerLazySingleton<repo.AuthRepository>(() => AuthRepositoryImpl(sl<AuthService>()));

  // Feed
  sl.registerLazySingleton<PostRepositoryImpl>(() => PostRepositoryImpl(
    firestore: sl<FirebaseFirestore>(),
    storage: sl<SupabaseStorageService>(),
  ));
  sl.registerLazySingleton<post.PostRepository>(() => sl<PostRepositoryImpl>());

  // Comments
  sl.registerLazySingleton<CommentRepositoryImpl>(() => CommentRepositoryImpl(firestore: sl<FirebaseFirestore>()));
  sl.registerLazySingleton<CommentRepository>(() => sl<CommentRepositoryImpl>());

  // Profile
  sl.registerLazySingleton<profile.ProfileRepository>(() => ProfileRepositoryImpl(ProfileService()));

  // Wallet
  sl.registerLazySingleton<TicketRepositoryImpl>(() => TicketRepositoryImpl(storage: sl<SupabaseStorageService>()));
  sl.registerLazySingleton<wallet.TicketRepository>(() => sl<TicketRepositoryImpl>());

  // Memories
  sl.registerLazySingleton<MemoryRepositoryImpl>(() => MemoryRepositoryImpl(storage: sl<SupabaseStorageService>()));

  // 4. Use Cases
  // Auth
  sl.registerLazySingleton(() => LoginUsecase(sl<repo.AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUsecase(sl<repo.AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUsecase(sl<repo.AuthRepository>()));

  // Feed
  sl.registerLazySingleton(() => FetchPostsUseCase(sl<PostRepositoryImpl>()));
  sl.registerLazySingleton(() => AddPostUseCase(sl<PostRepositoryImpl>()));
  sl.registerLazySingleton(() => ToggleLikeUseCase(sl<PostRepositoryImpl>()));

  // Comments
  sl.registerLazySingleton(() => GetCommentsUseCase(sl<CommentRepository>()));
  sl.registerLazySingleton(() => AddCommentUseCase(sl<CommentRepository>()));
  sl.registerLazySingleton(() => DeleteCommentUseCase(sl<CommentRepository>()));
  sl.registerLazySingleton(() => UpdateCommentUseCase(sl<CommentRepository>()));

  // Profile
  sl.registerLazySingleton(() => FetchProfileUsecase(sl<profile.ProfileRepository>()));
  sl.registerLazySingleton(() => UpdateProfileUsecase(sl<profile.ProfileRepository>()));

  // Wallet
  sl.registerLazySingleton(() => FetchTicketsUsecase(sl<wallet.TicketRepository>()));
  sl.registerLazySingleton(() => AddTicketUsecase(sl<wallet.TicketRepository>()));
  sl.registerLazySingleton(() => DeleteTicketUsecase(sl<wallet.TicketRepository>()));

  // 5. Providers
  // Auth
  sl.registerFactory(() => auth.AuthProvider(
    loginUsecase: sl<LoginUsecase>(),
    registerUsecase: sl<RegisterUsecase>(),
    logoutUsecase: sl<LogoutUsecase>(),
  ));

  // Feed
  sl.registerLazySingleton(() => PostProvider(postRepository: sl<PostRepositoryImpl>()));

  // Comments
  sl.registerLazySingleton(() => CommentProvider(
    getCommentsUseCase: sl<GetCommentsUseCase>(),
    addCommentUseCase: sl<AddCommentUseCase>(),
    deleteCommentUseCase: sl<DeleteCommentUseCase>(),
    updateCommentUseCase: sl<UpdateCommentUseCase>(),
  ));

  // Profile
  sl.registerLazySingleton(() => ProfileProvider(
    fetchProfileUsecase: sl<FetchProfileUsecase>(),
    updateProfileUsecase: sl<UpdateProfileUsecase>(),
  ));

  // Wallet
  sl.registerLazySingleton(() => WalletProvider(
    fetchTicketsUsecase: sl<FetchTicketsUsecase>(),
    addTicketUsecase: sl<AddTicketUsecase>(),
    deleteTicketUsecase: sl<DeleteTicketUsecase>(),
    ticketRepository: sl<TicketRepositoryImpl>(),
  ));

  // Memories
  sl.registerLazySingleton(() => MemoryProvider(memoryRepository: sl<MemoryRepositoryImpl>()));
}
