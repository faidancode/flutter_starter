# Project Rules

- Follow `docs/flutter_employee_attendance_detailed_phase_plan.md` sequentially.
- Do not implement attendance, leave, permission, overtime, payroll, or report features before the full login flow, auth state, secure storage, protected routing, and dashboard placeholders are complete.
- Keep UI, state, repository, network, and storage responsibilities separated according to the planned folder structure.
- Do not store access tokens in persistent storage; only refresh tokens belong in secure storage.
- Keep widgets testable by passing behavior through callbacks or providers instead of creating network/storage clients in UI code.

# Quality Gate

- Run `dart format .` after Dart edits.
- Run `flutter analyze` before considering a phase complete.
- Run `flutter test` before considering a phase complete.
- Prefer `make check` when the full gate is needed.
- **Stalled Processes:** If a process gets stuck, I will manually execute the command. Provide only the exact command that I need to run.
