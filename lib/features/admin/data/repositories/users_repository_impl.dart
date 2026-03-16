import 'package:task_radar/features/shared/data/models/user_model.dart';
import '../datasources/users_remote_datasource.dart';
import '../domain/users_repository.dart';


class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource _remote;

  UsersRepositoryImpl(this._remote);

  @override
  Future<List<UserModel>> getUsers({String? search}) =>
      _remote.getUsers(search: search);
}