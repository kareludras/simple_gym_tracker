import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/features/exercises/data/models/exercise.dart';

void main() {
  group('Exercise Model', () {
    test('creates exercise with all fields', () {
      final now = DateTime.now();
      final exercise = Exercise(
        id: 1,
        name: 'Squat',
        category: 'Legs',
        isBuiltin: true,
        createdAt: now,
      );

      expect(exercise.id, 1);
      expect(exercise.name, 'Squat');
      expect(exercise.category, 'Legs');
      expect(exercise.isBuiltin, true);
      expect(exercise.createdAt, now);
    });

    test('creates exercise without optional fields', () {
      final exercise = Exercise(name: 'Bench Press');

      expect(exercise.id, null);
      expect(exercise.name, 'Bench Press');
      expect(exercise.category, null);
      expect(exercise.isBuiltin, false);
      expect(exercise.createdAt, isNotNull);
    });

    test('copyWith updates specified fields', () {
      final original = Exercise(
        id: 1,
        name: 'Squat',
        category: 'Legs',
      );

      final updated = original.copyWith(
        name: 'Front Squat',
        category: 'Core',
      );

      expect(updated.id, 1);
      expect(updated.name, 'Front Squat');
      expect(updated.category, 'Core');
      expect(updated.isBuiltin, false);
    });

    test('toMap converts exercise to map correctly', () {
      final now = DateTime.now();
      final exercise = Exercise(
        id: 1,
        name: 'Deadlift',
        category: 'Back',
        isBuiltin: true,
        createdAt: now,
      );

      final map = exercise.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'Deadlift');
      expect(map['category'], 'Back');
      expect(map['is_builtin'], 1);
      expect(map['created_at'], now.millisecondsSinceEpoch);
    });

    test('fromMap creates exercise from map correctly', () {
      final now = DateTime.now();
      final map = {
        'id': 2,
        'name': 'Pull-up',
        'category': 'Back',
        'is_builtin': 0,
        'created_at': now.millisecondsSinceEpoch,
      };

      final exercise = Exercise.fromMap(map);

      expect(exercise.id, 2);
      expect(exercise.name, 'Pull-up');
      expect(exercise.category, 'Back');
      expect(exercise.isBuiltin, false);
      expect(exercise.createdAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('fromMap handles null category', () {
      final map = {
        'id': 3,
        'name': 'Plank',
        'category': null,
        'is_builtin': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };

      final exercise = Exercise.fromMap(map);

      expect(exercise.category, null);
    });
  });
}
