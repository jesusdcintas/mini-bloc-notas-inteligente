// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mini_bloc_notas_inteligente/app/app.dart';

void main() {
  testWidgets('App should render notes list page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the main app title is shown
    expect(find.text('Mis Notas'), findsOneWidget);

    // Verify that the FAB to create new note exists
    expect(find.text('Nueva Nota'), findsOneWidget);
  });
}
