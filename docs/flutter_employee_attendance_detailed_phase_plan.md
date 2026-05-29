# Flutter Employee Attendance Detailed Phase Plan

## Document Purpose

This document is the technical breakdown of
[`flutter_hris_nfr_implementation_plan.md`](./flutter_hris_nfr_implementation_plan.md).
The global plan defines the larger target and NFR direction. This document
breaks the work into small phases so the implementation can be used as a
learning path for code flow, state, routing, services, and UI.

The initial product target is an Employee Attendance App. The first learning
scope does not include implementing attendance submission with photo, leave
requests, permission requests, overtime, payroll, or reports. The initial scope
only covers:

- Show the login page.
- Sign in through the API.
- Store the refresh token securely.
- Redirect a signed-in user to the dashboard.
- Protect the dashboard from anonymous users.
- Sign out and redirect back to login.
- Show an employee attendance dashboard menu as placeholders.

## Learning Principles

- Each small phase should produce a readable and testable change.
- Understand the data flow before adding new features.
- Separate UI, state, repository, network, and storage from the beginning.
- Do not store the access token in persistent storage.
- Do not continue to attendance or leave features before login, routing, and
  auth state are clear.

## Target Folder Structure

```text
lib/
  main.dart
  app/
    app.dart
    router.dart
    theme.dart
  core/
    config/
      app_config.dart
    errors/
      app_error.dart
    network/
      api_client.dart
      api_envelope.dart
    storage/
      secure_session_storage.dart
  features/
    auth/
      data/
        auth_api.dart
        auth_repository.dart
        auth_dto.dart
      state/
        auth_controller.dart
        auth_state.dart
      presentation/
        login_page.dart
        widgets/
          login_form.dart
    dashboard/
      domain/
        attendance_menu_item.dart
      presentation/
        dashboard_page.dart
        widgets/
          attendance_menu_grid.dart
          attendance_menu_tile.dart
test/
```

This structure can be adjusted to match the Flutter project style, but the
separation of responsibilities should remain.

## Phase 0 - Project Preparation

### Phase 0.a - Create The Flutter Project

Goal:
Create an empty project that can run.

Tasks:

- Create a new Flutter project.
- Run the default app on an emulator or device.
- Make sure `flutter doctor` does not show major blockers.

Concepts to learn:

- Basic Flutter project structure.
- The difference between `lib/`, `test/`, `android/`, and `ios/`.

Done when:

- The default app can open.
- `flutter test` runs.

### Phase 0.b - Add Core Dependencies

Goal:
Prepare the main packages for state, routing, network, and secure storage.

Tasks:

- Add `flutter_riverpod`.
- Add `go_router`.
- Add `dio`.
- Add `flutter_secure_storage`.
- Add supporting test packages if needed.

Concepts to learn:

- Riverpod as state management and dependency injection.
- GoRouter for route redirects.
- Dio as the HTTP client.
- Secure storage for the refresh token.

Done when:

- `flutter pub get` succeeds.
- The app still runs.
- `flutter analyze` has no new errors.

### Phase 0.c - Create The Initial Quality Gate

Goal:
Build the habit of validating each small phase.

Tasks:

- Run `dart format .`.
- Run `flutter analyze`.
- Run `flutter test`.
- Record these commands as the gate for every implementation phase.

Concepts to learn:

- Automatic formatting.
- Static analysis.
- Basic unit testing.

Done when:

- All initial gates pass.

## Phase 1 - Application Shell

### Phase 1.a - Create The Root App

Goal:
Replace the default app with the application's own root.

Tasks:

- Create `lib/app/app.dart`.
- Move the `MaterialApp` configuration into `App`.
- Wrap the app with `ProviderScope` in `main.dart`.
- Create a basic mobile-first theme.

Concepts to learn:

- Flutter entry point.
- Root widget.
- Riverpod `ProviderScope`.
- Separating app-level configuration from screens.

Done when:

- The app shows a temporary screen from `App`.
- There is no auth logic in `main.dart`.

### Phase 1.b - Create The App Theme

Goal:
Prepare a consistent visual baseline.

Tasks:

- Create `lib/app/theme.dart`.
- Define the primary color, text theme, input theme, and button theme.
- Make sure the UI is comfortable on mobile.

Concepts to learn:

- `ThemeData`.
- Reusable styling.
- UI consistency.

Done when:

- The theme is used by `MaterialApp`.
- The temporary page uses styles from the theme.

### Phase 1.c - Create The Minimal Router

Goal:
Prepare `/login`, `/dashboard`, and `/not-found` routes.

Tasks:

