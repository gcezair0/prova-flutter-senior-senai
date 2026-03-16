import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/storage/token_storage.dart';
import '../../auth/data/domain/auth_repository.dart';
import '../../shared/data/models/user_model.dart';

enum SplashStatus { loading, authenticated, unauthenticated }

class SplashCubit extends Cubit<SplashStatus> {

  final TokenStorage _tokenStorage = getIt<TokenStorage>();
  final AuthRepository _authRepository = getIt<AuthRepository>();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  SplashCubit() : super(SplashStatus.loading);

  Future<void> checkAuth() async {
    try {
      final hasToken = await _tokenStorage.hasToken();

      if (!hasToken) {
        emit(SplashStatus.unauthenticated);
        return;
      }

      if (await _isTokenValid()) {
        emit(SplashStatus.authenticated);
        return;
      }

      final refreshed = await _authRepository.refreshToken();

      if (!refreshed) {
        await _logout();
        return;
      }

      if (await _isTokenValid()) {
        emit(SplashStatus.authenticated);
        return;
      }

      await _logout();

    } catch (_) {
      await _logout();
    }
  }

  Future<bool> _isTokenValid() async {
    try {
      final user = await _authRepository.getMe();
      _currentUser = user;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _logout() async {
    await _tokenStorage.clear();
    await _authRepository.logout();
    emit(SplashStatus.unauthenticated);
  }
}