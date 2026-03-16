import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_radar/features/admin/bloc/users_bloc.dart';
import 'package:task_radar/features/admin/bloc/users_event.dart';
import 'package:task_radar/features/admin/bloc/users_state.dart';

import '../../mocks/fake_user.dart';
import '../../mocks/mocks.dart';

final _fakeUsers = [
  fakeAdminUser,
  fakeModeratorUser,
];

void main() {
  late MockUsersRepository usersRepository;

  setUp(() {
    usersRepository = MockUsersRepository();
  });

  group('UsersBloc', () {
    blocTest<UsersBloc, UsersState>(
      'emite [loading, success] quando carrega usuários',
      build: () {
        when(() => usersRepository.getUsers())
            .thenAnswer((_) async => _fakeUsers);
        return UsersBloc(usersRepository);
      },
      act: (bloc) => bloc.add(UsersLoadRequested()),
      expect: () => [
        isA<UsersState>().having(
              (s) => s.status,
          'status',
          UsersStatus.loading,
        ),
        isA<UsersState>()
            .having((s) => s.status, 'status', UsersStatus.success)
            .having((s) => s.users.length, 'users length', 2),
      ],
    );

    blocTest<UsersBloc, UsersState>(
      'filtra apenas admins corretamente',
      build: () => UsersBloc(usersRepository),
      seed: () => UsersState(
        users: _fakeUsers,
        status: UsersStatus.success,
      ),
      act: (bloc) => bloc.add(UsersFilterChanged(UsersFilter.admin)),
      expect: () => [
        isA<UsersState>().having(
              (s) => s.filter,
          'filter',
          UsersFilter.admin,
        ),
      ],
      verify: (bloc) {
        expect(bloc.state.admins.length, 1);
        expect(bloc.state.moderators.length, 0);
      },
    );

    blocTest<UsersBloc, UsersState>(
      'filtra apenas moderators corretamente',
      build: () => UsersBloc(usersRepository),
      seed: () => UsersState(
        users: _fakeUsers,
        status: UsersStatus.success,
      ),
      act: (bloc) => bloc.add(UsersFilterChanged(UsersFilter.moderator)),
      verify: (bloc) {
        expect(bloc.state.moderators.length, 1);
        expect(bloc.state.admins.length, 0);
      },
    );

    blocTest<UsersBloc, UsersState>(
      'busca usuário por nome corretamente',
      build: () => UsersBloc(usersRepository),
      seed: () => UsersState(
        users: _fakeUsers,
        status: UsersStatus.success,
      ),
      act: (bloc) => bloc.add(UsersSearchChanged('Emily')),
      verify: (bloc) {
        expect(bloc.state.displayUsers.length, 1);
        expect(bloc.state.displayUsers.first.firstName, 'Emily');
      },
    );

    blocTest<UsersBloc, UsersState>(
      'emite [loading, failure] quando repositório lança exceção',
      build: () {
        when(() => usersRepository.getUsers())
            .thenThrow(Exception('Erro de rede'));
        return UsersBloc(usersRepository);
      },
      act: (bloc) => bloc.add(UsersLoadRequested()),
      expect: () => [
        isA<UsersState>().having(
              (s) => s.status,
          'status',
          UsersStatus.loading,
        ),
        isA<UsersState>().having(
              (s) => s.status,
          'status',
          UsersStatus.failure,
        ),
      ],
    );
  });
}