- Create `lib/app/router.dart`.
- Configure GoRouter.
- Create placeholder pages for login, dashboard, and not found.
- Set the initial route to `/login`.

Concepts to learn:

- Declarative routing.
- Route name and route path.
- Fallback page for unknown routes.

Done when:

- `/login` shows the Login placeholder.
- `/dashboard` shows the Dashboard placeholder.
- Unknown routes show Not Found.

## Phase 2 - Login UI Without API

### Phase 2.a - Create The Login Page

Goal:
Create a complete login UI that is not connected to the API yet.

Tasks:

- Create `login_page.dart`.
- Create a mobile layout with app title, email field, password field, login
  button, and error area.
- Use `SafeArea`.
- Make sure the keyboard does not break the layout.

Concepts to learn:

- Form layout.
- Basic responsiveness.
- Separating pages from smaller widgets.

Done when:

- The login page looks clean on a phone size.
- The fields can be filled.

### Phase 2.b - Create The Login Form Widget

Goal:
Split the form so the page does not become too large.

Tasks:

- Create `widgets/login_form.dart`.
- Move the email field, password field, and button into this widget.
- Add an `onSubmit` callback.

Concepts to learn:

- Stateless widget composition.
- Passing callbacks from parent to child.
- Reducing page responsibility.

Done when:

- The UI remains the same.
- The submit callback can be called.

### Phase 2.c - Add Form Validation

Goal:
Reject empty input before sending a login request.

Tasks:

- Add `Form` and `GlobalKey<FormState>`.
- Validate that email is required.
- Validate that password is required.
- Add a show/hide password toggle.

Concepts to learn:

- Flutter form validation.
- Local widget state.
- Loading and validation UX.

Done when:

- Submitting empty fields shows validation messages.
- The password toggle works.

## Phase 3 - Auth Model And State

### Phase 3.a - Create Auth State

Goal:
Define every possible auth condition explicitly.

Tasks:

- Create `auth_state.dart`.
- Define states: `initializing`, `unauthenticated`, `authenticating`,
  `authenticated`, and `failure`.
- Store user data and the access token only in the authenticated state.

Concepts to learn:

- A simple state machine.
- Why auth is not enough as a boolean `isLoggedIn`.
- The difference between loading, failure, and success states.

Done when:

- Auth state can be created in a unit test.
- No token is stored in a loose global variable.

### Phase 3.b - Create The Auth Controller

Goal:
Create the central place for login, logout, and session restoration actions.

Tasks:

- Create `auth_controller.dart`.
- Use a Riverpod `Notifier` or `AsyncNotifier`.
- Add `login(email, password)`.
- Add `logout()`.
- Add `restoreSession()`.
- Temporarily use fake success without the API.

Concepts to learn:

- Riverpod provider.
- Controller as the state owner.
- UI reads state instead of storing auth locally.

Done when:

- Submit login changes the state to authenticated.
- Logout changes the state to unauthenticated.

### Phase 3.c - Connect Login UI To Auth State

Goal:
Make the login form react to auth state.

Tasks:

- Make the login page read the auth controller.
- Disable the login button while `authenticating`.
- Show a loading indicator while login is running.
- Show an error message when the state is failure.

Concepts to learn:

- `ref.watch`.
- `ref.read`.
- UI as a representation of state.

Done when:

- Fake login shows a short loading state.
- A fake error can be displayed when the controller fails.

## Phase 4 - Dashboard Shell

### Phase 4.a - Create The Dashboard Page

Goal:
Create the destination page after login.

Tasks:

- Create `dashboard_page.dart`.
- Show the user's name or email from auth state.
- Add a logout button.

Concepts to learn:

- Reading the authenticated user from a provider.
- Triggering logout from the UI.

Done when:

- The dashboard can show a fake user identity.
- The logout button calls the auth controller.

### Phase 4.b - Create The Attendance Menu Model

Goal:
Define the dashboard menu as data.

Tasks:

- Create `attendance_menu_item.dart`.
- Use minimal fields: `label`, `description`, `icon`, and `status`.
- Create a list of 9 menu items:
  `Fill Attendance`, `Attendance History`, `Work Schedule`,
  `Request Leave`, `Request Permission`, `Overtime`, `Payslip`, `Profile`,
  and `Announcements`.

Concepts to learn:

- Data-driven UI.
- Why menu items should not be hardcoded repeatedly inside widgets.

Done when:

- The menu list can be tested to contain 9 items.

### Phase 4.c - Create The Menu Grid

Goal:
Show the dashboard menu in a mobile-first layout.

Tasks:

