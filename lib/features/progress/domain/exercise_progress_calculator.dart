import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';

class ProgressDataPoint {
  final DateTime date;
  final double maxWeight;
  final int maxReps;
  final double totalVolume;
  final int totalSets;
  final double estimatedOneRepMax;

  ProgressDataPoint({
    required this.date,
    required this.maxWeight,
    required this.maxReps,
    required this.totalVolume,
    required this.totalSets,
    required this.estimatedOneRepMax,
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

double calculateOneRepMax(double weight, int reps) {
  if (reps == 1) return weight;
  return weight * (1 + reps / 30);
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
            double bestEstimatedOneRepMax = 0;

            for (final set in sets) {
              if (set.weight != null && set.weight! > maxWeight) {
                maxWeight = set.weight!;
              }
              if (set.reps != null && set.reps! > maxReps) {
                maxReps = set.reps!;
              }
              if (set.weight != null && set.reps != null) {
                totalVolume += set.weight! * set.reps!;
                
                final estimatedMax = calculateOneRepMax(set.weight!, set.reps!);
                if (estimatedMax > bestEstimatedOneRepMax) {
                  bestEstimatedOneRepMax = estimatedMax;
                }
              }
            }

            totalSetsCount += sets.length;

            dataPoints.add(ProgressDataPoint(
              date: workout.date,
              maxWeight: maxWeight,
              maxReps: maxReps,
              totalVolume: totalVolume,
              totalSets: sets.length,
              estimatedOneRepMax: bestEstimatedOneRepMax,
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
