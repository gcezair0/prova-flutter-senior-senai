import 'package:dio/dio.dart';
import 'package:task_radar/features/shared/data/models/user_model.dart';

abstract class UsersRemoteDataSource {
  Future<List<UserModel>> getUsers({String? search});
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final Dio _dio;

  UsersRemoteDataSourceImpl(this._dio);

  @override
  Future<List<UserModel>> getUsers({String? search}) async {
    final response = await _dio.get(
      search != null && search.isNotEmpty
          ? '/users/search'
          : '/users',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'q': search,
        'limit': 100,
      },
    );
    final list = response.data['users'] as List;
    return list.map((e) => UserModel.fromJson(e)).toList();
  }
}