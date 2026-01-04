import '../../../core/database/db.dart';
import '../../../core/database/tables.dart';
import 'models/workout.dart';
import 'models/workout_exercise.dart';
import 'workout_draft_provider.dart';
import 'models/set.dart';

class WorkoutRepository {
  final DatabaseService _db;

  WorkoutRepository(this._db);

  Future<List<Workout>> getAll() async {
    final db = await _db.database;
    final maps = await db.query(
      Tables.workouts,
      orderBy: 'date DESC',
    );
    return maps.map((m) => Workout.fromMap(m)).toList();
  }

  Future<Workout?> getById(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      Tables.workouts,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Workout.fromMap(maps.first);
  }

  Future<Workout> create(Workout workout) async {
    final db = await _db.database;
    final id = await db.insert(Tables.workouts, workout.toMap());
    return workout.copyWith(id: id);
  }

  Future<void> update(Workout workout) async {
    final db = await _db.database;
    await db.update(
      Tables.workouts,
      workout.toMap(),
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;

    final workoutExercises = await db.query(
      Tables.workoutExercises,
      where: 'workout_id = ?',
      whereArgs: [id],
    );

    for (final we in workoutExercises) {
      await db.delete(
        Tables.sets,
        where: 'workout_exercise_id = ?',
        whereArgs: [we['id']],
      );
    }

    await db.delete(
      Tables.workoutExercises,
      where: 'workout_id = ?',
      whereArgs: [id],
    );

    await db.delete(
      Tables.workouts,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<WorkoutExercise>> getWorkoutExercises(int workoutId) async {
    final db = await _db.database;
    final maps = await db.query(
      Tables.workoutExercises,
      where: 'workout_id = ?',
      whereArgs: [workoutId],
      orderBy: 'order_index ASC',
    );
    return maps.map((m) => WorkoutExercise.fromMap(m)).toList();
  }

  Future<WorkoutExercise> addExerciseToWorkout({
    required int workoutId,
    required int exerciseId,
  }) async {
    final db = await _db.database;

    final existing = await getWorkoutExercises(workoutId);
    final orderIndex = existing.length;

    final workoutExercise = WorkoutExercise(
      workoutId: workoutId,
      exerciseId: exerciseId,
      orderIndex: orderIndex,
    );

    final id = await db.insert(Tables.workoutExercises, workoutExercise.toMap());
    return WorkoutExercise(
      id: id,
      workoutId: workoutId,
      exerciseId: exerciseId,
      orderIndex: orderIndex,
    );
  }

  Future<List<ExerciseSet>> getSets(int workoutExerciseId) async {
    final db = await _db.database;
    final maps = await db.query(
      Tables.sets,
      where: 'workout_exercise_id = ?',
      whereArgs: [workoutExerciseId],
      orderBy: 'order_index ASC',
    );
    return maps.map((m) => ExerciseSet.fromMap(m)).toList();
  }

  Future<ExerciseSet> addSet({
    required int workoutExerciseId,
    int? reps,
    double? weight,
    int? duration,
  }) async {
    final db = await _db.database;

    final existing = await getSets(workoutExerciseId);
    final orderIndex = existing.length;

    final set = ExerciseSet(
      workoutExerciseId: workoutExerciseId,
      reps: reps,
      weight: weight,
      duration: duration,
      orderIndex: orderIndex,
    );

    final id = await db.insert(Tables.sets, set.toMap());
    return ExerciseSet(
      id: id,
      workoutExerciseId: workoutExerciseId,
      reps: reps,
      weight: weight,
      duration: duration,
      orderIndex: orderIndex,
    );
  }

  Future<void> updateSet(ExerciseSet set) async {
    final db = await _db.database;
    await db.update(
      Tables.sets,
      set.toMap(),
      where: 'id = ?',
      whereArgs: [set.id],
    );
  }

  Future<void> deleteSet(int id) async {
    final db = await _db.database;
    await db.delete(
      Tables.sets,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Save a complete workout draft
  Future<Workout> saveWorkoutDraft(WorkoutDraft draft) async {
    final db = await _db.database;

    // Start transaction
    return await db.transaction((txn) async {
      // 1. Insert workout
      final workoutId = await txn.insert(
        Tables.workouts,
        {
          'date': draft.date.millisecondsSinceEpoch,
          'note': draft.note,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
      );

      // 2. Insert each exercise and its sets
      for (final draftExercise in draft.exercises) {
        // Insert workout_exercise
        final workoutExerciseId = await txn.insert(
          Tables.workoutExercises,
          {
            'workout_id': workoutId,
            'exercise_id': draftExercise.exercise.id,
            'order_index': draftExercise.orderIndex,
          },
        );

        // Insert sets (only completed ones)
        for (final draftSet in draftExercise.sets) {
          if (draftSet.isComplete) {
            await txn.insert(
              Tables.sets,
              draftSet.toExerciseSet(workoutExerciseId).toMap(),
            );
          }
        }
      }

      return Workout(
        id: workoutId,
        date: draft.date,
        note: draft.note,
        createdAt: DateTime.now(),
      );
    });
  }
}