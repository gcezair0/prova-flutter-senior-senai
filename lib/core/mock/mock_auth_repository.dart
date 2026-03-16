import 'package:task_radar/features/auth/data/domain/auth_repository.dart';
import 'package:task_radar/features/shared/data/models/user_model.dart';

final _fakeAdmin = UserModel(
  id: 1,
  username: 'emilys',
  email: 'emily.johnson@x.dummyjson.com',
  firstName: 'Emily',
  lastName: 'Johnson',
  gender: 'female',
  image: 'https://dummyjson.com/icon/emilys/128',
  role: 'admin',
  phone: '+81 965-431-3024',
  company: 'Dooley, Kozey and Cronin',
  department: 'Engineering',
  accessToken: 'fake_access_token',
  refreshToken: 'fake_refresh_token',
);

final _fakeModerator = UserModel(
  id: 2,
  username: 'moderator',
  email: 'gcezair0@gmail.com',
  firstName: 'Guilherme',
  lastName: 'Cezar',
  gender: 'male',
  image: 'https://dummyjson.com/icon/emilys/128',
  role: 'moderator',
  phone: '+87 9 9618-2672',
  company: 'Senai Soluções Digitais',
  department: 'Squad Apps',
  accessToken: 'fake_access_token',
  refreshToken: 'fake_refresh_token',
);

class MockAuthRepositoryImpl implements AuthRepository {
  static const _adminCredentials = ('emilys', 'emilyspass');
  static const _moderatorCredentials = ('moderator', 'moderatorpass');

  UserModel? _loggedUser;

  @override
  Future<UserModel> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (username == _adminCredentials.$1 && password == _adminCredentials.$2) {
      _loggedUser = _fakeAdmin;
      return _fakeAdmin;
    }

    if (username == _moderatorCredentials.$1 &&
        password == _moderatorCredentials.$2) {
      _loggedUser = _fakeModerator;
      return _fakeModerator;
    }

    throw Exception('Credenciais inválidas');
  }

  @override
  Future<UserModel> getMe() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (_loggedUser == null) throw Exception('Não autenticado');
    return _loggedUser!;
  }

  @override
  Future<bool> refreshToken() async => true;

  @override
  Future<void> logout() async => _loggedUser = null;

  @override
  Future<bool> isAuthenticated() async => _loggedUser != null;

  @override
  Future<UserModel?> getSavedUser() async => _loggedUser;
}

