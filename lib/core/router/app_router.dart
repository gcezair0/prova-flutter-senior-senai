import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/bloc/users_bloc.dart';
import '../../features/admin/presentation/users_screen.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/data/domain/auth_repository.dart';
import '../../features/shared/data/models/user_model.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/dashboard/bloc/dashboard_bloc.dart';
import '../../features/dashboard/bloc/dashboard_event.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/loading/bloc/loading_bloc.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/splash/bloc/splash_cubit.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/tasks/bloc/task_bloc.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../di/injection.dart';
import '../../features/loading/presentation/loading_screen.dart';
import '../widgets/main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final extra = state.extra;
    if (state.uri.path.startsWith('/users') && extra is UserModel) {
      if (extra.role != 'admin') return '/dashboard';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => BlocProvider(
        create: (_) => SplashCubit(),
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/loading',
      builder: (context, state) {
        final user = state.extra as UserModel?;
        if (user == null) return const SizedBox.shrink();
        return BlocProvider(
          create: (_) => getIt<LoadingBloc>(),
          child: LoadingScreen(user: user),
        );
      },
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => BlocProvider(
        create: (_) => AuthBloc(getIt<AuthRepository>()),
        child: const LoginScreen(),
      ),
    ),

    ShellRoute(
      builder: (context, state, child) {
        final user = state.extra as UserModel?;
        if (user == null) return child;
        return MainShell(user: user, child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) {
            final user = state.extra as UserModel?;
            if (user == null) return const SizedBox.shrink();
            return BlocProvider(
              create: (_) => DashboardBloc(
                taskRepository: getIt(),
                quoteDataSource: getIt(),
              )..add(DashboardStarted(user)),
              child: DashboardScreen(user: user),
            );
          },
        ),
        GoRoute(
          path: '/tasks',
          builder: (context, state) {
            final user = state.extra as UserModel?;
            if (user == null) return const SizedBox.shrink();
            return BlocProvider(
              create: (_) => getIt<TaskBloc>(),
              child: TasksScreen(user: user),
            );
          },
        ),
        GoRoute(
          path: '/users',
          builder: (context, state) {
            final user = state.extra as UserModel?;
            if (user == null) return const SizedBox.shrink();
            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => getIt<UsersBloc>()),
                BlocProvider(
                  create: (_) => getIt<TaskBloc>(),
                ),
              ],
              child: const UsersScreen(),
            );
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);