import 'package:flutter_bloc/flutter_bloc.dart';
import '../../tasks/data/domain/task_repository.dart';
import '../data/datasources/quote_remote_datasource.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TaskRepository _taskRepository;
  final QuoteRemoteDataSource _quoteDataSource;

  DashboardBloc({
    required TaskRepository taskRepository,
    required QuoteRemoteDataSource quoteDataSource,
  })  : _taskRepository = taskRepository,
        _quoteDataSource = quoteDataSource,
        super(const DashboardState()) {
    on<DashboardStarted>(_onStarted);
    on<DashboardRefreshed>(_onRefreshed);
    on<DashboardTaskCreated>(_onTaskCreated);
    on<DashboardTaskDeleted>(_onTaskDeleted);
    on<DashboardTaskToggled>(_onTaskToggled);
    on<DashboardTaskCreateRequested>(_onCreateTask);
  }

  Future<void> _onCreateTask(
      DashboardTaskCreateRequested event,
      Emitter<DashboardState> emit,
      ) async {
    try {
      final task = await _taskRepository.createTask(
        todo: event.todo,
        description: event.description,
        userId: event.userId,
      );
      final exists = state.tasks.any((t) => t.localId == task.localId);
      if (!exists) {
        emit(state.copyWith(tasks: [task, ...state.tasks]));
      }
    } catch (_) {}
  }


  Future<void> _onStarted(
      DashboardStarted event,
      Emitter<DashboardState> emit,
      ) async {
    await Future.wait([
      _loadTasks(emit, event.user.id),
      _loadQuote(emit),
    ]);
  }

  Future<void> _onRefreshed(
      DashboardRefreshed event,
      Emitter<DashboardState> emit,
      ) async {
    await Future.wait([
      _loadTasks(emit, event.user.id),
      _loadQuote(emit),
    ]);
  }

  Future<void> _loadQuote(Emitter<DashboardState> emit) async {
    emit(state.copyWith(isLoadingQuote: true));
    try {
      final quote = await _quoteDataSource.getRandomQuote();
      emit(state.copyWith(
        quote: quote,
        isLoadingQuote: false,
        quoteError: null,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoadingQuote: false,
        quoteError: 'Não foi possível carregar a frase',
      ));
    }
  }

  void _onTaskCreated(
      DashboardTaskCreated event,
      Emitter<DashboardState> emit,
      ) {
    final exists = state.tasks.any((t) => t.localId == event.task.localId);
    if (exists) return;
    emit(state.copyWith(tasks: [event.task, ...state.tasks]));
  }

  void _onTaskDeleted(
      DashboardTaskDeleted event,
      Emitter<DashboardState> emit,
      ) {
    final updated = state.tasks.where((t) => t.id != event.taskId).toList();
    emit(state.copyWith(tasks: updated));
  }

  void _onTaskToggled(
      DashboardTaskToggled event,
      Emitter<DashboardState> emit,
      ) {
    final updated = state.tasks.map((t) {
      return t.id == event.task.id
          ? t.copyWith(completed: !t.completed)
          : t;
    }).toList();
    emit(state.copyWith(tasks: updated));
  }

  Future<void> _loadTasks(Emitter<DashboardState> emit, int userId) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final tasks = await _taskRepository.getTasksByUser(
        userId,
        limit: 100,
        skip: 0,
      );
      emit(state.copyWith(
        tasks: tasks,
        status: DashboardStatus.success,
        errorMessage: null,
      ));
    } catch (_) {
      try {
        final cached = await _taskRepository.getCachedTasksByUser(userId);
        emit(state.copyWith(
          tasks: cached,
          status: DashboardStatus.success,
          errorMessage: cached.isNotEmpty
              ? 'Sem conexão — exibindo dados salvos'
              : null,
        ));
      } catch (_) {
        emit(state.copyWith(
          status: DashboardStatus.failure,
          errorMessage: 'Não foi possível carregar as tarefas',
        ));
      }
    }
  }
}