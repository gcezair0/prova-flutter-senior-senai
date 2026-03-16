abstract class UsersEvent {}

class UsersLoadRequested extends UsersEvent {}

class UsersSearchChanged extends UsersEvent {
  final String query;
  UsersSearchChanged(this.query);
}

class UsersFilterChanged extends UsersEvent {
  final UsersFilter filter;
  UsersFilterChanged(this.filter);
}

enum UsersFilter { all, admin, moderator }