import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/features/workouts/data/models/workout.dart';

void main() {
  group('Workout Model', () {
    test('creates workout with all fields', () {
      final date = DateTime(2024, 1, 15);
      final createdAt = DateTime.now();
      
      final workout = Workout(
        id: 1,
        date: date,
        note: 'Great workout!',
        createdAt: createdAt,
      );

      expect(workout.id, 1);
      expect(workout.date, date);
      expect(workout.note, 'Great workout!');
      expect(workout.createdAt, createdAt);
    });

    test('creates workout without optional fields', () {
      final date = DateTime(2024, 1, 15);
      
      final workout = Workout(date: date);

      expect(workout.id, null);
      expect(workout.date, date);
      expect(workout.note, null);
      expect(workout.createdAt, isNotNull);
    });

    test('copyWith updates specified fields', () {
      final original = Workout(
        id: 1,
        date: DateTime(2024, 1, 15),
        note: 'Original note',
      );

      final updated = original.copyWith(
        note: 'Updated note',
      );

      expect(updated.id, 1);
      expect(updated.date, original.date);
      expect(updated.note, 'Updated note');
    });

    test('toMap converts workout to map correctly', () {
      final date = DateTime(2024, 1, 15);
      final createdAt = DateTime.now();
      
      final workout = Workout(
        id: 1,
        date: date,
        note: 'Test note',
        createdAt: createdAt,
      );

      final map = workout.toMap();

      expect(map['id'], 1);
      expect(map['date'], date.millisecondsSinceEpoch);
      expect(map['note'], 'Test note');
      expect(map['created_at'], createdAt.millisecondsSinceEpoch);
    });

    test('fromMap creates workout from map correctly', () {
      final date = DateTime(2024, 1, 15);
      final createdAt = DateTime.now();
      
      final map = {
        'id': 2,
        'date': date.millisecondsSinceEpoch,
        'note': 'Mapped workout',
        'created_at': createdAt.millisecondsSinceEpoch,
      };

      final workout = Workout.fromMap(map);

      expect(workout.id, 2);
      expect(workout.date.millisecondsSinceEpoch, date.millisecondsSinceEpoch);
      expect(workout.note, 'Mapped workout');
      expect(workout.createdAt.millisecondsSinceEpoch, createdAt.millisecondsSinceEpoch);
    });

    test('fromMap handles null note', () {
      final map = {
        'id': 3,
        'date': DateTime.now().millisecondsSinceEpoch,
        'note': null,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };

      final workout = Workout.fromMap(map);

      expect(workout.note, null);
    });
  });
}
