// Basic widget test for Dhikrify app

import 'package:flutter_test/flutter_test.dart';
import 'package:dhikrify/main.dart';

void main() {
  testWidgets('App starts and shows Dhikrify title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DhikrifyApp());

    // Verify that the app title is shown
    expect(find.text('Dhikrify'), findsOneWidget);
  });
}
