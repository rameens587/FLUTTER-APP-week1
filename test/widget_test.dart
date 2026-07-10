import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:excelerate_connect/main.dart';

void main() {
  testWidgets('App launches on the Login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ExcelerateConnectApp());

    expect(find.text('Excelerate Connect'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
