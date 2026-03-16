import 'package:dio/dio.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasksByUser(int userId, {required int limit, required int skip});
  Future<TaskModel> getTaskById(int id);
  Future<TaskModel> createTask({required String todo, required int userId});
  Future<TaskModel> updateTask(int id, {String? todo, bool? completed});
  Future<void> deleteTask(int id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio _dio;

  TaskRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TaskModel>> getTasksByUser(
      int userId, {
        required int limit,
        required int skip,
      }) async {
    final response = await _dio.get(
      '/todos/user/$userId',
      queryParameters: {'limit': limit, 'skip': skip},
    );
    final list = response.data['todos'] as List;
    return list.map((e) => TaskModel.fromJson(e)).toList();
  }

  @override
  Future<TaskModel> getTaskById(int id) async {
    final response = await _dio.get('/todos/$id');
    return TaskModel.fromJson(response.data);
  }

  @override
  Future<TaskModel> createTask({
    required String todo,
    required int userId,
  }) async {
    final response = await _dio.post(
      '/todos/add',
      data: {'todo': todo, 'completed': false, 'userId': userId},
    );
    return TaskModel.fromJson(response.data);
  }

  @override
  Future<TaskModel> updateTask(int id, {String? todo, bool? completed}) async {
    final response = await _dio.put(
      '/todos/$id',
      data: {
        if (todo != null) 'todo': todo,
        if (completed != null) 'completed': completed,
      },
    );
    return TaskModel.fromJson(response.data);
  }

  @override
  Future<void> deleteTask(int id) => _dio.delete('/todos/$id');
}