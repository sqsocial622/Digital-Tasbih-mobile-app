import 'package:flutter_test/flutter_test.dart';
import 'package:dua_azkar_app/main.dart';

void main() {
  testWidgets('App starts and shows Dua & Azkar', (WidgetTester tester) async {
    await tester.pumpWidget(const DuaAzkarApp());
    expect(find.text('Dua & Azkar'), findsOneWidget);
  });
}
