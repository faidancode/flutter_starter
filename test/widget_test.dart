import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_starter/app/app.dart';
import 'package:flutter_starter/app/router.dart';
import 'package:flutter_starter/features/auth/state/auth_controller.dart';
import 'package:flutter_starter/features/auth/state/auth_state.dart';

void main() {
  testWidgets('Initial route shows the login page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    expect(find.text('Employee Attendance'), findsOneWidget);
    expect(find.text('Login'), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('Login fields can be filled', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(EditableText).at(0),
      'employee@example.com',
    );
    await tester.enterText(find.byType(EditableText).at(1), 'password123');

    expect(find.text('employee@example.com'), findsOneWidget);
    expect(find.text('password123'), findsOneWidget);
  });

  testWidgets('Dashboard route shows user identity and logout button', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        authControllerProvider.overrideWith(_AuthenticatedAuthController.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const App(initialLocation: AppRoutePaths.dashboard),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Welcome back, Employee.'), findsOneWidget);
    expect(find.text('Employee'), findsOneWidget);
    expect(find.text('employee@example.com'), findsOneWidget);
    expect(find.byTooltip('Logout'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.logout_rounded));
    await tester.pumpAndSettle();

    expect(container.read(authControllerProvider), isA<AuthUnauthenticated>());
  });

  testWidgets('Unknown route shows not found', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: App(initialLocation: '/unknown')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Not Found'), findsOneWidget);
  });
}

class _AuthenticatedAuthController extends AuthController {
  @override
  AuthState build() {
    return const AuthState.authenticated(
      user: AuthUser(
        id: 'fake-employee',
        email: 'employee@example.com',
        name: 'Employee',
      ),
      accessToken: 'fake-access-token',
    );
  }
}
