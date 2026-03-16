import 'package:task_radar/features/shared/data/models/user_model.dart';
import 'users_event.dart';

enum UsersStatus { initial, loading, success, failure }

class UsersState {
  final List<UserModel> users;
  final UsersStatus status;
  final String? errorMessage;
  final String searchQuery;
  final UsersFilter filter;

  const UsersState({
    this.users = const [],
    this.status = UsersStatus.initial,
    this.errorMessage,
    this.searchQuery = '',
    this.filter = UsersFilter.all,
  });

  List<UserModel> get displayUsers {
    var result = List<UserModel>.from(users);

    switch (filter) {
      case UsersFilter.admin:
        result = result.where((u) => u.role == 'admin').toList();
      case UsersFilter.moderator:
        result = result.where((u) => u.role == 'moderator').toList();
      case UsersFilter.all:
        break;
    }

    if (searchQuery.isNotEmpty) {
      result = result.where((u) {
        final name = '${u.firstName} ${u.lastName}'.toLowerCase();
        return name.contains(searchQuery.toLowerCase());
      }).toList();
    }

    return result;
  }

  List<UserModel> get admins =>
      displayUsers.where((u) => u.role == 'admin').toList();

  List<UserModel> get moderators =>
      displayUsers.where((u) => u.role == 'moderator').toList();

  UsersState copyWith({
    List<UserModel>? users,
    UsersStatus? status,
    String? errorMessage,
    String? searchQuery,
    UsersFilter? filter,
  }) {
    return UsersState(
      users: users ?? this.users,
      status: status ?? this.status,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
    );
  }
}