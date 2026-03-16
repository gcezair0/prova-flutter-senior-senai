import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/domain/task_repository.dart';
import '../data/models/task_model.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _repository;
  static const _pageSize = 20;

  List<TaskModel> _allTasks = [];

  TaskBloc(this._repository) : super(const TaskState()) {
    on<TasksLoadRequested>(_onLoad);
    on<TasksLoadMoreRequested>(_onLoadMore);
    on<TaskSearchChanged>(_onSearchChanged);
    on<TaskFilterChanged>(_onFilterChanged);
    on<TaskSortChanged>(_onSortChanged);
    on<TaskSortOrderToggled>(_onSortOrderToggled);
    on<TaskCreateRequested>(_onCreate);
    on<TaskUpdateRequested>(_onUpdate);
    on<TaskDeleteRequested>(_onDelete);
    on<TaskToggleCompleted>(_onToggle);
  }

  Future<void> _onLoad(
      TasksLoadRequested event,
      Emitter<TaskState> emit,
      ) async {
    emit(state.copyWith(status: TaskStatus.loading, currentSkip: 0));
    try {
      _allTasks = await _repository.getTasksByUser(
        event.userId,
        limit: 9999,
        skip: 0,
      );

      final firstPage = _allTasks.take(_pageSize).toList();

      emit(state.copyWith(
        tasks: firstPage,
        status: TaskStatus.success,
        currentSkip: firstPage.length,
        hasReachedMax: firstPage.length >= _allTasks.length,
      ));
    } catch (e) {
    }
  }

  Future<void> _onLoadMore(
      TasksLoadMoreRequested event,
      Emitter<TaskState> emit,
      ) async {

    if (state.hasReachedMax || state.status == TaskStatus.loadingMore) return;

    emit(state.copyWith(status: TaskStatus.loadingMore));
    await Future.delayed(const Duration(milliseconds: 300));

    final nextPage = _allTasks
        .skip(state.currentSkip)
        .take(_pageSize)
        .toList();

    if (nextPage.isEmpty) {
      emit(state.copyWith(status: TaskStatus.success, hasReachedMax: true));
      return;
    }

    final updated = [...state.tasks, ...nextPage];
    emit(state.copyWith(
      tasks: updated,
      status: TaskStatus.success,
      currentSkip: state.currentSkip + nextPage.length,
      hasReachedMax: updated.length >= _allTasks.length,
    ));
  }


  void _onSearchChanged(TaskSearchChanged event, Emitter<TaskState> emit) {
    emit(state.copyWith(
      searchQuery: event.query,
    ));
  }

  void _onFilterChanged(TaskFilterChanged event, Emitter<TaskState> emit) {
    emit(state.copyWith(filter: event.filter));
  }

  void _onSortChanged(TaskSortChanged event, Emitter<TaskState> emit) {
    emit(state.copyWith(sort: event.sort));
  }

  void _onSortOrderToggled(
      TaskSortOrderToggled event,
      Emitter<TaskState> emit,
      ) {
    emit(state.copyWith(ascending: !state.ascending));
  }

  Future<void> _onCreate(
      TaskCreateRequested event,
      Emitter<TaskState> emit,
      ) async {
    try {
      final task = await _repository.createTask(
        todo: event.todo,
        description: event.description ?? '',
        userId: event.userId,
      );
      final exists = state.tasks.any((t) => t.localId == task.localId);
      if (!exists) {
        _allTasks = [task, ..._allTasks];
        emit(state.copyWith(tasks: [task, ...state.tasks]));
      }
    } catch (_) {
      emit(state.copyWith(
        status: TaskStatus.failure,
        errorMessage: 'Erro ao criar tarefa',
      ));
    }
  }

  Future<void> _onDelete(
      TaskDeleteRequested event,
      Emitter<TaskState> emit,
      ) async {
    final previous = state.tasks;
    try {
      _allTasks = _allTasks.where((t) => t.localId != event.localId).toList();
      final newList = state.tasks.where((t) => t.localId != event.localId).toList();
      emit(state.copyWith(tasks: newList));
      await _repository.deleteTask(event.localId);
    } catch (_) {
      _allTasks = previous;
      emit(state.copyWith(
        tasks: previous,
        status: TaskStatus.failure,
        errorMessage: 'Erro ao excluir — revertido',
      ));
    }
  }

  Future<void> _onToggle(
      TaskToggleCompleted event,
      Emitter<TaskState> emit,
      ) async {
    _allTasks = _allTasks.map((t) {
      return t.localId == event.task.localId
          ? t.copyWith(completed: !t.completed)
          : t;
    }).toList();

    final optimistic = state.tasks.map((t) {
      return t.localId == event.task.localId
          ? t.copyWith(completed: !t.completed)
          : t;
    }).toList();
    emit(state.copyWith(tasks: optimistic));

    await _repository.updateTask(
      event.task.id,
      completed: !event.task.completed,
      localId: event.task.localId,
    );
  }

  Future<void> _onUpdate(
      TaskUpdateRequested event,
      Emitter<TaskState> emit,
      ) async {
    final previous = state.tasks;
    try {
      if (event.id == 0) {
        await _repository.updateTask(
          0,
          todo: event.todo,
          description: event.description,
          completed: event.completed,
          localId: event.localId,
        );
        final newList = state.tasks.map((t) {
          return t.localId == event.localId
              ? t.copyWith(
            todo: event.todo ?? t.todo,
            description: event.description ?? t.description,
            completed: event.completed ?? t.completed,
          )
              : t;
        }).toList();
        emit(state.copyWith(tasks: newList));
        return;
      }

      final updated = await _repository.updateTask(
        event.id,
        todo: event.todo,
        description: event.description,
        completed: event.completed,
        localId: event.localId,
      );
      final newList = state.tasks
          .map((t) => t.localId == event.localId ? updated : t)
          .toList();
      emit(state.copyWith(tasks: newList));
    } catch (_) {
      emit(state.copyWith(
        tasks: previous,
        status: TaskStatus.failure,
        errorMessage: 'Erro ao atualizar — revertido',
      ));
    }
  }

}