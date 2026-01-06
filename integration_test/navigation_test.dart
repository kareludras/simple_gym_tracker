import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/main.dart' as app;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigation', () {
    setUp(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    testWidgets('User can navigate between all tabs', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: app.GymTrackerApp()));
      await tester.pumpAndSettle();

      expect(find.text('Ready to start your workout?'), findsOneWidget);

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Progress'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Exercises'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Preferences'), findsOneWidget);

      await tester.tap(find.text('Workout'));
      await tester.pumpAndSettle();
      expect(find.text('Ready to start your workout?'), findsOneWidget);
    });
  });
}
