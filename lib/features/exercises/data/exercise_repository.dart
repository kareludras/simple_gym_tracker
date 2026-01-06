import '../../../core/database/db.dart';
import '../../../core/database/tables.dart';
import '../../../core/constants/database_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import 'models/exercise.dart';

/// Repository for exercise CRUD operations following clean code principles
class ExerciseRepository {
  final DatabaseService _databaseService;

  ExerciseRepository(this._databaseService);

  /// Retrieves all exercises ordered by built-in status, then alphabetically
  Future<List<Exercise>> getAllExercisesOrderedByBuiltInThenName() async {
    final database = await _databaseService.database;
    final exerciseMaps = await database.query(
      Tables.exercises,
      orderBy: DatabaseConstants.exerciseDefaultOrder,
    );
    return _convertMapsToExercises(exerciseMaps);
  }

  /// Retrieves a single exercise by its ID
  Future<Exercise?> getExerciseById(int id) async {
    final database = await _databaseService.database;
    final exerciseMaps = await database.query(
      Tables.exercises,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (exerciseMaps.isEmpty) return null;

    return Exercise.fromMap(exerciseMaps.first);
  }

  /// Creates a new custom exercise
  Future<Exercise> createCustomExercise(Exercise exercise) async {
    final database = await _databaseService.database;
    final exerciseId = await database.insert(
      Tables.exercises,
      exercise.toMap(),
    );
    return exercise.copyWith(id: exerciseId);
  }

  /// Updates an existing custom exercise
  /// 
  /// Throws [BuiltInExerciseException] if attempting to update a built-in exercise
  Future<void> updateCustomExercise(Exercise exercise) async {
    _validateExerciseIsNotBuiltIn(exercise);

    final database = await _databaseService.database;
    await database.update(
      Tables.exercises,
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  /// Deletes a custom exercise if not in use
  /// 
  /// Throws [BuiltInExerciseException] if attempting to delete a built-in exercise
  /// Throws [ExerciseInUseException] if exercise is used in any workout
  Future<void> deleteCustomExercise(int exerciseId) async {
    final exercise = await getExerciseById(exerciseId);

    if (exercise == null) {
      throw EntityNotFoundException('Exercise', exerciseId);
    }

    _validateExerciseIsNotBuiltIn(exercise);
    await _validateExerciseIsNotInUse(exerciseId, exercise.name);

    final database = await _databaseService.database;
    await database.delete(
      Tables.exercises,
      where: 'id = ?',
      whereArgs: [exerciseId],
    );
  }

  /// Creates a copy of an exercise (useful for copy-on-edit of built-in exercises)
  Future<Exercise> duplicateExercise(int exerciseId) async {
    final originalExercise = await getExerciseById(exerciseId);

    if (originalExercise == null) {
      throw EntityNotFoundException('Exercise', exerciseId);
    }

    final duplicatedExercise = originalExercise.copyWith(
      id: null,
      name: '${originalExercise.name} (Copy)',
      isBuiltin: false,
      createdAt: DateTime.now(),
    );

    return await createCustomExercise(duplicatedExercise);
  }

  // Private helper methods

  List<Exercise> _convertMapsToExercises(List<Map<String, dynamic>> maps) {
    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  void _validateExerciseIsNotBuiltIn(Exercise exercise) {
    if (exercise.isBuiltin) {
      throw BuiltInExerciseException();
    }
  }

  Future<void> _validateExerciseIsNotInUse(int exerciseId, String exerciseName) async {
    final database = await _databaseService.database;
    final usageCount = await database.query(
      Tables.workoutExercises,
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      limit: 1,
    );

    if (usageCount.isNotEmpty) {
      throw ExerciseInUseException(exerciseName);
    }
  }
}
