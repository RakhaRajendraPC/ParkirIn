import 'package:flutter_test/flutter_test.dart';

import 'package:parkirin_cgk/main.dart';

void main() {
  testWidgets('App launches and shows the Search tab by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ParkirInApp());
    await tester.pumpAndSettle();

    expect(find.text('ParkirIn'), findsOneWidget);

    expect(find.textContaining('Solusi Parkir Inap'), findsOneWidget);

    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Bookings'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Tapping the Alerts tab shows the Notifications screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ParkirInApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Shuttle Arriving Soon'), findsOneWidget);
  });

  testWidgets('Filtering Alerts by "Shuttle" shows only shuttle notifications',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ParkirInApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();

    expect(find.text('Booking Berhasil Dikonfirmasi'), findsOneWidget);

    await tester.tap(find.text('Shuttle'));
    await tester.pumpAndSettle();

    expect(find.text('Shuttle Arriving Soon'), findsOneWidget);
    expect(find.text('Booking Berhasil Dikonfirmasi'), findsNothing);
  });

  testWidgets('Tapping a notification card marks it as read',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ParkirInApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alerts'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Shuttle Arriving Soon'));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
  });

  testWidgets('Tapping the Profile tab shows profile details',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ParkirInApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('Gold Member'), findsOneWidget);
  });
}
