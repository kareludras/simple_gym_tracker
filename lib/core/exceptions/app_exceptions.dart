class BuiltInExerciseException implements Exception {
  final String message;

  BuiltInExerciseException([this.message = 'Cannot modify built-in exercises']);

  @override
  String toString() => message;
}

class ExerciseInUseException implements Exception {
  final String exerciseName;

  ExerciseInUseException(this.exerciseName);

  @override
  String toString() => 'Cannot delete "$exerciseName" - it is used in workouts';
}

class InvalidWorkoutException implements Exception {
  final String reason;

  InvalidWorkoutException(this.reason);

  @override
  String toString() => 'Invalid workout: $reason';
}

class EntityNotFoundException implements Exception {
  final String entityType;
  final int id;

  EntityNotFoundException(this.entityType, this.id);

  @override
  String toString() => '$entityType with id $id not found';
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => message;
}
