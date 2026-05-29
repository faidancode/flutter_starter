import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_starter/main.dart';

void main() {
  testWidgets('App boots with starter text', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Flutter Starter'), findsOneWidget);
  });
}
