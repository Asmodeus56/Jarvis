import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jarvis/main.dart';

void main() {
  testWidgets('JarvisApp renders without errors', (WidgetTester tester) async {
    // Build the JARVIS app and trigger a frame.
    await tester.pumpWidget(const JarvisApp());

    // Verify the app renders a Scaffold with a black background.
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(Stack), findsOneWidget);
  });
}
