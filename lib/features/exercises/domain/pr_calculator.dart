import '../../workouts/data/models/workout.dart';
import '../../workouts/data/models/workout_exercise.dart';
import '../../workouts/data/models/set.dart';

class PersonalRecord {
  final double? maxWeight;
  final int? maxReps;
  final double? maxVolume; // total weight × reps in one workout
  final DateTime? lastPerformed;

  PersonalRecord({
    this.maxWeight,
    this.maxReps,
    this.maxVolume,
    this.lastPerformed,
  });

  bool get hasRecords => maxWeight != null || maxReps != null || maxVolume != null;
}

class PRCalculator {
  static PersonalRecord calculatePRs({
    required int exerciseId,
    required List<Workout> workouts,
    required Map<int, List<WorkoutExercise>> workoutExercisesMap,
    required Map<int, List<ExerciseSet>> setsMap,
  }) {
    double? maxWeight;
    int? maxReps;
    double? maxVolume;
    DateTime? lastPerformed;

    for (final workout in workouts) {
      final workoutExercises = workoutExercisesMap[workout.id] ?? [];

      for (final we in workoutExercises) {
        if (we.exerciseId != exerciseId) continue;

        final sets = setsMap[we.id] ?? [];
        if (sets.isEmpty) continue;

        if (lastPerformed == null || workout.date.isAfter(lastPerformed)) {
          lastPerformed = workout.date;
        }

        for (final set in sets) {
          if (set.weight != null) {
            if (maxWeight == null || set.weight! > maxWeight) {
              maxWeight = set.weight;
            }
          }

          if (set.reps != null) {
            if (maxReps == null || set.reps! > maxReps) {
              maxReps = set.reps;
            }
          }
        }

        double workoutVolume = 0;
        for (final set in sets) {
          if (set.weight != null && set.reps != null) {
            workoutVolume += set.weight! * set.reps!;
          }
        }

        if (workoutVolume > 0) {
          if (maxVolume == null || workoutVolume > maxVolume) {
            maxVolume = workoutVolume;
          }
        }
      }
    }

    return PersonalRecord(
      maxWeight: maxWeight,
      maxReps: maxReps,
      maxVolume: maxVolume,
      lastPerformed: lastPerformed,
    );
  }
}