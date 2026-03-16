import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/data/datasources/auth_local_datasource.dart';
import '../../auth/data/domain/auth_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository _authRepository;
  final AuthLocalDataSource _localDataSource;

  ProfileBloc({
    required AuthRepository authRepository,
    required AuthLocalDataSource localDataSource,
  })  : _authRepository = authRepository,
        _localDataSource = localDataSource,
        super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileRetryRequested>(_onRetry);
  }

  Future<void> _onLoad(
      ProfileLoadRequested event,
      Emitter<ProfileState> emit,
      ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final user = await _authRepository.getMe();
      emit(state.copyWith(
        user: user,
        status: ProfileStatus.success,
      ));
    } catch (_) {
      try {
        final cached = await _localDataSource.getUser();
        if (cached != null) {
          emit(state.copyWith(
            user: cached,
            status: ProfileStatus.success,
          ));
        } else {
          emit(state.copyWith(
            status: ProfileStatus.failure,
            errorMessage: 'Não foi possível carregar as informações',
          ));
        }
      } catch (_) {
        emit(state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'Não foi possível carregar as informações',
        ));
      }
    }
  }

  Future<void> _onRetry(
      ProfileRetryRequested event,
      Emitter<ProfileState> emit,
      ) async {
    add(ProfileLoadRequested());
  }
}