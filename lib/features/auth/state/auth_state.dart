// AuthState is a small state machine for authentication.
// Each subclass represents one clear screen/application condition.
sealed class AuthState {
  const AuthState();

  // Used while the app is checking whether an existing session can be restored.
  const factory AuthState.initializing() = AuthInitializing;

  // Used when no user is signed in and protected pages should be blocked.
  const factory AuthState.unauthenticated() = AuthUnauthenticated;

  // Used while a login request is in progress.
  const factory AuthState.authenticating() = AuthAuthenticating;

  // The only state that is allowed to hold user data and the access token.
  const factory AuthState.authenticated({
    required AuthUser user,
    required String accessToken,
  }) = AuthAuthenticated;

  // Used when authentication fails and the UI needs a safe message to display.
  const factory AuthState.failure(String message) = AuthFailure;
}

// Startup/session-restore is still in progress.
final class AuthInitializing extends AuthState {
  const AuthInitializing();
}

// The user is not signed in.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

// The user submitted login credentials and the app is waiting for a result.
final class AuthAuthenticating extends AuthState {
  const AuthAuthenticating();
}

// A valid in-memory session exists.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user, required this.accessToken});

  // Minimal identity needed by the UI.
  final AuthUser user;

  // Access token is kept in memory only. It must not be persisted.
  final String accessToken;
}

// Authentication failed. Keep this message user-facing and avoid raw API errors.
final class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;
}

// Minimal user model for auth state.
// API-specific DTOs will be added later in the data layer.
final class AuthUser {
  const AuthUser({required this.id, required this.email, this.name});

  final String id;
  final String email;
  final String? name;
}
