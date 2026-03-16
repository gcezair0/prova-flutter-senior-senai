import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../features/admin/bloc/users_bloc.dart';
import '../../features/admin/data/datasources/users_remote_datasource.dart';
import '../../features/admin/data/domain/users_repository.dart';
import '../../features/admin/data/repositories/users_repository_impl.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/domain/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/dashboard/bloc/dashboard_bloc.dart';
import '../../features/dashboard/data/datasources/quote_remote_datasource.dart';
import '../../features/loading/bloc/loading_bloc.dart';
import '../../features/profile/bloc/profile_bloc.dart';
import '../../features/tasks/bloc/task_bloc.dart';
import '../../features/tasks/data/datasources/task_local_datasource.dart';
import '../../features/tasks/data/datasources/task_remote_datasource.dart';
import '../../features/tasks/data/domain/task_repository.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../config/env.dart';
import '../constants/theme_cubit.dart';
import '../database/app_database.dart';
import '../mock/mock_auth_repository.dart';
import '../network/http_client.dart';
import '../storage/token_storage.dart';
import '../sync/sync_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // ── 1. Database (base de tudo) ────────────────────────
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // ── 2. Storage ────────────────────────────────────────
  getIt.registerLazySingleton<FlutterSecureStorage>(
        () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<TokenStorage>(
        () => TokenStorage(getIt<FlutterSecureStorage>()),
  );

  // ── 3. Network ────────────────────────────────────────
  getIt.registerLazySingleton<Dio>(
        () => HttpClient.create(getIt<TokenStorage>()),
  );

  // ── 5. Repositorys ────────────────────────────────
  if (Env.useMock) {
    getIt.registerLazySingleton<AuthRepository>(
          () => MockAuthRepositoryImpl());
  } else {
    getIt.registerLazySingleton<AuthRepository>(
          () => AuthRepositoryImpl(
        getIt<AuthRemoteDataSource>(),
        getIt<TokenStorage>(),
        getIt<AuthLocalDataSource>(),
      ),
    );
  }


  getIt.registerLazySingleton<UsersRepository>(
        () => UsersRepositoryImpl(getIt<UsersRemoteDataSource>()),
  );
  getIt.registerLazySingleton<TaskRepository>(
        () => TaskRepositoryImpl(
      getIt<TaskRemoteDataSource>(),
      getIt<TaskLocalDataSource>(),
      getIt<AppDatabase>(),
    ),
  );

  // ── Local Datasources ───────────────────────────────
  getIt.registerLazySingleton<TaskLocalDataSource>(
        () => TaskLocalDataSourceImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(getIt<AppDatabase>()),
  );

  // ── Remotes Datasource ───────────────────────────────
  getIt.registerLazySingleton<QuoteRemoteDataSource>(
        () => QuoteRemoteDataSourceImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<UsersRemoteDataSource>(
        () => UsersRemoteDataSourceImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<TaskRemoteDataSource>(
        () => TaskRemoteDataSourceImpl(getIt<Dio>()),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(getIt<Dio>()),
  );

  // ── Blocs ─────────────────────────────────────────
  getIt.registerFactory<TaskBloc>(
        () => TaskBloc(getIt<TaskRepository>()),
  );
  getIt.registerFactory<DashboardBloc>(
        () => DashboardBloc(
      taskRepository: getIt<TaskRepository>(),
      quoteDataSource: getIt<QuoteRemoteDataSource>(),
    ),
  );
  getIt.registerFactory<ProfileBloc>(
        () => ProfileBloc(
      authRepository: getIt<AuthRepository>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );
  getIt.registerFactory<LoadingBloc>(
        () => LoadingBloc(
      taskRepository: getIt<TaskRepository>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  getIt.registerFactory<UsersBloc>(
        () => UsersBloc(getIt<UsersRepository>()),
  );

  // ── Outros ─────────────────────────────────────────
  getIt.registerLazySingleton<ThemeCubit>(
        () => ThemeCubit(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<SyncService>(
        () => SyncService(
      db: getIt<AppDatabase>(),
      remote: getIt<TaskRemoteDataSource>(),
      local: getIt<TaskLocalDataSource>(),
    ),
  );

}