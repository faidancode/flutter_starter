# Flutter Employee Attendance NFR Implementation Plan

## Purpose

This document defines a two-phase implementation plan for a Flutter employee
attendance starter application. The existing Ionic Angular Employee RBAC
application is used as a behavioral and non-functional requirement (NFR)
reference, not as a screen-for-screen implementation target.

The immediate learning target is intentionally narrow: a user can see the login
screen, sign in, be redirected to a protected attendance dashboard, see a
mobile-first menu grid, and sign out back to login. Attendance workflows such
as fill attendance with photo, leave request, permission request, payroll, and
reports are visible only as future menu placeholders until the authenticated
shell is stable.

### Selected Flutter Foundation

| Concern | Selected Technology | Purpose |
| --- | --- | --- |
| UI framework | Flutter | Mobile-first client application |
| State and dependency injection | Riverpod | Testable authentication and application state |
| Routing | GoRouter | Redirect-based protected routes and future deep links |
| Networking | Dio | Typed API calls, interceptors, cancellation, and timeouts |
| Token persistence | `flutter_secure_storage` | Platform-backed storage for the refresh token |

The planned architecture separates views, state/controllers, repositories, and
external services. This matches Flutter's current architecture guidance while
keeping Phase 1 small enough to understand end to end.

## Verified Ionic Source Audit

The findings below were verified from the source code in this repository,
rather than copied from the original improvement plan.

### Implemented Capabilities

| Capability | Verified Behavior | Ionic Reference |
| --- | --- | --- |
| Authentication state | Login builds the current user session; logout clears state and routes to login. | [`auth.service.ts`](../src/app/core/services/auth.service.ts) |
| Session hydration | Startup refresh occurs before initial routing when a stored refresh token is available. | [`app.config.ts`](../src/app/app.config.ts), [`auth.service.ts`](../src/app/core/services/auth.service.ts) |
| Token handling | Access tokens remain in application state; only a refresh token is persisted. | [`auth.service.ts`](../src/app/core/services/auth.service.ts) |
| Authenticated HTTP requests | Bearer tokens are attached; a non-auth request returning `401` is refreshed and retried. Concurrent retry requests wait for the refresh result. | [`auth.interceptor.ts`](../src/app/core/interceptors/auth.interceptor.ts) |
| Protected navigation | Dashboard and feature routes require an authenticated session. | [`app.routes.ts`](../src/app/app.routes.ts), [`auth.guard.ts`](../src/app/core/guards/auth.guard.ts) |
| RBAC user experience | Permissions are loaded from the API, checked on routes, and used to hide unavailable navigation entries. | [`ability.service.ts`](../src/app/core/services/ability.service.ts), [`app.component.html`](../src/app/app.component.html) |
| Error routing | `403` navigates to unauthorized, `404` navigates to not found, and network/server failures show feedback. | [`error-handler.interceptor.ts`](../src/app/core/interceptors/error-handler.interceptor.ts), [`app.routes.ts`](../src/app/app.routes.ts) |
| Dashboard resilience | Summary loading, failure messaging, and retry behavior are implemented. | [`dashboard.service.ts`](../src/app/core/services/dashboard.service.ts), [`dashboard.page.html`](../src/app/pages/dashboard/dashboard.page.html) |
| Performance behavior | Lazy-route preloading, scroll restoration, reference-data caching/invalidation, and debounced list search are present. | [`app.config.ts`](../src/app/app.config.ts), [`reference-data.service.ts`](../src/app/core/services/reference-data.service.ts), [`department.page.ts`](../src/app/pages/department/department.page.ts) |
| Accessibility baseline | Accessible labels, status/loading semantics, and semantic dashboard links have been introduced. | [`app.component.html`](../src/app/app.component.html), [`dashboard.page.html`](../src/app/pages/dashboard/dashboard.page.html), [`pagination.component.html`](../src/app/components/pagination/pagination.component.html) |
| Service architecture | Shared query and mutation bases support thin feature facades for CRUD-oriented modules. | [`paginated-query.service.ts`](../src/app/core/services/paginated-query.service.ts), [`crud-mutation.service.ts`](../src/app/core/services/crud-mutation.service.ts) |
| Automated testing | Unit tests use Vitest and browser flows use Playwright. | [`package.json`](../package.json), [`vitest.config.ts`](../vitest.config.ts), [`playwright.config.ts`](../playwright.config.ts) |

### Important Limitations And Porting Decisions

- The Ionic application persists its refresh token in browser
  `localStorage`. A mobile Flutter application must instead keep that token in
  platform secure storage; browser storage is not an acceptable model to port.
