import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_state.dart';

// Riverpod provider that exposes the current AuthState and controller actions.
// UI code will watch this provider in later phases.
final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

// AuthController is the single owner of authentication state transitions.
// Screens should call methods here instead of changing AuthState directly.
class AuthController extends Notifier<AuthState> {
  // Temporary delay so fake login/restore can show loading states in the UI.
  // This will be removed or replaced when real API calls are added.
  static const _fakeDelay = Duration(milliseconds: 300);

  @override
  AuthState build() {
    // Initial fake behavior: no persisted session exists yet.
    // Phase 8 will replace this with secure storage/session restore logic.
    return const AuthState.unauthenticated();
  }

  // Fake login for learning the auth flow before connecting the API.
  // Later this will call AuthRepository.login(email, password).
  Future<void> login(String email, String password) async {
    // Move to loading state first so the UI can disable the button/spinner.
    state = const AuthState.authenticating();

    await Future<void>.delayed(_fakeDelay);

    // Fake successful login.
    // Only AuthAuthenticated contains the access token, and it stays in memory.
    state = AuthState.authenticated(
      user: AuthUser(
        id: 'fake-employee',
        email: email.trim(),
        name: 'Employee',
      ),
      accessToken: 'fake-access-token',
    );
  }

  // Logout clears the in-memory auth state.
  // Secure storage cleanup will be added when refresh token storage exists.
  void logout() {
    state = const AuthState.unauthenticated();
  }

  // Fake session restoration.
  // For now it always ends unauthenticated because secure storage is not added yet.
  Future<void> restoreSession() async {
    // Initializing lets the router/UI avoid deciding too early.
    state = const AuthState.initializing();

    await Future<void>.delayed(_fakeDelay);

    state = const AuthState.unauthenticated();
  }
}
