import 'package:flutter/material.dart';

import 'widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers let the page own and dispose the text input state.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Add bottom padding when the keyboard is open so fields remain reachable.
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottomInset),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _AppMark(),
                      const SizedBox(height: 40),
                      Text(
                        'Employee Attendance',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to manage your attendance record.',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 32),
                      LoginForm(
                        emailController: _emailController,
                        passwordController: _passwordController,
                        onSubmit: _handleSubmit,
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          'Use your company email and password.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleSubmit(String _email, String _password) {
    // Real login behavior is added in later phases; this only closes the keyboard.
    FocusScope.of(context).unfocus();
  }
}

class _AppMark extends StatelessWidget {
  const _AppMark();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.fact_check_outlined,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}
