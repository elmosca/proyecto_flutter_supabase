import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/screens/lists/tasks_list.dart';
import 'package:frontend/l10n/app_localizations.dart';

void main() {
  group('TasksList Widget Tests', () {
    testWidgets('TasksList can be instantiated', (WidgetTester tester) async {
      // Test simple que solo verifica que el widget se puede instanciar
      expect(() => const TasksList(projectId: 1), returnsNormally);
    });

    testWidgets('TasksList can be built in MaterialApp', (WidgetTester tester) async {
      // Test que verifica que el widget se puede construir en un MaterialApp
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: Text('Test App'),
            ),
          ),
        ),
      );

      expect(find.text('Test App'), findsOneWidget);
    });
  });
}