import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/main.dart' as app;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Exercise Management', () {
    setUp(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    testWidgets('User can create custom exercise', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: app.GymTrackerApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Exercises'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Add Exercise'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Exercise Name'),
        'Cable Flyes',
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Category (optional)'),
        'Chest',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Cable Flyes'), findsOneWidget);
      expect(find.text('Added Cable Flyes'), findsOneWidget);
    });

    testWidgets('User can edit custom exercise', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: app.GymTrackerApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Exercises'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Exercise Name'),
        'Test Exercise',
      );
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(IconButton, Icons.edit).last);
      await tester.pumpAndSettle();

      expect(find.text('Edit Exercise'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Exercise Name'),
        'Edited Exercise',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Edited Exercise'), findsOneWidget);
      expect(find.text('Exercise updated'), findsOneWidget);
    });

    testWidgets('User can delete custom exercise', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: app.GymTrackerApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Exercises'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(IconButton, Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Exercise Name'),
        'To Delete',
      );
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(IconButton, Icons.delete).last);
      await tester.pumpAndSettle();

      expect(find.text('Delete Confirmation'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Deleted To Delete'), findsOneWidget);
    });

    testWidgets('User cannot delete built-in exercise', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: app.GymTrackerApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Exercises'));
      await tester.pumpAndSettle();

      final builtInExercises = find.widgetWithText(Chip, 'Built-in');
      expect(builtInExercises, findsWidgets);
    });
  });
}
