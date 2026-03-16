import 'package:task_radar/features/shared/data/models/user_model.dart';

abstract class UsersRepository {
  Future<List<UserModel>> getUsers({String? search});
}