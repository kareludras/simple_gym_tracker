import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/main.dart';

void main() {
  testWidgets('App starts and shows bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GymTrackerApp()));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Workout'), findsWidgets);
    expect(find.text('History'), findsWidgets);
    expect(find.text('Progress'), findsWidgets);
    expect(find.text('Exercises'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('Shows workout empty state by default', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GymTrackerApp()));
    await tester.pumpAndSettle();

    expect(find.text('Ready to start your workout?'), findsOneWidget);
    expect(find.text('Start Workout'), findsOneWidget);
  });
}
