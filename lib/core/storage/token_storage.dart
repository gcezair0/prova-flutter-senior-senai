import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  TokenStorage(this._storage);

  Future<void> saveToken({
    required String accessToken,
    required String refreshToken,
  }) async {

    await Future.wait([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() async {
    final token = await _storage.read(key: _accessKey);
    return token;
  }

  Future<String?> getRefreshToken() async {
    final token = await _storage.read(key: _refreshKey);
    return token;
  }

  Future<void> clear() async {

    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
    ]);

  }

  Future<bool> hasToken() async {
    final token = await getAccessToken();

    final hasToken = token != null;

    return hasToken;
  }
}