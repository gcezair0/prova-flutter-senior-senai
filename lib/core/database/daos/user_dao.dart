import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/users_table.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [UsersTable])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  Future<UsersTableData?> getCurrentUser() =>
      select(usersTable).getSingleOrNull();

  Future<void> saveUser(UsersTableCompanion user) =>
      into(usersTable).insertOnConflictUpdate(user);

  Future<void> clearUser() => delete(usersTable).go();

  Future<List<UsersTableData>> getAllUsers() =>
      select(usersTable).get();

  Future<UsersTableData?> getUserById(int id) =>
      (select(usersTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> saveUsers(List<UsersTableCompanion> users) =>
      batch((b) => b.insertAllOnConflictUpdate(usersTable, users));
}