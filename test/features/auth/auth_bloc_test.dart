import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_radar/features/auth/bloc/auth_bloc.dart';

import '../../mocks/fake_user.dart';
import '../../mocks/mocks.dart';

void main() {
  late MockAuthRepository authRepository;


  setUpAll(() {
    registerFallbackValue(FakeUserModel());
  });

  setUp(() {
    authRepository = MockAuthRepository();
    when(() => authRepository.login(any(), any()))
        .thenAnswer((_) async => fakeAdminUser);
    when(() => authRepository.logout())
        .thenAnswer((_) async {});
    when(() => authRepository.isAuthenticated())
        .thenAnswer((_) async => false);
    when(() => authRepository.getMe())
        .thenAnswer((_) async => fakeAdminUser);
  });

  group('AuthBloc', () {
    blocTest<AuthBloc, AuthState>(
      'emite [loading, authenticated] quando login é bem-sucedido',
      build: () {
        when(() => authRepository.login(any(), any()))
            .thenAnswer((_) async => fakeAdminUser);
        when(() => authRepository.getMe())
            .thenAnswer((_) async => fakeAdminUser);
        return AuthBloc(authRepository);
      },
      act: (bloc) => bloc.add(
        AuthEvent.loginRequested(
          username: 'emilys',
          password: 'emilyspass',
        ),
      ),
      expect: () => [
        const AuthState.loading(),
        AuthState.authenticated(fakeAdminUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emite [loading, error] quando credenciais são inválidas',
      build: () {
        when(() => authRepository.login('wrong', 'wrong'))
            .thenThrow(Exception('Credenciais inválidas'));
        return AuthBloc(authRepository);
      },
      act: (bloc) => bloc.add(
        AuthEvent.loginRequested(
          username: 'wrong',
          password: 'wrong',
        ),
      ),
      expect: () => [
        const AuthState.loading(),
        isA<AuthState>().having(
              (s) => s.maybeWhen(error: (_) => true, orElse: () => false),
          'is error',
          true,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emite [unauthenticated] quando logout é solicitado',
      build: () {
        when(() => authRepository.logout()).thenAnswer((_) async {});
        return AuthBloc(authRepository);
      },
      act: (bloc) => bloc.add(const AuthEvent.logoutRequested()),
      expect: () => [const AuthState.unauthenticated()],
    );
  });
}