- Create `attendance_menu_grid.dart`.
- Create `attendance_menu_tile.dart`.
- Render 9 menu items from the model.
- Show `Coming soon` status on every tile.

Concepts to learn:

- `GridView`.
- Reusable tile widgets.
- Touch targets and accessibility labels.

Done when:

- The dashboard shows 9 menu items.
- Tiles do not open any feature yet.
- The layout does not clip on common phone widths.

## Phase 5 - Protected Routing

### Phase 5.a - Redirect Anonymous Users To Login

Goal:
Prevent users who are not signed in from opening the dashboard.

Tasks:

- Connect GoRouter to auth state.
- If the state is unauthenticated and the target is `/dashboard`, redirect to
  `/login`.
- If the state is initializing, show a simple loading or splash screen.

Concepts to learn:

- GoRouter redirect.
- Hydration race.
- Why protected routes must depend on resolved auth state.

Done when:

- Opening `/dashboard` while signed out always returns to `/login`.

### Phase 5.b - Redirect Authenticated Users To Dashboard

Goal:
Prevent users who are already signed in from using the login page again.

Tasks:

- If the state is authenticated and the target is `/login`, redirect to
  `/dashboard`.
- After successful login, use navigation replacement to `/dashboard`.

Concepts to learn:

- Two-way redirect.
- Back stack after login.

Done when:

- A signed-in user cannot return to login with the back button.

### Phase 5.c - Redirect Logout To Login

Goal:
Make sure logout clears the UI session and route.

Tasks:

- Clear auth state after logout.
- Replace the route with `/login`.
- Make sure the dashboard does not appear from the back stack.

Concepts to learn:

- The difference between `go`, `push`, and replacement behavior.
- Logout as a security boundary.

Done when:

- Logout always returns to login.
- The back button does not open the old dashboard.

## Phase 6 - API Client And DTO

### Phase 6.a - Create App Config

Goal:
Centralize API configuration.

Tasks:

- Create `app_config.dart`.
- Store the API base URL in one place.
- Make sure local development uses the `/api/v1` prefix when following the
  reference backend contract.

Concepts to learn:

- Environment configuration.
- Avoiding hardcoded URLs across many files.

Done when:

- Repositories do not write their own base URL.

### Phase 6.b - Create The Dio API Client

Goal:
Prepare the shared HTTP client.

Tasks:

- Create `api_client.dart`.
- Configure base URL, connect timeout, and receive timeout.
- Provide Dio through Riverpod.

Concepts to learn:

- Dependency injection for the HTTP client.
- Timeout as an early NFR.

Done when:

- Dio can be injected into services.
- No screen creates its own Dio instance.

### Phase 6.c - Create The Response Envelope

Goal:
Read API responses shaped as `{ "data": ... }`.

Tasks:

- Create `api_envelope.dart`.
- Create a generic parser or helper to extract `data`.
- Add tests for valid and invalid responses.

Concepts to learn:

- DTO parsing.
- Errors when the API shape is not as expected.

Done when:

- Unit tests for parsing pass.

### Phase 6.d - Create Auth DTO

Goal:
Define the login request and response models.

Tasks:

- Create `auth_dto.dart`.
- Define `LoginRequest`.
- Define `AuthResponse`.
- Define `UserDto` with the minimal fields needed by the UI.

Concepts to learn:

- The boundary between API data and UI state.
- JSON parsing without `any`.

Done when:

- DTOs have parsing tests.
- The access token and refresh token are parsed from the response.

## Phase 7 - Auth Repository And Secure Storage

### Phase 7.a - Create Secure Session Storage

Goal:
Store only the refresh token in secure storage.

Tasks:

- Create `secure_session_storage.dart`.
- Add methods: `readRefreshToken`, `saveRefreshToken`, and `clear`.
- Use `flutter_secure_storage`.

Concepts to learn:

- Secure storage vs shared preferences.
- Why the access token is not stored permanently.

Done when:

- Unit tests use fake storage or a wrapper.
- There is no method for storing the access token.

### Phase 7.b - Create Auth API

Goal:
Isolate auth endpoints.

Tasks:

- Create `auth_api.dart`.
- Add `login(email, password)`.
- Add `refresh(refreshToken)`.
- Use Dio from the provider.

Concepts to learn:

- API service as a remote data layer.
- Endpoints are not written in the UI.

Done when:

- Auth API can be tested with a Dio mock or fake.

### Phase 7.c - Create Auth Repository

Goal:
Combine Auth API and secure storage.

Tasks:

- Create `auth_repository.dart`.
- Save the refresh token when login succeeds.
- Update the refresh token when refresh succeeds.
- Clear storage when refresh fails.
- Clear storage on logout.

