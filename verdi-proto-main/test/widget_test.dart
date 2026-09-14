import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verdi/app/verdi_app.dart';
import 'package:verdi/features/analytics/presentation/analytics_page.dart';
import 'package:verdi/features/orders/presentation/orders_page.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: VerdiApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Farm Operations'), findsWidgets);
  });

  testWidgets('Orders page shows premium operations controls', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OrdersPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('New Order'), findsOneWidget);
    expect(find.text('Traceable Batch'), findsOneWidget);
  });

  testWidgets('App shell shows a floating AI assistant entry point', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: VerdiApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ask Verdi'), findsOneWidget);
  });

  testWidgets('Analytics page shows executive cockpit controls', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AnalyticsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Field & Yield Analytics'), findsOneWidget);
    expect(find.text('Spatial Telemetry & Predictive AI'), findsOneWidget);
  });
}
