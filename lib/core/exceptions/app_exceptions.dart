// ignore_for_file: dangling_library_doc_comments
/// Custom exceptions for better error handling and user feedback

/// Exception thrown when trying to modify a built-in exercise
class BuiltInExerciseException implements Exception {
  final String message;

  BuiltInExerciseException([this.message = 'Cannot modify built-in exercises']);

  @override
  String toString() => message;
}

/// Exception thrown when trying to delete an exercise that's in use
class ExerciseInUseException implements Exception {
  final String exerciseName;

  ExerciseInUseException(this.exerciseName);

  @override
  String toString() => 'Cannot delete "$exerciseName" - it is used in workouts';
}

/// Exception thrown when a workout is invalid
class InvalidWorkoutException implements Exception {
  final String reason;

  InvalidWorkoutException(this.reason);

  @override
  String toString() => 'Invalid workout: $reason';
}

/// Exception thrown when required data is not found
class EntityNotFoundException implements Exception {
  final String entityType;
  final int id;

  EntityNotFoundException(this.entityType, this.id);

  @override
  String toString() => '$entityType with id $id not found';
}

/// Exception thrown for general validation errors
class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => message;
}