Concepts to learn:

- Repository as an orchestration layer.
- The boundary between network and local persistence.

Done when:

- A successful login test saves the refresh token.
- Tests confirm the access token is never stored.
- A logout test clears storage.

## Phase 8 - Auth Controller With Real API

### Phase 8.a - Replace Fake Login With Repository

Goal:
Connect the login UI to the real API.

Tasks:

- Make the auth controller call the auth repository.
- Map the response into authenticated state.
- Map errors into safe user-facing messages.

Concepts to learn:

- Async state transition.
- Error mapping for users.

Done when:

- Valid login reaches the dashboard.
- Invalid login stays on login with a safe message.

### Phase 8.b - Implement Restore Session

Goal:
Open the app again without logging in when the refresh token is valid.

Tasks:

- Read the refresh token when the app starts.
- If there is no token, set state to unauthenticated.
- If a token exists, call refresh.
- If refresh succeeds, set state to authenticated.
- If refresh fails, clear the token and set state to unauthenticated.

Concepts to learn:

- Session hydration.
- Initializing state.
- Race between router and auth restore.

Done when:

- Restarting the app with a valid token opens the dashboard.
- An invalid token returns to login.

### Phase 8.c - Make Logout Safe

Goal:
Clear state and storage consistently.

Tasks:

- Clear the access token from memory on logout.
- Clear the refresh token from secure storage on logout.
- Return the router to `/login`.

Concepts to learn:

- Auth cleanup.
- Client-side security boundary.

Done when:

- After logout, refreshing the app does not open the dashboard.

## Phase 9 - Incremental Tests

### Phase 9.a - Unit Test DTOs

Goal:
Make sure parsing is not fragile.

Tasks:

- Test `ApiEnvelope`.
- Test `AuthResponse`.
- Test malformed responses.

Done when:

- All parsing tests pass.

### Phase 9.b - Unit Test Repository

Goal:
Make sure token rules are correct.

Tasks:

- Successful login saves the refresh token.
- Failed login does not save a token.
- Failed refresh clears the token.
- Logout clears the token.

Done when:

- All repository tests pass.

### Phase 9.c - Widget Test Login

Goal:
Make sure the login UI follows state.

Tasks:

- Empty fields show validation.
- Loading state disables the button.
- Error state shows a message.

Done when:

- Login widget tests pass.

### Phase 9.d - Router Test

Goal:
Make sure the main redirects are correct.

Tasks:

- Anonymous `/dashboard` redirects to `/login`.
- Authenticated `/login` redirects to `/dashboard`.
- Logout returns to `/login`.

Done when:

- Router tests pass.

## Phase 10 - Manual Verification

### Phase 10.a - Successful Login Flow

Checklist:

- Open the app.
- See the login page.
- Enter a valid email and password.
- Tap login.
- Reach the dashboard.
- See 9 placeholder menu items.

### Phase 10.b - Failed Login Flow

Checklist:

- Open the login page.
- Enter invalid credentials.
- Tap login.
- Stay on login.
- The error message does not show technical details or tokens.

### Phase 10.c - Protected Route Flow

Checklist:

- Clear secure storage or sign out.
- Open `/dashboard`.
- The app redirects to `/login`.

### Phase 10.d - Restore Session Flow

Checklist:

- Log in successfully.
- Close the app.
- Open the app again.
- If the refresh token is valid, reach the dashboard.
- If the refresh token is invalid, reach login.

## Definition Of Done Phase 1

Phase 1 is done when:

- Login page appears as the main entry for anonymous users.
- Valid login redirects to dashboard.
- Dashboard is protected from anonymous users.
- Logout redirects to login.
- Secure storage stores only the refresh token.
- Dashboard shows 9 Employee Attendance App menu items as placeholders.
- `dart format --set-exit-if-changed .` passes.
- `flutter analyze` passes.
- `flutter test` passes.

## Recommended Implementation Order

1. Phase 0.a through 0.c.
2. Phase 1.a through 1.c.
3. Phase 2.a through 2.c.
4. Phase 3.a through 3.c.
5. Phase 4.a through 4.c.
6. Phase 5.a through 5.c.
7. Phase 6.a through 6.d.
8. Phase 7.a through 7.c.
9. Phase 8.a through 8.c.
10. Phase 9.a through 9.d.
11. Phase 10.a through 10.d.

Do not implement Fill Attendance, Leave, Permission, or Payroll features
before the full login flow, auth state, secure storage, protected route, and
dashboard placeholder are complete and tested.
