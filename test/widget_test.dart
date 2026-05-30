import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_starter/app/app.dart';
import 'package:flutter_starter/app/router.dart';

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

  testWidgets('Dashboard route shows the dashboard placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: App(initialLocation: AppRoutePaths.dashboard)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard placeholder'), findsOneWidget);
  });

  testWidgets('Unknown route shows not found', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: App(initialLocation: '/unknown')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Not Found'), findsOneWidget);
  });
}
