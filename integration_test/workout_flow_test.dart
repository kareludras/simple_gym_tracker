import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/main.dart' as app;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete Workout Flow', () {
    setUp(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    testWidgets('User can complete full workout flow', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: app.GymTrackerApp()));
      await tester.pumpAndSettle();

      expect(find.text('Ready to start your workout?'), findsOneWidget);

      await tester.tap(find.text('Start Workout'));
      await tester.pumpAndSettle();

      expect(find.text('No exercises yet'), findsOneWidget);

      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.text('Select Exercise'), findsOneWidget);
      
      final squatTiles = find.ancestor(
        of: find.text('Squat'),
        matching: find.byType(ListTile),
      );
      await tester.tap(squatTiles.first);
      await tester.pumpAndSettle();

      expect(find.text('Squat'), findsWidgets);

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), '100');
      await tester.pumpAndSettle();

      await tester.enterText(textFields.at(1), '5');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(IconButton, Icons.save));
      await tester.pumpAndSettle();

      expect(find.textContaining('Workout saved'), findsOneWidget);
    });

    testWidgets('User can add multiple exercises to workout', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: app.GymTrackerApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Workout'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final squatTile = find.ancestor(
        of: find.text('Squat'),
        matching: find.byType(ListTile),
      );
      await tester.tap(squatTile.first);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final benchTile = find.ancestor(
        of: find.text('Bench Press'),
        matching: find.byType(ListTile),
      );
      await tester.tap(benchTile.first);
      await tester.pumpAndSettle();

      expect(find.text('Squat'), findsWidgets);
      expect(find.text('Bench Press'), findsWidgets);
    });

    testWidgets('User can add multiple sets to exercise', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: app.GymTrackerApp()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start Workout'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final squatTile = find.ancestor(
        of: find.text('Squat'),
        matching: find.byType(ListTile),
      );
      await tester.tap(squatTile.first);
      await tester.pumpAndSettle();

      expect(find.text('1'), findsWidgets);

      await tester.tap(find.text('Add Set'));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsWidgets);

      await tester.tap(find.text('Add Set'));
      await tester.pumpAndSettle();

      expect(find.text('3'), findsWidgets);
    });
  });
}
