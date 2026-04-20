// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camino_app/main.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() { 
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CaminoApp()));
    await tester.pump();

    // Splash screen should render immediately.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // After the splash delay, app navigates to role selection.
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to CAMINO'), findsOneWidget);
  });
}

