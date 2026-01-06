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
  final databaseService = ref.watch(databaseProvider);
  return ExerciseRepository(databaseService);
});

// Exercise list provider
final exerciseListProvider = FutureProvider<List<Exercise>>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return await repository.getAllExercisesOrderedByBuiltInThenName();
});

// Workout repository provider
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final databaseService = ref.watch(databaseProvider);
  return WorkoutRepository(databaseService);
});

// Workout list provider
final workoutListProvider = FutureProvider<List<Workout>>((ref) async {
  final repository = ref.watch(workoutRepositoryProvider);
  return await repository.getAll();
});

// PR Provider - calculates personal records for all exercises
final prMapProvider = FutureProvider<Map<int, PersonalRecord>>((ref) async {
  final workouts = await ref.watch(workoutListProvider.future);
  final exercises = await ref.watch(exerciseListProvider.future);
  final workoutRepository = ref.watch(workoutRepositoryProvider);

  final personalRecordsMap = <int, PersonalRecord>{};

  final workoutExercisesMap = <int, List<WorkoutExercise>>{};
  final setsMap = <int, List<ExerciseSet>>{};

  for (final workout in workouts) {
    final workoutExercises = await workoutRepository.getWorkoutExercises(workout.id!);
    workoutExercisesMap[workout.id!] = workoutExercises;

    for (final we in workoutExercises) {
      final sets = await workoutRepository.getSets(we.id!);
      setsMap[we.id!] = sets;
    }
  }

  for (final exercise in exercises) {
    final personalRecord = PRCalculator.calculatePRs(
      exerciseId: exercise.id!,
      workouts: workouts,
      workoutExercisesMap: workoutExercisesMap,
      setsMap: setsMap,
    );

    if (personalRecord.hasRecords) {
      personalRecordsMap[exercise.id!] = personalRecord;
    }
  }

  return personalRecordsMap;
});
