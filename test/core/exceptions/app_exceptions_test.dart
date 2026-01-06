import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/core/exceptions/app_exceptions.dart';

void main() {
  group('App Exceptions', () {
    test('BuiltInExerciseException has correct message', () {
      final exception = BuiltInExerciseException();
      
      expect(exception.toString(), 'Cannot modify built-in exercises');
    });

    test('BuiltInExerciseException accepts custom message', () {
      final exception = BuiltInExerciseException('Custom error');
      
      expect(exception.toString(), 'Custom error');
    });

    test('ExerciseInUseException formats message correctly', () {
      final exception = ExerciseInUseException('Squat');
      
      expect(
        exception.toString(),
        'Cannot delete "Squat" - it is used in workouts',
      );
    });

    test('InvalidWorkoutException includes reason', () {
      final exception = InvalidWorkoutException('No exercises added');
      
      expect(exception.toString(), 'Invalid workout: No exercises added');
    });

    test('EntityNotFoundException formats message correctly', () {
      final exception = EntityNotFoundException('Exercise', 42);
      
      expect(exception.toString(), 'Exercise with id 42 not found');
    });

    test('ValidationException shows message', () {
      final exception = ValidationException('Field is required');
      
      expect(exception.toString(), 'Field is required');
    });
  });
}
