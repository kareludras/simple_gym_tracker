import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/core/widgets/confirmation_dialog.dart';

void main() {
  group('ConfirmationDialog', () {
    testWidgets('shows confirmation dialog with correct content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await ConfirmationDialog.show(
                  context: context,
                  title: 'Test Title',
                  message: 'Test Message',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Message'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('returns true when confirm is tapped', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ConfirmationDialog.show(
                  context: context,
                  title: 'Test',
                  message: 'Test',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(result, true);
    });

    testWidgets('returns false when cancel is tapped', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ConfirmationDialog.show(
                  context: context,
                  title: 'Test',
                  message: 'Test',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, false);
    });

    testWidgets('showDeleteConfirmation uses correct defaults', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await ConfirmationDialog.showDeleteConfirmation(
                  context: context,
                  itemName: 'Squat',
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Confirmation'), findsOneWidget);
      expect(find.text('Delete "Squat"?'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });
  });
}
