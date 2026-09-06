import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('La aplicación Mangazo se inicializa correctamente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MangazoApp());

    expect(find.text('App Mangazo Inicializada 🚀'), findsOneWidget);
  });
}
