import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/features/auth/presentation/login_page.dart';

void main() {
  testWidgets('LoginPage shows loading then fake authenticated state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginPage())),
    );

    await tester.enterText(
      find.byType(EditableText).at(0),
      'employee@example.com',
    );
    await tester.enterText(find.byType(EditableText).at(1), 'password123');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(
      find.text(
        'Signed in as employee@example.com. Dashboard routing is added in a later phase.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('LoginPage shows fake auth failure message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginPage())),
    );

    await tester.enterText(
      find.byType(EditableText).at(0),
      'employee@example.com',
    );
    await tester.enterText(find.byType(EditableText).at(1), 'fail');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Invalid email or password.'), findsOneWidget);
  });
}
