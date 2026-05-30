import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'theme.dart';

class App extends StatefulWidget {
  const App({
    super.key,
    this.initialLocation = AppRoutePaths.login,
  });

  final String initialLocation;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Keep one router instance for the lifetime of the app widget.
  late final GoRouter _router = createAppRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Employee Attendance',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: _router,
    );
  }
}