- The current Ionic dashboard is a summary-card interface linked to existing
  modules. The Flutter `3x3` module dashboard requested for the starter is a
  new shell design, not an exact UI port.
- The Ionic repository still contains legacy NgModule bootstrap artifacts,
  while the active entrypoint uses standalone bootstrap through `main.ts` and
  `app.config.ts`. The Flutter app should start with one clear application
  composition path.
- Menu/route permission checks in a client are a usability control only. The
  backend must enforce authorization for every protected API operation.

### Validation Baseline Observed During Audit

The following baseline was observed in the current working tree on
May 27, 2026. It records the state of the Ionic reference and is not a
deliverable of the Flutter project.

| Check | Observed Result | Note |
| --- | --- | --- |
| `npx tsc -p tsconfig.spec.json --noEmit` | Passed | Spec type checking completes successfully. |
| `npm run test:unit` | Passed, `26/26` tests | Vitest emits TypeScript-program inclusion warnings for several Angular component specs. |
| `npm run lint` | Failed | ESLint project inclusion errors exist for specs/test setup, plus existing Angular lint findings. |
| `npm run test:e2e` | Failed, `3/11` tests passed | Auth and unauthorized routing tests pass; department tests do not mock the active development API prefix `/api/v1`. |

## Phase 1 - Secure Attendance Starter Application

### Goal

Build the smallest useful Flutter attendance application shell: API-connected
login, secure session restoration, protected dashboard access, logout, and a
visible employee attendance menu layout. Business module implementation is
deliberately deferred; Phase 1 proves the login-to-dashboard flow only.

### Phase 1.1 - Application Foundation

#### Implementation

- Create a Flutter project organized around `core` infrastructure and the
  `auth` and `dashboard` features.
- Configure `ProviderScope` at the application root and expose configuration,
  storage, Dio, repositories, auth state, and router through Riverpod
  providers.
- Configure `MaterialApp.router` with GoRouter and a mobile-first theme.
- Define API configuration by environment rather than embedding endpoint
  choices throughout repositories.
- Use an API base URL compatible with the active Ionic API contract; local
  development must include the `/api/v1` prefix.

#### Suggested Initial Structure

```text
lib/
  app/
    app.dart
    router.dart
    theme.dart
  core/
    config/
    network/
    storage/
    errors/
  features/
    auth/
      data/
      presentation/
    dashboard/
      presentation/
```

#### Completion Criteria

- The application launches through `ProviderScope` and GoRouter.
- Development and release API endpoint selection is centralized.
- No feature screen creates its own Dio or secure storage instance.

### Phase 1.2 - Login And Secure Session

#### Required API Contracts

```text
POST /auth/login
Request:  { "email": string, "password": string }
Response: { "data": { "user": {...}, "accessToken": string, "refreshToken": string } }

POST /auth/refresh
Request:  { "refreshToken": string }
Response: { "data": { "user": {...}, "accessToken": string, "refreshToken": string } }
```

#### Implementation

- Implement typed DTO parsing for the response envelope used by the Ionic
  application.
- Implement an authentication repository that coordinates the remote auth
  service and secure session storage.
- Model auth state explicitly as initializing, unauthenticated,
  authenticating, authenticated, or failure.
- Persist only the refresh token using `flutter_secure_storage`; retain the
  access token only in authenticated Riverpod state.
- During app initialization, read the persisted refresh token and attempt
  session refresh before resolving the initial authenticated route.
- When refresh fails, remove the stored token and expose unauthenticated state.
- When login succeeds, store the refresh token, expose authenticated state, and
  replace navigation with `/dashboard`.
- When logout is requested, clear in-memory authentication data and secure
  storage, then replace navigation with `/login`.
- Provide email/password required validation, a password visibility control,
  a disabled loading submit state, and a generic safe authentication failure
  message.

#### Completion Criteria

- A valid API login reaches the dashboard without persisting the access token.
- Closing and reopening the application restores a valid session through
  refresh.
- An invalid or expired refresh token results in login, with no remaining
  stored session.
- Passwords, access tokens, and refresh tokens never appear in application
  logs or user-visible errors.

### Phase 1.3 - Protected Attendance Dashboard

#### Routes

| Route | Access | Behavior |
| --- | --- | --- |
| `/login` | Public | Authenticated users are redirected to `/dashboard`. |
| `/dashboard` | Authenticated | Unauthenticated users are redirected to `/login`. |
| `/not-found` | Public | Unknown routes display a recovery screen. |

#### Implementation

- Drive GoRouter redirects from resolved authentication state so the app does
  not briefly expose the dashboard before hydration finishes.
- Display the authenticated user's identifier and a logout action on the
  dashboard.
