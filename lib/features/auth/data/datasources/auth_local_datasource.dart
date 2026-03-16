import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../shared/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final AppDatabase _db;

  AuthLocalDataSourceImpl(this._db);

  @override
  Future<void> saveUser(UserModel user) async {
    await _db.userDao.saveUser(
      UsersTableCompanion.insert(
        id: Value(user.id),
        username: user.username,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        gender: user.gender,
        image: user.image,
        role: Value(user.role),
        phone: user.phone ?? '',
        company: user.company ?? '',
        department: user.department ?? ''
      ),
    );
  }

  @override
  Future<UserModel?> getUser() async {
    final row = await _db.userDao.getCurrentUser();
    if (row == null) return null;
    return UserModel(
      id: row.id,
      username: row.username,
      email: row.email,
      firstName: row.firstName,
      lastName: row.lastName,
      gender: row.gender,
      image: row.image,
      role: row.role,
    );
  }

  @override
  Future<void> clearUser() => _db.userDao.clearUser();
}