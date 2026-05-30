import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/auth_controller.dart';
import '../state/auth_state.dart';
import 'widgets/login_form.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
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
    // Watching auth state makes this page rebuild when login starts, fails,
    // or succeeds. The controller remains the only place that mutates auth.
    final authState = ref.watch(authControllerProvider);
    final isAuthenticating = authState is AuthAuthenticating;
    final errorMessage = authState is AuthFailure ? authState.message : null;
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
                        isSubmitting: isAuthenticating,
                        errorMessage: errorMessage,
                        onSubmit: _handleSubmit,
                      ),
                      if (authState is AuthAuthenticated) ...[
                        const SizedBox(height: 12),
                        _AuthSuccessMessage(email: authState.user.email),
                      ],
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

  Future<void> _handleSubmit(String email, String password) async {
    // The UI submits credentials to the controller, then reacts to provider
    // state changes instead of storing its own login result.
    FocusScope.of(context).unfocus();
    await ref.read(authControllerProvider.notifier).login(email, password);
  }
}

class _AuthSuccessMessage extends StatelessWidget {
  const _AuthSuccessMessage({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      child: Text(
        'Signed in as $email. Dashboard routing is added in a later phase.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
      ),
    );
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
