import '../../../shared/data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login(String username, String password);
  Future<UserModel> getMe();
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<bool> refreshToken();
  Future<UserModel?> getSavedUser();
}