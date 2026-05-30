import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/features/auth/state/auth_controller.dart';
import 'package:flutter_starter/features/auth/state/auth_state.dart';

void main() {
  group('AuthController', () {
    test('starts unauthenticated', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(authControllerProvider),
        isA<AuthUnauthenticated>(),
      );
    });

    test('login changes state to authenticated with fake user data', () async {
      final container = ProviderContainer();
      final states = <AuthState>[];
      final subscription = container.listen(
        authControllerProvider,
        (_, next) => states.add(next),
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      addTearDown(container.dispose);

      await container
          .read(authControllerProvider.notifier)
          .login(' employee@example.com ', 'password123');

      expect(states, [
        isA<AuthUnauthenticated>(),
        isA<AuthAuthenticating>(),
        isA<AuthAuthenticated>(),
      ]);

      final state = container.read(authControllerProvider) as AuthAuthenticated;
      expect(state.user.id, 'fake-employee');
      expect(state.user.email, 'employee@example.com');
      expect(state.user.name, 'Employee');
      expect(state.accessToken, 'fake-access-token');
    });

    test('logout changes state to unauthenticated', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);
      await controller.login('employee@example.com', 'password123');

      controller.logout();

      expect(
        container.read(authControllerProvider),
        isA<AuthUnauthenticated>(),
      );
    });

    test(
      'restoreSession resolves to unauthenticated without storage',
      () async {
        final container = ProviderContainer();
        final states = <AuthState>[];
        final subscription = container.listen(
          authControllerProvider,
          (_, next) => states.add(next),
          fireImmediately: true,
        );
        addTearDown(subscription.close);
        addTearDown(container.dispose);

        await container.read(authControllerProvider.notifier).restoreSession();

        expect(states, [
          isA<AuthUnauthenticated>(),
          isA<AuthInitializing>(),
          isA<AuthUnauthenticated>(),
        ]);
        expect(
          container.read(authControllerProvider),
          isA<AuthUnauthenticated>(),
        );
      },
    );
  });
}
