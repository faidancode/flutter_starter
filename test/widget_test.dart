import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_starter/app/app.dart';

void main() {
  testWidgets('App shows the themed temporary shell screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());

    expect(find.text('Employee Attendance'), findsOneWidget);
    expect(find.text('Application shell ready'), findsOneWidget);
    expect(find.text('Quick preview'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
