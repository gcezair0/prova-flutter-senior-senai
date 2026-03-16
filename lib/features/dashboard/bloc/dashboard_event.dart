import '../../shared/data/models/user_model.dart';
import '../../tasks/data/models/task_model.dart';

abstract class DashboardEvent {}

class DashboardStarted extends DashboardEvent {
  final UserModel user;
  DashboardStarted(this.user);
}

class DashboardTaskCreateRequested extends DashboardEvent {
  final String todo;
  final String description;
  final int userId;
  DashboardTaskCreateRequested({required this.todo, required this.description, required this.userId});
}

class DashboardRefreshed extends DashboardEvent {
  final UserModel user;
  DashboardRefreshed(this.user);
}

class DashboardTaskCreated extends DashboardEvent {
  final TaskModel task;
  DashboardTaskCreated(this.task);
}

class DashboardTaskDeleted extends DashboardEvent {
  final int taskId;
  DashboardTaskDeleted(this.taskId);
}

class DashboardTaskToggled extends DashboardEvent {
  final TaskModel task;
  DashboardTaskToggled(this.task);
}