import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_radar/core/di/injection.dart';
import 'package:task_radar/features/splash/bloc/splash_cubit.dart';
import 'app.dart';
import 'core/constants/theme_cubit.dart';
import 'core/sync/sync_service.dart';
import 'features/dashboard/bloc/dashboard_bloc.dart';
import 'features/tasks/bloc/task_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await getIt<ThemeCubit>().loadTheme();
  Connectivity().onConnectivityChanged.listen((result) {
    if (result != ConnectivityResult.none) {
      getIt<SyncService>().syncPending();
    }
  });

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SplashCubit()),
        BlocProvider(create: (_) => getIt<TaskBloc>()),
        BlocProvider(create: (_) => getIt<DashboardBloc>()),
      ],
      child: const App(),
    ),
  );
}