- Build a mobile-first dashboard grid with consistent touch targets.
- Render attendance module tiles as unavailable or `Coming soon` during this
  phase; they establish the product direction but do not imply implemented
  functionality.

#### Starter Menu Tiles

| Row | Tiles |
| --- | --- |
| 1 | Isi Kehadiran, Riwayat Kehadiran, Jadwal Kerja |
| 2 | Ajukan Cuti, Ajukan Izin, Lembur |
| 3 | Slip Gaji, Profil, Pengumuman |

#### Completion Criteria

- Navigating directly to `/dashboard` before authentication never exposes
  dashboard content.
- Login navigation cannot leave a usable authenticated screen in the back
  stack after logout.
- The dashboard displays exactly nine accessible attendance-oriented menu
  tiles on common phone widths.

### Phase 1.4 - Mandatory Starter NFR

These requirements should not be postponed because retrofitting them after
feature development creates security and maintenance risk.

#### Security

- Store the refresh token only in platform secure storage and the access token
  only in memory.
- Configure Android secure-storage backup protections as required by the
  selected plugin configuration.
- Allow cleartext local development endpoints only in debug builds; reject
  cleartext API configuration in release builds.
- Do not add request/response logging that could record authorization headers
  or credentials.

#### Reliability And Usability

- Apply connection and receive timeouts with non-technical user messaging for
  login failures.
- Prevent multiple concurrent login submissions.
- Make login fields, visibility toggles, logout controls, loading indicators,
  and menu tiles accessible through semantics.
- Support text scaling and narrow screens without clipping the `3x3` dashboard
  layout.

#### Maintainability

- Keep DTOs, repositories, providers, and widgets separately testable.
- Keep configuration and endpoint resolution centralized.
- Establish analyzer and test gates before adding HRIS modules.

## Phase 2 - Advanced Non-Functional Requirements

### Goal

Make the authenticated attendance starter robust enough to serve as the
foundation for future employee self-service modules. This phase focuses on
NFRs; it does not implement attendance, leave, payroll, or reporting workflows.

### Security And Session Hardening

- Add a Dio authentication interceptor that attaches the current bearer token
  to protected API calls.
- Use queued or equivalent single-flight refresh coordination so concurrent
  `401` responses trigger one refresh request, not one per failed request.
- Exclude login and refresh endpoints from refresh-retry handling.
- Retry an original protected request at most once after refresh to avoid
  infinite failure loops.
- Make refresh failure atomic: clear credentials once, cancel or reject waiting
  protected requests, and route to login once.
- Sanitize diagnostics and crash-reporting context so tokens, credentials, and
  sensitive HR information are never captured.

### Authorization Readiness

- Add permission retrieval using `GET /auth/me/permissions` after successful
  login or startup hydration.
- Support the two permission response shapes already accepted by Ionic:
  flat rules such as `{action, subject}` and resource groups containing
  permission actions.
- Represent permissions as cached session state and clear them on logout.
- Allow future dashboard tiles and routes to declare an optional required
  permission.
- Retain server-side authorization as the required security enforcement point;
  Flutter permission checks only hide or block unsupported user interactions.

### Routing And Error Handling

- Add `/unauthorized` and complete `/not-found` recovery behavior.
- Preserve an intended authenticated destination when an anonymous user is sent
  to login, then restore it after successful login where permitted.
- Classify offline, connection timeout, server failure, session expiration, and
  authorization failure into distinct, recoverable user experiences.
- Add retry actions only for operations that are safe to repeat.
- Protect routing against hydration races and authentication redirect loops.

### Performance And Resource Usage

- Limit rebuilds by selecting only required Riverpod state in each view.
- Use request cancellation for obsolete operations and avoid duplicate
  permission/session network calls.
- Instrument startup and session hydration duration and profile dashboard frame
  rendering on representative devices.
- Define module-ready policies: debounced search, paginated loading, cached
  reference data, explicit invalidation after mutation, and consistent
  loading/empty/error presentation.

### Release And Operational Quality

- Establish development, staging, and production flavors with distinct API
  endpoint configuration.
- Require HTTPS in staging and production and keep debug-only network
  exceptions out of release artifacts.
- Decide crash reporting and telemetry configuration before real employee data
  is displayed; recorded context must exclude protected data.
- Maintain consistent English or Indonesian UI copy when product localization
  is chosen, rather than mixing language per screen.
- Add accessibility checks for interactive controls, contrast, text scaling,
  and screen-reader navigation.
- Document the auth, storage, error, and permission contracts for future
  feature teams.

## Interfaces And Security Decisions

### Core Types

