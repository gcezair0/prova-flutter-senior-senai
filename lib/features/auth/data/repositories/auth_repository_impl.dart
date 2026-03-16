import 'package:dio/dio.dart';
import '../../../../core/storage/token_storage.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../domain/auth_repository.dart';
import '../../../shared/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;
  final AuthLocalDataSource _local;

  AuthRepositoryImpl(this._remote, this._tokenStorage, this._local,  );

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final auth = await _remote.login(username, password);
      await _tokenStorage.saveToken(
        accessToken: auth.accessToken ?? '',
        refreshToken: auth.refreshToken ?? '',
      );
      return auth;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final user = await _remote.getMe();
      await _local.saveUser(user);
      return user;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<UserModel?> getSavedUser() => _local.getUser();

  @override
  Future<void> logout() async {
    await _tokenStorage.clear();
    await _local.clearUser();
  }

  @override
  Future<bool> isAuthenticated() => _tokenStorage.hasToken();

  Exception _handleError(DioException e) {
    if (e.response?.statusCode == 400) {
      return Exception('Usuário ou senha inválidos');
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('Sem conexão. Verifique sua internet.');
    }
    return Exception('Erro inesperado. Tente novamente.');
  }

  @override
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _remote.refreshToken(refreshToken);

      await _tokenStorage.saveToken(
        accessToken: response.accessToken ?? '',
        refreshToken: response.refreshToken ?? '',
      );

      return true;
    } catch (_) {
      return false;
    }
  }
}