import '../../shared/data/models/user_model.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState {
  final UserModel? user;
  final ProfileStatus status;
  final String? errorMessage;

  const ProfileState({
    this.user,
    this.status = ProfileStatus.initial,
    this.errorMessage,
  });

  ProfileState copyWith({
    UserModel? user,
    ProfileStatus? status,
    String? errorMessage,
  }) {
    return ProfileState(
      user: user ?? this.user,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}