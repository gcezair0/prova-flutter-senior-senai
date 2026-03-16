import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/sync_queue_table.dart';

part 'sync_queue_dao.g.dart';

@DriftAccessor(tables: [SyncQueueTable])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  Future<List<SyncQueueTableData>> getPendingOperations() =>
      select(syncQueueTable).get();

  Future<void> enqueue(SyncQueueTableCompanion entry) =>
      into(syncQueueTable).insert(entry);

  Future<void> dequeue(int id) =>
      (delete(syncQueueTable)..where((t) => t.id.equals(id))).go();

  Future<void> clearAll() => delete(syncQueueTable).go();
}