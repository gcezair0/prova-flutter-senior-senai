import '../data/models/task_model.dart';

abstract class TaskEvent {}

class TasksLoadRequested extends TaskEvent {
  final int userId;
  TasksLoadRequested(this.userId);
}

class TasksLoadMoreRequested extends TaskEvent {
  final int userId;
  TasksLoadMoreRequested(this.userId);
}

class TaskSearchChanged extends TaskEvent {
  final String query;
  TaskSearchChanged(this.query);
}

class TaskFilterChanged extends TaskEvent {
  final TaskFilter filter;
  TaskFilterChanged(this.filter);
}

class TaskSortChanged extends TaskEvent {
  final TaskSort sort;
  TaskSortChanged(this.sort);
}

class TaskSortOrderToggled extends TaskEvent {}

class TaskCreateRequested extends TaskEvent {
  final String todo;
  final String? description;
  final int userId;
  TaskCreateRequested({required this.todo, required this.description, required this.userId});
}

class TaskUpdateRequested extends TaskEvent {
  final int id;
  final String? todo;
  final String? description;
  final int? localId;
  final bool? completed;
  TaskUpdateRequested({required this.id, this.todo, this.description, this.localId, this.completed});
}

class TaskDeleteRequested extends TaskEvent {
  final int localId;
  TaskDeleteRequested(this.localId);
}

class TaskToggleCompleted extends TaskEvent {
  final TaskModel task;
  TaskToggleCompleted(this.task);
}

enum TaskFilter { all, pending, completed }

enum TaskSort { defaultOrder, name, status, completedAt}

class TaskSelected extends TaskEvent {
  final TaskModel task;
  TaskSelected(this.task);
}