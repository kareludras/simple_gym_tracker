import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/db.dart';
import '../features/exercises/data/exercise_repository.dart';
import '../features/exercises/data/models/exercise.dart';
import '../features/workouts/data/workout_repository.dart';
import '../features/workouts/data/models/workout.dart';

// Exercise repository provider
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ExerciseRepository(db);
});

// Exercise list provider
final exerciseListProvider = FutureProvider<List<Exercise>>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return await repo.getAll();
});

// Workout repository provider
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return WorkoutRepository(db);
});

// Workout list provider
final workoutListProvider = FutureProvider<List<Workout>>((ref) async {
  final repo = ref.watch(workoutRepositoryProvider);
  return await repo.getAll();
});