import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/domain/auth_repository.dart';
import '../../shared/data/models/user_model.dart';
part 'auth_bloc.freezed.dart';

@freezed
abstract class AuthEvent with _$AuthEvent {
  const factory AuthEvent.loginRequested({
    required String username,
    required String password,
  }) = _LoginRequested;

  const factory AuthEvent.logoutRequested() = _LogoutRequested;
}

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(UserModel user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc(this._repository) : super(const AuthState.initial()) {
    on<_LoginRequested>(_onLogin);
    on<_LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(
      _LoginRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthState.loading());
    try {
      await _repository.login(event.username, event.password);

      final user = await _repository.getMe();

      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.error(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLogout(
      _LogoutRequested event,
      Emitter<AuthState> emit,
      ) async {
    await _repository.logout();
    emit(const AuthState.unauthenticated());
  }
}