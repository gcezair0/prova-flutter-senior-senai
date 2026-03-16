import 'package:drift/drift.dart';

class UsersTable extends Table {
  IntColumn get id => integer()();
  TextColumn get username => text()();
  TextColumn get email => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get gender => text()();
  TextColumn get image => text()();
  TextColumn get role => text().withDefault(const Constant('moderator'))();
  TextColumn get phone => text()();
  TextColumn get company => text()();
  TextColumn get department => text()();

  @override
  Set<Column> get primaryKey => {id};
}