| Type | Required Fields Or Values | Purpose |
| --- | --- | --- |
| `AuthState` | `initializing`, `unauthenticated`, `authenticating`, `authenticated`, `failure` | Controls splash, login, dashboard, and router decisions. |
| `LoginRequest` | `email`, `password` | Sends authentication credentials only to the login API. |
| `LoginResponse` | `user`, `accessToken`, `refreshToken` | Parses authentication data inside the API response envelope. |
| `StoredSession` | `refreshToken` | Defines the only credential persisted on device. |
| `PermissionRule` | `action`, `subject` | Represents client-side permission visibility and navigation checks. |
| `MenuItem` | `label`, `icon`, `availability`, optional `requiredPermission` | Defines attendance dashboard tile content and future permission gating. |

### Non-Negotiable Decisions

- Access tokens must never be persisted on disk.
- Refresh tokens must never be stored in shared preferences or plaintext local
  application storage.
- Release builds must reject cleartext API URLs.
- Errors displayed to users must not expose raw server payloads or token
  values.
- Client-side RBAC must never be treated as a replacement for server-side
  authorization.

## Test Plan And Acceptance Criteria

### Phase 1 Tests

| Level | Scenarios |
| --- | --- |
| Unit | Response envelope parsing, secure-storage write of refresh token only, login success/failure state transitions, hydration refresh success/failure, logout clearing state, and safe error mapping. |
| Widget/router | Anonymous direct navigation to dashboard redirects to login; authenticated login opens dashboard; authenticated access to login redirects to dashboard; dashboard renders nine tiles; logout returns to login. |
| Integration | API-backed login to dashboard, session restoration after application restart, logout clearing persisted session, and expired refresh token returning the user to login. |

### Phase 2 Tests

| Area | Scenarios |
| --- | --- |
| Refresh concurrency | Multiple protected `401` responses invoke one refresh operation and replay eligible requests once. |
| Session failure | Refresh failure clears secure storage/state, rejects queued requests, and results in one login redirect. |
| Authorization | Permission parsing supports both Ionic response forms and future route/tile decisions respect missing permission. |
| Error navigation | `403`, `404`, offline, timeout, and `5xx` conditions produce the intended route or user feedback. |
| Configuration | Staging/production configuration rejects HTTP API endpoints and logging does not contain secrets. |
| Quality/performance | Hydration and dashboard performance measurements are captured against agreed target devices before feature growth. |

### Required Flutter Quality Gates

Run these gates for every implementation increment:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
flutter test integration_test
```

Phase 1 is complete only when an authenticated user can reach the protected
attendance dashboard, an anonymous user cannot, logout returns to login,
session restoration works securely, and all Phase 1 checks pass. Phase 2 is
complete only when the security, error, authorization-readiness, configuration,
and performance checks above are in place and passing.

## Assumptions And Exclusions

- The Flutter starter integrates with the same authentication contract already
  used by the Ionic source.
- This roadmap does not implement CRUD feature parity, dashboard summary
  metrics, role-management workflows, or position history.
- Isi Kehadiran, Riwayat Kehadiran, Jadwal Kerja, Ajukan Cuti, Ajukan Izin,
  Lembur, Slip Gaji, Profil, and Pengumuman are dashboard placeholders only;
  they require separate product requirements and API contracts.
- Certificate pinning and biometric unlock are not assumed requirements. They
  require a later threat-model and operational decision because they change
  certificate rotation, device access, and support behavior.

## References

### Audited Repository Documentation

- [Ionic improvement implementation plan](./improvement_implementation_plan.md)
- [Security and session hardening report](./improvement_phase_1.md)
- [Error handling and routing report](./improvement_phase_2.md)
- [Performance and mobile UX report](./improvement_phase_4.md)
- [Testing report](./improvement_phase_5.md)
- [Accessibility and polish report](./improvement_phase_6.md)
- [CRUD service refactor report](./improvement_phase_7.md)

### Flutter And Package Documentation

- [Flutter architecture guide](https://docs.flutter.dev/app-architecture/guide)
- [Flutter testing overview](https://docs.flutter.dev/testing/overview)
- [Flutter accessibility guidance](https://docs.flutter.dev/ui/accessibility)
- [GoRouter package](https://pub.dev/packages/go_router)
- [Dio package and interceptor behavior](https://pub.dev/packages/dio)
- [`flutter_secure_storage` package](https://pub.dev/packages/flutter_secure_storage)

### Security References

- [OWASP Mobile Application Security Verification Standard (MASVS)](https://mas.owasp.org/MASVS/)
- [Android Network Security Configuration](https://developer.android.com/privacy-and-security/security-config)
