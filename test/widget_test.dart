import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_tracker/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: GymTrackerApp()));
    expect(find.text('Gym Tracker'), findsOneWidget);
  });
}