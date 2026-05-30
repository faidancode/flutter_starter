import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/state/auth_controller.dart';
import '../../auth/state/auth_state.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // The dashboard reads auth state from Riverpod so identity display stays
    // connected to the same source of truth that future protected routing uses.
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;
    final displayName = _displayNameFor(user);
    final displayEmail = user?.email ?? 'employee@example.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Attendance'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Dashboard', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Welcome back, $displayName.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            _UserIdentityCard(name: displayName, email: displayEmail),
          ],
        ),
      ),
    );
  }

  String _displayNameFor(AuthUser? user) {
    final trimmedName = user?.name?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      return trimmedName;
    }

    final email = user?.email.trim();
    if (email != null && email.isNotEmpty) {
      return email;
    }

    // Phase 5 will prevent anonymous users from reaching this page. Until then,
    // a fake identity keeps Phase 4.a visible and testable in isolation.
    return 'Employee';
  }
}

class _UserIdentityCard extends StatelessWidget {
  const _UserIdentityCard({required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              child: const Icon(Icons.person_outline_rounded),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(email, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
