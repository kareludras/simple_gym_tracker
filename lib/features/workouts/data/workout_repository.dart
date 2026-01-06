import 'package:sqflite/sqflite.dart';
import '../../../core/database/db.dart';
import '../../../core/database/tables.dart';
import '../../../core/constants/database_constants.dart';
import '../../../core/exceptions/app_exceptions.dart';
import 'models/workout.dart';
import 'models/workout_exercise.dart';
import 'models/set.dart';
import 'workout_draft_provider.dart';

class WorkoutRepository {
  final DatabaseService _databaseService;

  WorkoutRepository(this._databaseService);

  Future<List<Workout>> getAllWorkoutsOrderedByDate() async {
    final database = await _databaseService.database;
    final workoutMaps = await database.query(
      Tables.workouts,
      orderBy: DatabaseConstants.workoutDefaultOrder,
    );
    return _convertMapsToWorkouts(workoutMaps);
  }

  Future<List<Workout>> getAll() async {
    return await getAllWorkoutsOrderedByDate();
  }

  Future<Workout?> getWorkoutById(int workoutId) async {
    final database = await _databaseService.database;
    final workoutMaps = await database.query(
      Tables.workouts,
      where: 'id = ?',
      whereArgs: [workoutId],
      limit: 1,
    );

    if (workoutMaps.isEmpty) return null;

    return Workout.fromMap(workoutMaps.first);
  }

  Future<Workout?> getById(int id) async {
    return await getWorkoutById(id);
  }

  Future<Workout> createWorkout(Workout workout) async {
    final database = await _databaseService.database;
    final workoutId = await database.insert(
      Tables.workouts,
      workout.toMap(),
    );
    return workout.copyWith(id: workoutId);
  }

  Future<Workout> create(Workout workout) async {
    return await createWorkout(workout);
  }

