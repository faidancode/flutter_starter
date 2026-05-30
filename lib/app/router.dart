import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';

class AppRoutePaths {
  AppRoutePaths._();

  // Central route paths keep navigation calls from scattering string literals.
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const notFound = '/not-found';
}

class AppRouteNames {
  AppRouteNames._();

  static const login = 'login';
  static const dashboard = 'dashboard';
  static const notFound = 'not-found';
}

GoRouter createAppRouter({String initialLocation = AppRoutePaths.login}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutePaths.login,
        name: AppRouteNames.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutePaths.dashboard,
        name: AppRouteNames.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutePaths.notFound,
        name: AppRouteNames.notFound,
        builder: (context, state) => const NotFoundPlaceholderPage(),
      ),
    ],
    // Unknown paths render a page instead of leaving the user on a blank screen.
    errorBuilder: (context, state) => const NotFoundPlaceholderPage(),
  );
}

class NotFoundPlaceholderPage extends StatelessWidget {
  const NotFoundPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RoutePlaceholderPage(
      title: 'Not Found',
      icon: Icons.search_off_rounded,
    );
  }
}

class _RoutePlaceholderPage extends StatelessWidget {
  const _RoutePlaceholderPage({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Employee Attendance')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 40, color: theme.colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
