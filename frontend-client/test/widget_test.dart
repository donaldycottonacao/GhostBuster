import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_client/main.dart';

void main() {
  testWidgets('GhostBusterApp initializes and renders StealthTriggerScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GhostBusterApp());
    await tester.pumpAndSettle();

    // Verify AppBar title is present
    expect(find.text('GhostBuster - Stealth Escape'), findsOneWidget);

    // Verify persona section and action buttons exist
    expect(find.text('CALLER PERSONA'), findsOneWidget);
    expect(find.text('TRIGGER DELAY'), findsOneWidget);
    expect(find.textContaining('ARM ESCAPE CALL'), findsOneWidget);
  });
}
