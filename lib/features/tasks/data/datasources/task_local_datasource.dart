import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getAllTasksByUser(int userId);
  Future<void> cacheTasks(List<TaskModel> tasks);
  Future<void> saveTask(TaskModel task);
  Future<void> deleteTask(int localId);
  Future<TaskModel?> getLastInserted();
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final AppDatabase _db;

  TaskLocalDataSourceImpl(this._db);

  @override
  Future<List<TaskModel>> getAllTasksByUser(int userId) async {
    final rows = await _db.taskDao.getTasksByUser(userId);
    return rows.map(_toModel).toList();
  }

  @override
  Future<TaskModel?> getLastInserted() async {
    final row = await _db.taskDao.getLastInserted();
    if (row == null) return null;
    return _toModel(row);
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    for (final task in tasks) {
      final exists = await _db.taskDao.existsByApiId(task.id);
      if (!exists) {
        await _db.taskDao.insertOrIgnoreTask(
          _toCompanion(task, isSynced: true),
        );
      }
    }
  }

  @override
  Future<void> saveTask(TaskModel task) =>
      _db.taskDao.insertOrUpdateTask(_toCompanion(task));

  @override
  Future<void> deleteTask(int localId) =>
      _db.taskDao.deleteTaskByLocalId(localId);

  TaskModel _toModel(TasksTableData row) => TaskModel(
    id: row.id,
    localId: row.localId,
    todo: row.todo,
    description: row.description,
    completed: row.completed,
    userId: row.userId,
    completedAt: row.completedAt,
    isSynced: row.isSynced,
  );

  TasksTableCompanion _toCompanion(TaskModel task, {bool? isSynced}) =>
      TasksTableCompanion(
        localId: task.localId != null
            ? Value(task.localId!)
            : const Value.absent(),
        id: Value(task.id),
        todo: Value(task.todo),
        description: Value(task.description),
        completed: Value(task.completed),
        userId: Value(task.userId),
        completedAt: Value(task.completedAt),
        isSynced: Value(isSynced ?? task.isSynced),
      );
}