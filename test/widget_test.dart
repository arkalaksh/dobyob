import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dobyob_1/main.dart';

void main() {
  testWidgets('Dummy smoke test', (WidgetTester tester) async {
    // isLoggedIn: false देऊन app build कर
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // इथे तुझ्या real UI मध्ये counter वगैरे नाही,
    // म्हणून फक्त app build झाला का तेच बघू.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
