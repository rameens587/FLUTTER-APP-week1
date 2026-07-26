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

  testWidgets('Profile screen opens with editable profile details', (
      WidgetTester tester) async {
    await tester.pumpWidget(const ExcelerateConnectApp());

    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/profile');
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Edit name'), findsOneWidget);
  });

  testWidgets('Program listing renders sample data from the mock dataset', (
      WidgetTester tester) async {
    await tester.pumpWidget(const ExcelerateConnectApp());

    tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/programs');
    await tester.pumpAndSettle();

    expect(find.text('AI Product Launch Workshop'), findsOneWidget);
  });
}
