import 'dart:convert';
import '../database/app_database.dart';
import '../../features/tasks/data/datasources/task_remote_datasource.dart';

class SyncService {
  final AppDatabase _db;
  final TaskRemoteDataSource _remote;

  SyncService({
    required AppDatabase db,
    required TaskRemoteDataSource remote,
    required local,
  })  : _db = db,
        _remote = remote;

  Future<void> syncPending() async {
    final pending = await _db.syncQueueDao.getPendingOperations();
    if (pending.isEmpty) return;

    for (final entry in pending) {
      try {
        await _processEntry(entry);
        await _db.syncQueueDao.dequeue(entry.id);
      } catch (_) {
        break;
      }
    }
  }

  Future<void> _processEntry(SyncQueueTableData entry) async {
    final payload = jsonDecode(entry.payload) as Map<String, dynamic>;

    switch (entry.operation) {
      case 'create':
        await _remote.createTask(
          todo: payload['todo'],
          userId: payload['userId'],
        );
        await _db.taskDao.markAsSynced(entry.localId);

      case 'update':
        await _remote.updateTask(
          payload['id'],
          todo: payload['todo'] as String?,
          completed: payload['completed'] as bool?,
        );

      case 'delete':
        await _remote.deleteTask(payload['id']);
    }
  }
}