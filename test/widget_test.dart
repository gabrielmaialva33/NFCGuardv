// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_guard/main.dart';

void main() {
  testWidgets('NFCGuard app loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: NFCGuardApp()));

    // Just pump once to build the initial UI
    await tester.pump();

    // Verify that our app loads with NFCGuard splash screen
    expect(find.text('NFCGuard'), findsOneWidget);
  });
}
