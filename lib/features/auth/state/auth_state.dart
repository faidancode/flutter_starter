sealed class AuthState {
  const AuthState();

  const factory AuthState.initializing() = AuthInitializing;

  const factory AuthState.unauthenticated() = AuthUnauthenticated;

  const factory AuthState.authenticating() = AuthAuthenticating;

  const factory AuthState.authenticated({
    required AuthUser user,
    required String accessToken,
  }) = AuthAuthenticated;

  const factory AuthState.failure(String message) = AuthFailure;
}

final class AuthInitializing extends AuthState {
  const AuthInitializing();
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthAuthenticating extends AuthState {
  const AuthAuthenticating();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user, required this.accessToken});

  final AuthUser user;
  final String accessToken;
}

final class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;
}

final class AuthUser {
  const AuthUser({required this.id, required this.email, this.name});

  final String id;
  final String email;
  final String? name;
}
