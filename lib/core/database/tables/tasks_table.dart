import 'package:drift/drift.dart';

class TasksTable extends Table {
  IntColumn get id => integer()();
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get todo => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  IntColumn get userId => integer()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {localId};
}