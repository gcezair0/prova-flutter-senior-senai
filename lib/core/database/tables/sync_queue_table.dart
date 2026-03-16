import 'package:drift/drift.dart';

enum SyncOperation { create, update, delete }

class SyncQueueTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get localId => integer()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()
      .withDefault(currentDateAndTime)();
}