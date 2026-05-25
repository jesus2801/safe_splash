// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can use WidgetTester to find child widgets in the widget
// tree, read the values of widget properties, and verify correct behavior.

import 'package:flutter_test/flutter_test.dart';

import 'package:splash_frontend/app/splash_app.dart';

void main() {
  testWidgets('SplashApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(const SplashApp());
    await tester.pump();

    expect(find.text('Splash'), findsOneWidget);

    // Advance splash delay + route transition so no pending timers remain.
    await tester.pump(const Duration(milliseconds: 2000));
    await tester.pumpAndSettle();

    expect(find.text('Pool monitoring'), findsOneWidget);
  });
}
