import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/db.dart';
import '../features/exercises/data/exercise_repository.dart';
import '../features/exercises/data/models/exercise.dart';
import '../features/workouts/data/workout_repository.dart';
import '../features/workouts/data/models/workout.dart';
import '../features/workouts/data/models/workout_exercise.dart';
import '../features/workouts/data/models/set.dart';
import '../features/exercises/domain/pr_calculator.dart';

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

// PR Provider - calculates personal records for all exercises
final prMapProvider = FutureProvider<Map<int, PersonalRecord>>((ref) async {
  final workouts = await ref.watch(workoutListProvider.future);
  final exercises = await ref.watch(exerciseListProvider.future);
  final workoutRepo = ref.watch(workoutRepositoryProvider);

  final prMap = <int, PersonalRecord>{};

  // Build maps of workout exercises and sets
  final workoutExercisesMap = <int, List<WorkoutExercise>>{};
  final setsMap = <int, List<ExerciseSet>>{};

  for (final workout in workouts) {
    final workoutExercises = await workoutRepo.getWorkoutExercises(workout.id!);
    workoutExercisesMap[workout.id!] = workoutExercises;

    for (final we in workoutExercises) {
      final sets = await workoutRepo.getSets(we.id!);
      setsMap[we.id!] = sets;
    }
  }

  // Calculate PRs for each exercise
  for (final exercise in exercises) {
    final pr = PRCalculator.calculatePRs(
      exerciseId: exercise.id!,
      workouts: workouts,
      workoutExercisesMap: workoutExercisesMap,
      setsMap: setsMap,
    );

    if (pr.hasRecords) {
      prMap[exercise.id!] = pr;
    }
  }

  return prMap;
});