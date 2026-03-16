import '../../data/models/task_model.dart';

abstract class TaskRepository {
  Future<List<TaskModel>> getTasksByUser(
    int userId, {
    required int limit,
    required int skip,
  });
  Future<TaskModel> getTaskById(int id);
  Future<TaskModel> createTask({required String todo, required String description, required int userId});
  Future<TaskModel> updateTask(
    int id, {
    String? todo,
        String? description,
    bool? completed,
    int? localId,
  });
  Future<void> deleteTask(int id);
  Future<List<TaskModel>> getCachedTasksByUser(int userId);
  Future<int> getNextLocalId();
}
