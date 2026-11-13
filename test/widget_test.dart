import 'package:flutter_test/flutter_test.dart';

import 'package:sankar_group/app.dart';

void main() {
  testWidgets('Mierae Solar App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MieraeSolarApp());
    await tester.pumpAndSettle();

    // Verify that the setup preview screen loads.
    expect(find.text('Design system preview'), findsOneWidget);
  });
}
