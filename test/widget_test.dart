import 'package:flutter_test/flutter_test.dart';
import 'package:diary_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We pass a dummy initialRoute for testing
    await tester.pumpWidget(const MyApp(initialRoute: '/onboarding'));

    // Basic check to see if the app loads
    expect(find.byType(MyApp), findsOneWidget);
  });
}
