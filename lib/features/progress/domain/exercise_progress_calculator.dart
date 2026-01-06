import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';

class ProgressDataPoint {
  final DateTime date;
  final double maxWeight;
  final int maxReps;
  final double totalVolume;
  final int totalSets;

  ProgressDataPoint({
    required this.date,
    required this.maxWeight,
    required this.maxReps,
    required this.totalVolume,
    required this.totalSets,
  });
}

class ExerciseProgressData {
  final List<ProgressDataPoint> dataPoints;
  final int totalWorkouts;
  final int totalSets;

  ExerciseProgressData({
    required this.dataPoints,
    required this.totalWorkouts,
    required this.totalSets,
  });
}

final exerciseProgressProvider = FutureProvider.family<ExerciseProgressData, int>(
  (ref, exerciseId) async {
    final workouts = await ref.watch(workoutListProvider.future);
    final workoutRepository = ref.watch(workoutRepositoryProvider);

    final dataPoints = <ProgressDataPoint>[];
    int totalSetsCount = 0;

    for (final workout in workouts) {
      final workoutExercises = await workoutRepository.getWorkoutExercises(workout.id!);

      for (final workoutExercise in workoutExercises) {
        if (workoutExercise.exerciseId == exerciseId) {
          final sets = await workoutRepository.getSets(workoutExercise.id!);

          if (sets.isNotEmpty) {
            double maxWeight = 0;
            int maxReps = 0;
            double totalVolume = 0;

            for (final set in sets) {
              if (set.weight != null && set.weight! > maxWeight) {
                maxWeight = set.weight!;
              }
              if (set.reps != null && set.reps! > maxReps) {
                maxReps = set.reps!;
              }
              if (set.weight != null && set.reps != null) {
                totalVolume += set.weight! * set.reps!;
              }
            }

            totalSetsCount += sets.length;

            dataPoints.add(ProgressDataPoint(
              date: workout.date,
              maxWeight: maxWeight,
              maxReps: maxReps,
              totalVolume: totalVolume,
              totalSets: sets.length,
            ));
          }
        }
      }
    }

    dataPoints.sort((a, b) => a.date.compareTo(b.date));

    return ExerciseProgressData(
      dataPoints: dataPoints,
      totalWorkouts: dataPoints.length,
      totalSets: totalSetsCount,
    );
  },
);
