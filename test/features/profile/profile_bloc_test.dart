import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_radar/features/profile/bloc/profile_bloc.dart';
import 'package:task_radar/features/profile/bloc/profile_event.dart';
import 'package:task_radar/features/profile/bloc/profile_state.dart';

import '../../mocks/fake_user.dart';
import '../../mocks/mocks.dart';

void main() {
  late MockAuthRepository authRepository;
  late MockAuthLocalDataSource localDataSource;

  setUp(() {
    authRepository = MockAuthRepository();
    localDataSource = MockAuthLocalDataSource();
  });

  group('ProfileBloc', () {
    blocTest<ProfileBloc, ProfileState>(
      'emite [loading, success] quando getMe retorna usuário',
      build: () {
        when(() => authRepository.getMe())
            .thenAnswer((_) async => fakeAdminUser);
        return ProfileBloc(
          authRepository: authRepository,
          localDataSource: localDataSource,
        );
      },
      act: (bloc) => bloc.add(ProfileLoadRequested()),
      expect: () => [
        isA<ProfileState>().having(
              (s) => s.status,
          'status',
          ProfileStatus.loading,
        ),
        isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.success)
            .having((s) => s.user?.id, 'user id', 1),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emite [loading, success] com fallback do banco quando API falha',
      build: () {
        when(() => authRepository.getMe()).thenThrow(Exception('Sem conexão'));
        when(() => localDataSource.getUser())
            .thenAnswer((_) async => fakeAdminUser);
        return ProfileBloc(
          authRepository: authRepository,
          localDataSource: localDataSource,
        );
      },
      act: (bloc) => bloc.add(ProfileLoadRequested()),
      expect: () => [
        isA<ProfileState>().having(
              (s) => s.status,
          'status',
          ProfileStatus.loading,
        ),
        isA<ProfileState>()
            .having((s) => s.status, 'status', ProfileStatus.success)
            .having((s) => s.user?.id, 'user id', 1),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emite [loading, failure] quando API e banco falham',
      build: () {
        when(() => authRepository.getMe()).thenThrow(Exception('Sem conexão'));
        when(() => localDataSource.getUser()).thenAnswer((_) async => null);
        return ProfileBloc(
          authRepository: authRepository,
          localDataSource: localDataSource,
        );
      },
      act: (bloc) => bloc.add(ProfileLoadRequested()),
      expect: () => [
        isA<ProfileState>().having(
              (s) => s.status,
          'status',
          ProfileStatus.loading,
        ),
        isA<ProfileState>().having(
              (s) => s.status,
          'status',
          ProfileStatus.failure,
        ),
      ],
    );
  });
}