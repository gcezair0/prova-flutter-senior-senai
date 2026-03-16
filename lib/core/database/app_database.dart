import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:task_radar/core/database/tables/settings_table.dart';
import 'daos/settings_dao.dart';
import 'daos/sync_queue_dao.dart';
import 'daos/task_dao.dart';
import 'daos/user_dao.dart';
import 'tables/sync_queue_table.dart';
import 'tables/tasks_table.dart';
import 'tables/users_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [TasksTable, UsersTable, SyncQueueTable, SettingsTable],
  daos: [TaskDao, UserDao, SyncQueueDao, SettingsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(tasksTable, tasksTable.description);
      }
      if (from < 3) {
        await migrator.createTable(usersTable);
      }
      if (from < 4) {
        await migrator.addColumn(tasksTable, tasksTable.completedAt);
      }
      if (from < 5) {
        await migrator.addColumn(tasksTable, tasksTable.isSynced);
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'task_radar.db'));
    return NativeDatabase.createInBackground(file);
  });
}