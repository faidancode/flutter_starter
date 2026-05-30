# Flutter Essential Concepts

This document explains core concepts that appear often in this project. It is not a replacement for the Flutter documentation, but a quick reference for reading the codebase.

## Widget

In Flutter, almost every part of the UI is a `Widget`. Buttons, text, pages, padding, column layouts, and even the root application are widgets.

A widget is a description of UI. It does not draw directly to the screen. Flutter reads the widget tree, then the framework creates and updates the elements/render objects that are actually used to display the UI.

Example:

```dart
Text('Login')
```

Meaning: create a UI description for the text `Login`.

## Widget Tree

Widgets are usually nested. A parent widget wraps a child widget.

Simple example:

```dart
Padding(
  padding: EdgeInsets.all(16),
  child: Text('Login'),
)
```

`Padding` is the parent, and `Text` is the child. Flutter reads this structure as a tree.

## StatelessWidget

`StatelessWidget` is used when a widget does not store internal state that changes during its lifetime.

Example:

```dart
class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Login');
  }
}
```

Use `StatelessWidget` for presentational components that receive data or callbacks from a parent.

## StatefulWidget

`StatefulWidget` is used when a widget needs to store state or own a resource with a lifecycle.

Example from this project:

```dart
final _emailController = TextEditingController();
```

`TextEditingController` must be created, used, and then disposed. Because it has that lifecycle, the page uses `StatefulWidget`.

## State

`State` is the object that stores mutable data for a `StatefulWidget`.

In Flutter, the `StatefulWidget` itself should usually stay lightweight and immutable. Data that changes is stored in the `State` class.

Common pattern:

```dart
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}
```

## build

The `build` method returns the widget tree for the current state.

Flutter can call `build` many times. Because of that, avoid heavy work inside `build`, such as API requests, reading large files, or creating objects that must be disposed when those objects can be stored in `State` instead.

## BuildContext

`BuildContext` is Flutter's handle for knowing where a widget sits in the tree.

Example usage:

```dart
final theme = Theme.of(context);
```

This code gets the nearest theme from that widget's position in the tree.

## super.key

`super.key` forwards the `key` parameter to Flutter's parent class.

Example:

```dart
const LoginPage({super.key});
```

A `key` helps Flutter distinguish widgets when the tree changes. For many simple widgets, we do not use a key directly, but keeping `super.key` in the constructor is standard practice because it makes the widget ready for lists, routes, tests, or more complex composition.

## const

`const` means an object can be created as a compile-time constant.

Example:

```dart
const SizedBox(height: 16)
```

Use `const` when a widget or value does not depend on runtime state. This helps Flutter reduce rebuild work.

## Controller

A controller is an object used to read or control the state of a specific widget.

Example:

```dart
final controller = TextEditingController();
```

`TextEditingController` is used to read the contents of a `TextField`. Controllers must be disposed when they are no longer used.

## dispose

`dispose` is a lifecycle method for cleaning up resources.

Example:

```dart
@override
void dispose() {
  _emailController.dispose();
  super.dispose();
}
```

If resources such as controllers, animation controllers, stream subscriptions, or routers are not disposed, the app can keep memory/resources that are no longer needed.

## Callback

A callback is a function passed from a parent to a child so the child can notify the parent that something happened.

Example:

```dart
final void Function(String email, String password) onSubmit;
```

`LoginForm` does not need to know the login process. The form only collects input and calls `onSubmit`. The parent decides what happens after submit.

## Routing

Routing decides which screen appears for a specific path.

In this project, `go_router` connects paths such as `/login` and `/dashboard` to page widgets.

Example:

```dart
GoRoute(
  path: '/login',
  builder: (context, state) => const LoginPage(),
)
```

## Theme

Theme stores global visual rules such as colors, typography, input shape, and button style.

With a theme, widgets do not need to repeat the same styling. A page can use:

```dart
final theme = Theme.of(context);
```

Then it can read styles from `theme.textTheme`, `theme.colorScheme`, or other theme components.

## SafeArea

`SafeArea` keeps UI from being covered by the notch, status bar, navigation bar, or other system areas.

Use `SafeArea` for main screens, especially on mobile layouts.

## SingleChildScrollView

`SingleChildScrollView` makes content scrollable when the screen height is not enough.

This is important for the login form because the keyboard can reduce the available screen area.

## TextField and TextEditingController

`TextField` is a text input. If we need to read the input value explicitly, use `TextEditingController`.

Example:

```dart
TextField(controller: emailController)
```

Later, the value can be read with:

```dart
emailController.text
```

## Current Project Structure

Initial structure currently being built:

```text
lib/
  app/
    app.dart
    router.dart
    theme.dart
  features/
    auth/
      presentation/
        login_page.dart
        widgets/
          login_form.dart
```

The basic idea:

- `app/` contains global application configuration.
- `router.dart` contains application routes.
- `theme.dart` contains the visual baseline.
- `features/auth/` contains the auth/login feature.
- `widgets/` contains smaller components used by a page.

## When To Split Widgets

Split a widget when:

- a page file starts getting too long,
- part of the UI has a clear responsibility,
- part of the UI is reused,
- part of the UI needs to be tested separately.

Example in this project: `LoginForm` is split from `LoginPage` so the page focuses on screen layout, while the form focuses on input and submit behavior.
