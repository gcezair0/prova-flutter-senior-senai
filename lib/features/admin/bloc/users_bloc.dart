import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/domain/users_repository.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UsersRepository _repository;

  UsersBloc(this._repository) : super(const UsersState()) {
    on<UsersLoadRequested>(_onLoad);
    on<UsersSearchChanged>(_onSearchChanged);
    on<UsersFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoad(
      UsersLoadRequested event,
      Emitter<UsersState> emit,
      ) async {
    emit(state.copyWith(status: UsersStatus.loading));
    try {
      final users = await _repository.getUsers();
      emit(state.copyWith(
        users: users,
        status: UsersStatus.success,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: UsersStatus.failure,
        errorMessage: 'Não foi possível carregar os usuários',
      ));
    }
  }

  void _onSearchChanged(
      UsersSearchChanged event,
      Emitter<UsersState> emit,
      ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onFilterChanged(
      UsersFilterChanged event,
      Emitter<UsersState> emit,
      ) {
    emit(state.copyWith(filter: event.filter));
  }
}