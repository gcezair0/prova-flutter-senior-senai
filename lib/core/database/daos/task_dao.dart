import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tasks_table.dart';

part 'task_dao.g.dart';

@DriftAccessor(tables: [TasksTable])
class TaskDao extends DatabaseAccessor<AppDatabase> with _$TaskDaoMixin {
  TaskDao(super.db);

  Future<List<TasksTableData>> getAllTasks() =>
      select(tasksTable).get();

  Future<List<TasksTableData>> getTasksByUser(int userId) =>
      (select(tasksTable)..where((t) => t.userId.equals(userId))).get();

  Future<void> insertOrUpdateTask(TasksTableCompanion task) =>
      into(tasksTable).insertOnConflictUpdate(task);

  Future<void> insertOrUpdateTasks(List<TasksTableCompanion> tasks) =>
      batch((b) => b.insertAllOnConflictUpdate(tasksTable, tasks));

  Future<void> deleteTaskByLocalId(int localId) =>
      (delete(tasksTable)..where((t) => t.localId.equals(localId))).go();

  Future<void> insertOrIgnoreTask(TasksTableCompanion task) =>
      into(tasksTable).insert(task, mode: InsertMode.insertOrIgnore);

  Future<bool> existsByApiId(int apiId) async {
    final result = await (select(tasksTable)
      ..where((t) => t.id.equals(apiId)))
        .getSingleOrNull();
    return result != null;
  }

  Future<TasksTableData?> getLastInserted() =>
      (select(tasksTable)
        ..orderBy([(t) => OrderingTerm.desc(t.localId)])
        ..limit(1))
          .getSingleOrNull();

  Future<TasksTableData?> getByLocalId(int localId) =>
      (select(tasksTable)..where((t) => t.localId.equals(localId)))
          .getSingleOrNull();

  Future<void> updateByLocalId({
    required int localId,
    String? todo,
    String? description,
    bool? completed,
    DateTime? completedAt,
  }) async {
    final companion = TasksTableCompanion(
      todo: todo != null ? Value(todo) : const Value.absent(),
      description: description != null
          ? Value(description)
          : const Value.absent(),
      completed: completed != null ? Value(completed) : const Value.absent(),
      completedAt: completedAt != null
          ? Value(completedAt)
          : completed == false
          ? const Value(null)
          : const Value.absent(),
    );
    await (update(tasksTable)..where((t) => t.localId.equals(localId)))
        .write(companion);
  }

  Future<void> markAsSynced(int localId) =>
      (update(tasksTable)..where((t) => t.localId.equals(localId)))
          .write(const TasksTableCompanion(isSynced: Value(true)));

  Future<void> updateApiId({
    required int localId,
    required int apiId,
  }) =>
      (update(tasksTable)..where((t) => t.localId.equals(localId)))
          .write(TasksTableCompanion(id: Value(apiId)));
}