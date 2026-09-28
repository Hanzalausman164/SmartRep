// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:smart_rep/main.dart';
import 'package:smart_rep/screens/auth_screen.dart';
import 'package:smart_rep/screens/splash_screen.dart';

void main() {
  testWidgets('splash advances to auth after two seconds', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartRepApp());

    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1999));
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 201));
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(AuthScreen), findsOneWidget);
  });
}
