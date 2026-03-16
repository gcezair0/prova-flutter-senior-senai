import 'dart:developer';
import 'package:dio/dio.dart';
import '../../../shared/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
  Future<UserModel> getMe();
  Future<UserModel> refreshToken(String refreshToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<UserModel> login(String username, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
        'expiresInMins': 30,
      },
    );
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> getMe() async {
    final response = await _dio.get('/auth/me');
    log('📡 getMe raw response: ${response.data}', name: 'AuthDS');
    return UserModel.fromJson(response.data);
  }

  @override
  Future<UserModel> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      '/auth/refresh',
      data: {
        'refreshToken': refreshToken,
        'expiresInMins': 30,
      },
    );
    return UserModel.fromJson(response.data);
  }
}