import 'package:flutter_test/flutter_test.dart';
import 'package:digital_campus/main.dart';

void main() {
  testWidgets('Digital Campus smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DigitalCampusApp());
    expect(find.byType(DigitalCampusApp), findsOneWidget);
  });
}