  Future<void> updateWorkout(Workout workout) async {
    _validateWorkoutHasId(workout);

    final database = await _databaseService.database;
    await database.update(
      Tables.workouts,
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<void> update(Workout workout) async {
    return await updateWorkout(workout);
  }

  Future<void> deleteWorkoutCompletely(int workoutId) async {
    final database = await _databaseService.database;

    await database.transaction((transaction) async {
      await _deleteSetsForWorkout(transaction, workoutId);
      await _deleteWorkoutExercises(transaction, workoutId);
      await _deleteWorkout(transaction, workoutId);
    });
  }

  Future<void> delete(int id) async {
    return await deleteWorkoutCompletely(id);
  }

  Future<List<WorkoutExercise>> getWorkoutExercises(int workoutId) async {
    final database = await _databaseService.database;
    final workoutExerciseMaps = await database.query(
      Tables.workoutExercises,
      where: 'workout_id = ?',
      whereArgs: [workoutId],
      orderBy: DatabaseConstants.workoutExerciseDefaultOrder,
    );
    return _convertMapsToWorkoutExercises(workoutExerciseMaps);
  }

  Future<WorkoutExercise> addExerciseToWorkout({
    required int workoutId,
    required int exerciseId,
  }) async {
    final database = await _databaseService.database;
    final orderIndex = await _getNextExerciseOrderIndex(workoutId);

    final workoutExercise = WorkoutExercise(
      workoutId: workoutId,
      exerciseId: exerciseId,
      orderIndex: orderIndex,
    );

    final workoutExerciseId = await database.insert(
      Tables.workoutExercises,
      workoutExercise.toMap(),
    );

    return WorkoutExercise(
      id: workoutExerciseId,
      workoutId: workoutId,
      exerciseId: exerciseId,
      orderIndex: orderIndex,
    );
  }

  Future<List<ExerciseSet>> getSets(int workoutExerciseId) async {
    final database = await _databaseService.database;
    final setMaps = await database.query(
      Tables.sets,
      where: 'workout_exercise_id = ?',
      whereArgs: [workoutExerciseId],
      orderBy: DatabaseConstants.setDefaultOrder,
    );
    return _convertMapsToSets(setMaps);
  }

  Future<ExerciseSet> addSet({
    required int workoutExerciseId,
    int? reps,
    double? weight,
    int? duration,
  }) async {
    final database = await _databaseService.database;
    final orderIndex = await _getNextSetOrderIndex(workoutExerciseId);

    final set = ExerciseSet(
      workoutExerciseId: workoutExerciseId,
      reps: reps,
      weight: weight,
      duration: duration,
      orderIndex: orderIndex,
    );

    final setId = await database.insert(Tables.sets, set.toMap());

    return ExerciseSet(
      id: setId,
      workoutExerciseId: workoutExerciseId,
      reps: reps,
      weight: weight,
      duration: duration,
      orderIndex: orderIndex,
    );
  }

  Future<void> updateSet(ExerciseSet set) async {
    _validateSetHasId(set);

    final database = await _databaseService.database;
    await database.update(
      Tables.sets,
      set.toMap(),
      where: 'id = ?',
      whereArgs: [set.id],
    );
  }

  Future<void> deleteSet(int setId) async {
    final database = await _databaseService.database;
    await database.delete(
      Tables.sets,
      where: 'id = ?',
      whereArgs: [setId],
    );
  }

  Future<Workout> saveWorkoutDraft(WorkoutDraft draft) async {
    _validateWorkoutDraft(draft);

    final database = await _databaseService.database;

    return await database.transaction((transaction) async {
      final workoutId = await _insertWorkout(transaction, draft);
      await _insertExercisesAndSets(transaction, draft, workoutId);

      return Workout(
        id: workoutId,
        date: draft.date,
        note: draft.note,
        createdAt: DateTime.now(),
      );
    });
  }


  List<Workout> _convertMapsToWorkouts(List<Map<String, dynamic>> maps) {
    return maps.map((map) => Workout.fromMap(map)).toList();
  }

  List<WorkoutExercise> _convertMapsToWorkoutExercises(
    List<Map<String, dynamic>> maps,
  ) {
    return maps.map((map) => WorkoutExercise.fromMap(map)).toList();
  }

  List<ExerciseSet> _convertMapsToSets(List<Map<String, dynamic>> maps) {
    return maps.map((map) => ExerciseSet.fromMap(map)).toList();
  }

  void _validateWorkoutHasId(Workout workout) {
    if (workout.id == null) {
      throw ValidationException('Workout must have an ID to be updated');
    }
  }

  void _validateSetHasId(ExerciseSet set) {
    if (set.id == null) {
      throw ValidationException('Set must have an ID to be updated');
    }
  }

  void _validateWorkoutDraft(WorkoutDraft draft) {
    if (draft.isEmpty) {
      throw InvalidWorkoutException('Workout cannot be empty');
    }

    final hasCompletedSets = draft.exercises.any(
      (exercise) => exercise.sets.any((set) => set.isComplete),
    );

    if (!hasCompletedSets) {
      throw InvalidWorkoutException('At least one set must be completed');
    }
  }

  Future<int> _getNextExerciseOrderIndex(int workoutId) async {
    final existingExercises = await getWorkoutExercises(workoutId);
    return existingExercises.length;
  }

  Future<int> _getNextSetOrderIndex(int workoutExerciseId) async {
    final existingSets = await getSets(workoutExerciseId);
    return existingSets.length;
  }

  Future<void> _deleteSetsForWorkout(
    Transaction transaction,
    int workoutId,
  ) async {
    final workoutExercises = await transaction.query(
      Tables.workoutExercises,
      where: 'workout_id = ?',
      whereArgs: [workoutId],
    );

    for (final workoutExercise in workoutExercises) {
      await transaction.delete(
        Tables.sets,
        where: 'workout_exercise_id = ?',
        whereArgs: [workoutExercise['id']],
      );
    }
  }

  Future<void> _deleteWorkoutExercises(
    Transaction transaction,
    int workoutId,
  ) async {
    await transaction.delete(
      Tables.workoutExercises,
      where: 'workout_id = ?',
      whereArgs: [workoutId],
    );
  }

  Future<void> _deleteWorkout(Transaction transaction, int workoutId) async {
    await transaction.delete(
      Tables.workouts,
      where: 'id = ?',
      whereArgs: [workoutId],
    );
  }

  Future<int> _insertWorkout(Transaction transaction, WorkoutDraft draft) async {
    return await transaction.insert(
      Tables.workouts,
      {
        'date': draft.date.millisecondsSinceEpoch,
        'note': draft.note,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  Future<void> _insertExercisesAndSets(
    Transaction transaction,
    WorkoutDraft draft,
    int workoutId,
  ) async {
    for (final draftExercise in draft.exercises) {
      final workoutExerciseId = await _insertWorkoutExercise(
        transaction,
        workoutId,
        draftExercise,
      );

      await _insertCompletedSets(
        transaction,
        workoutExerciseId,
        draftExercise.sets,
      );
    }
  }

  Future<int> _insertWorkoutExercise(
    Transaction transaction,
    int workoutId,
    DraftWorkoutExercise draftExercise,
  ) async {
    return await transaction.insert(
      Tables.workoutExercises,
      {
        'workout_id': workoutId,
        'exercise_id': draftExercise.exercise.id,
        'order_index': draftExercise.orderIndex,
      },
    );
  }

  Future<void> _insertCompletedSets(
    Transaction transaction,
    int workoutExerciseId,
    List<DraftSet> sets,
  ) async {
    for (final draftSet in sets) {
      if (draftSet.isComplete) {
        await transaction.insert(
          Tables.sets,
          draftSet.toExerciseSet(workoutExerciseId).toMap(),
        );
      }
    }
  }
}
