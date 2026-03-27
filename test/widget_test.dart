// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:glublink/main.dart'; // Импортируем main.dart

void main() {
  testWidgets('GlubLink app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GlubLinkApp()); // Используем GlubLinkApp вместо MyApp

    // Verify that home screen exists
    expect(find.text('Home'), findsOneWidget);
  });
}