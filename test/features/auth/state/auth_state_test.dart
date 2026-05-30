import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/features/auth/state/auth_state.dart';

void main() {
  group('AuthState', () {
    test('creates initializing state', () {
      const state = AuthState.initializing();

      expect(state, isA<AuthInitializing>());
    });

    test('creates unauthenticated state', () {
      const state = AuthState.unauthenticated();

      expect(state, isA<AuthUnauthenticated>());
    });

    test('creates authenticating state', () {
      const state = AuthState.authenticating();

      expect(state, isA<AuthAuthenticating>());
    });

    test('stores user data and access token only when authenticated', () {
      const user = AuthUser(
        id: 'employee-1',
        email: 'employee@example.com',
        name: 'Employee One',
      );
      const state = AuthState.authenticated(
        user: user,
        accessToken: 'access-token',
      );
      final authenticatedState = state as AuthAuthenticated;

      expect(state, isA<AuthAuthenticated>());
      expect(authenticatedState.user, user);
      expect(authenticatedState.accessToken, 'access-token');
    });

    test('creates failure state with safe message', () {
      const state = AuthState.failure('Invalid email or password.');
      final failureState = state as AuthFailure;

      expect(state, isA<AuthFailure>());
      expect(failureState.message, 'Invalid email or password.');
    });
  });
}
