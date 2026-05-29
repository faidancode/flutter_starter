import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_starter/app/app.dart';
import 'package:flutter_starter/app/router.dart';

void main() {
  testWidgets('Initial route shows the login placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Login placeholder'), findsOneWidget);
  });

  testWidgets('Dashboard route shows the dashboard placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const App(initialLocation: AppRoutePaths.dashboard),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard placeholder'), findsOneWidget);
  });

  testWidgets('Unknown route shows not found', (WidgetTester tester) async {
    await tester.pumpWidget(const App(initialLocation: '/unknown'));
    await tester.pumpAndSettle();

    expect(find.text('Not Found'), findsOneWidget);
  });
}
