import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:frontend/blocs/auth_bloc.dart';
import 'package:frontend/services/auth_service.dart';

// Generar mocks
@GenerateMocks([AuthService])
import 'auth_bloc_test.mocks.dart';

void main() {
  group('AuthBloc', () {
    late MockAuthService mockAuthService;
    late AuthBloc authBloc;

    setUp(() {
      mockAuthService = MockAuthService();
      authBloc = AuthBloc(authService: mockAuthService);
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    group('AuthLogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthUnauthenticated] when logout is successful',
        build: () {
          when(mockAuthService.signOut()).thenAnswer((_) async {});
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLogoutRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthUnauthenticated>(),
        ],
        verify: (_) {
          verify(mockAuthService.signOut()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthFailure] when logout fails',
        build: () {
          when(mockAuthService.signOut()).thenThrow(Exception('Logout failed'));
          return authBloc;
        },
        act: (bloc) => bloc.add(AuthLogoutRequested()),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthFailure>(),
        ],
        verify: (_) {
          verify(mockAuthService.signOut()).called(1);
        },
      );
    });
  });
}
