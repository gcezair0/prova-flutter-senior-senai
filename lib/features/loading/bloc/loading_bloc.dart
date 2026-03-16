import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/tasks/data/domain/task_repository.dart';
import '../../../features/auth/data/domain/auth_repository.dart';
import 'loading_event.dart';
import 'loading_state.dart';

class LoadingBloc extends Bloc<LoadingEvent, LoadingState> {
  final TaskRepository _taskRepository;
  final AuthRepository _authRepository;

  LoadingBloc({
    required TaskRepository taskRepository,
    required AuthRepository authRepository,
  })  : _taskRepository = taskRepository,
        _authRepository = authRepository,
        super(const LoadingState()) {
    on<LoadingStarted>(_onStarted);
  }

  Future<void> _onStarted(
      LoadingStarted event,
      Emitter<LoadingState> emit,
      ) async {
    emit(const LoadingState(status: LoadingStatus.loading));
    try {
      await Future.wait([
        _taskRepository.getTasksByUser(
          event.user.id,
          limit: 9999,
          skip: 0,
        ),
        _authRepository.getMe(),
      ]);

      emit(const LoadingState(status: LoadingStatus.success));
    } catch (e) {
      emit(LoadingState(
        status: LoadingStatus.failure,
        errorMessage: 'Não foi possível carregar os dados. Tente novamente.',
      ));
    }
  }
}