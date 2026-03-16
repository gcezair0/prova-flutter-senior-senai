import '../data/models/task_model.dart';
import 'task_event.dart';

enum TaskStatus { initial, loading, loadingMore, success, failure }

class TaskState {
  final List<TaskModel> tasks;
  final TaskStatus status;
  final String? errorMessage;
  final String searchQuery;
  final TaskFilter filter;
  final TaskSort sort;
  final bool ascending;
  final bool hasReachedMax;
  final int currentSkip;

  const TaskState({
    this.tasks = const [],
    this.status = TaskStatus.initial,
    this.errorMessage,
    this.searchQuery = '',
    this.filter = TaskFilter.all,
    this.sort = TaskSort.defaultOrder,
    this.ascending = true,
    this.hasReachedMax = false,
    this.currentSkip = 0,
  });

  List<TaskModel> get displayTasks {
    var result = List<TaskModel>.from(tasks);

    switch (filter) {
      case TaskFilter.pending:
        result = result.where((t) => !t.completed).toList();
      case TaskFilter.completed:
        result = result.where((t) => t.completed).toList();
      case TaskFilter.all:
        break;
    }

    if (searchQuery.isNotEmpty) {
      result = result
          .where((t) =>
          t.todo.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    switch (sort) {
      case TaskSort.name:
        result.sort((a, b) => ascending
            ? a.todo.compareTo(b.todo)
            : b.todo.compareTo(a.todo));
      case TaskSort.status:
        result.sort((a, b) => ascending
            ? (a.completed ? 1 : 0).compareTo(b.completed ? 1 : 0)
            : (b.completed ? 1 : 0).compareTo(a.completed ? 1 : 0));
      case TaskSort.defaultOrder:
        if (!ascending) result = result.reversed.toList();
      case TaskSort.completedAt:
        result.sort((a, b) {
          final aDate = a.completedAt;
          final bDate = b.completedAt;
          if (aDate == null && bDate == null) {
            return ascending
                ? (a.localId ?? 0).compareTo(b.localId ?? 0)
                : (b.localId ?? 0).compareTo(a.localId ?? 0);
          }
          if (aDate == null) return ascending ? 1 : -1;
          if (bDate == null) return ascending ? -1 : 1;
          return ascending
              ? aDate.compareTo(bDate)
              : bDate.compareTo(aDate);
        });
    }

    return result;
  }

  List<TaskModel> get pendingTasks =>
      displayTasks.where((t) => !t.completed).toList();

  List<TaskModel> get completedTasks {
    final result = displayTasks.where((t) => t.completed).toList();
    return result;
  }

  bool get showReachedMax =>
      hasReachedMax &&
          searchQuery.isEmpty &&
          filter == TaskFilter.all;


  TaskState copyWith({
    List<TaskModel>? tasks,
    TaskStatus? status,
    String? errorMessage,
    String? searchQuery,
    TaskFilter? filter,
    TaskSort? sort,
    bool? ascending,
    bool? hasReachedMax,
    int? currentSkip,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      status: status ?? this.status,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      ascending: ascending ?? this.ascending,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentSkip: currentSkip ?? this.currentSkip,
    );
  }
}