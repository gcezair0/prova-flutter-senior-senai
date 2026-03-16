import 'dart:convert';
import '../../../../core/database/app_database.dart';
import '../datasources/task_local_datasource.dart';
import '../datasources/task_remote_datasource.dart';
import '../domain/task_repository.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remote;
  final TaskLocalDataSource _local;
  final AppDatabase _db;

  TaskRepositoryImpl(this._remote, this._local, this._db);

  @override
  Future<List<TaskModel>> getTasksByUser(
      int userId, {
        required int limit,
        required int skip,
      }) async {
    try {
      final remoteTasks = await _remote.getTasksByUser(
        userId,
        limit: limit,
        skip: skip,
      );
      await _local.cacheTasks(remoteTasks);
    } catch (_) {}
    return _local.getAllTasksByUser(userId);
  }

  @override
  Future<TaskModel> getTaskById(int id) => _remote.getTaskById(id);

  @override
  Future<TaskModel> createTask({
    required String todo,
    required String description,
    required int userId,
  }) async {
    final localTask = TaskModel(
      id: 1,
      todo: todo,
      description: description,
      completed: false,
      userId: userId,
      isSynced: false,
    );
    await _local.saveTask(localTask);
    final saved = await _local.getLastInserted();

    try {
      await _remote.createTask(todo: todo, userId: userId);
      await _db.taskDao.markAsSynced(saved!.localId!);
      return saved.copyWith(isSynced: true);
    } catch (_) {
      await _db.syncQueueDao.enqueue(
        SyncQueueTableCompanion.insert(
          localId: saved!.localId!,
          operation: 'create',
          payload: jsonEncode({'todo': todo, 'userId': userId}),
        ),
      );
      return saved;
    }
  }

  @override
  Future<TaskModel> updateTask(
      int id, {
        String? todo,
        String? description,
        bool? completed,
        int? localId,
      }) async {
    final completedAt = completed == true ? DateTime.now() : null;

    if (localId != null) {
      await _db.taskDao.updateByLocalId(
        localId: localId,
        todo: todo,
        description: description,
        completed: completed,
        completedAt: completedAt,
      );
    }

    final row = await _db.taskDao.getByLocalId(localId!);

    if (row != null && row.isSynced) {
      try {
        await _remote.updateTask(id, todo: todo, completed: completed);
      } catch (_) {
        await _db.syncQueueDao.enqueue(
          SyncQueueTableCompanion.insert(
            localId: localId,
            operation: 'update',
            payload: jsonEncode({
              'id': id,
              'todo': todo,
              'completed': completed,
            }),
          ),
        );
      }
    }

    return TaskModel(
      id: row?.id ?? id,
      localId: localId,
      todo: row?.todo ?? todo ?? '',
      description: row?.description,
      completed: completed ?? row?.completed ?? false,
      userId: row?.userId ?? 0,
      completedAt: completedAt ?? row?.completedAt,
      isSynced: row?.isSynced ?? false,
    );
  }

  @override
  Future<void> deleteTask(int localId) async {
    final row = await _db.taskDao.getByLocalId(localId);

    await _local.deleteTask(localId);

    if (row != null && row.isSynced && row.id > 0) {
      try {
        await _remote.deleteTask(row.id);
      } catch (_) {
        await _db.syncQueueDao.enqueue(
          SyncQueueTableCompanion.insert(
            localId: localId,
            operation: 'delete',
            payload: jsonEncode({'id': row.id}),
          ),
        );
      }
    }
  }

  @override
  Future<List<TaskModel>> getCachedTasksByUser(int userId) =>
      _local.getAllTasksByUser(userId);

  @override
  Future<int> getNextLocalId() {
    // TODO: implement getNextLocalId
    throw UnimplementedError();
  }
}