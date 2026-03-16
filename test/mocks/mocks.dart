import 'package:mocktail/mocktail.dart';
import 'package:task_radar/features/admin/data/domain/users_repository.dart';
import 'package:task_radar/features/auth/data/domain/auth_repository.dart';
import 'package:task_radar/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:task_radar/features/shared/data/models/user_model.dart';
import 'package:task_radar/features/tasks/data/domain/task_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}
class MockTaskRepository extends Mock implements TaskRepository {}
class MockUsersRepository extends Mock implements UsersRepository {}
class FakeUserModel extends Fake implements UserModel {}
