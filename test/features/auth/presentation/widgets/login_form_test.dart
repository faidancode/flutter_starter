import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/features/auth/presentation/widgets/login_form.dart';

void main() {
  testWidgets('LoginForm calls onSubmit with email and password', (
    WidgetTester tester,
  ) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String? submittedEmail;
    String? submittedPassword;

    addTearDown(emailController.dispose);
    addTearDown(passwordController.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoginForm(
            emailController: emailController,
            passwordController: passwordController,
            onSubmit: (email, password) {
              submittedEmail = email;
              submittedPassword = password;
            },
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byType(EditableText).at(0),
      'employee@example.com',
    );
    await tester.enterText(find.byType(EditableText).at(1), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(submittedEmail, 'employee@example.com');
    expect(submittedPassword, 'password123');
  });
}
