import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/features/progress/domain/exercise_progress_calculator.dart';

void main() {
  group('1RM Calculator', () {
    test('calculates 1RM correctly for 1 rep', () {
      final result = calculateOneRepMax(100, 1);
      
      expect(result, 100.0);
    });

    test('calculates 1RM correctly using Epley formula for 5 reps', () {
      final result = calculateOneRepMax(100, 5);
      
      expect(result, closeTo(116.67, 0.01));
    });

    test('calculates 1RM correctly for 10 reps', () {
      final result = calculateOneRepMax(80, 10);
      
      expect(result, closeTo(106.67, 0.01));
    });

    test('handles decimal weights', () {
      final result = calculateOneRepMax(67.5, 8);
      
      expect(result, closeTo(85.5, 0.1));
    });

    test('formula: weight × (1 + reps/30)', () {
      final weight = 90.0;
      final reps = 6;
      final expected = weight * (1 + reps / 30);
      
      final result = calculateOneRepMax(weight, reps);
      
      expect(result, expected);
    });
  });

  group('ProgressDataPoint', () {
    test('creates progress data point with all fields', () {
      final date = DateTime(2024, 1, 15);
      final point = ProgressDataPoint(
        date: date,
        maxWeight: 100,
        maxReps: 5,
        totalVolume: 500,
        totalSets: 3,
        estimatedOneRepMax: 116.67,
      );

      expect(point.date, date);
      expect(point.maxWeight, 100);
      expect(point.maxReps, 5);
      expect(point.totalVolume, 500);
      expect(point.totalSets, 3);
      expect(point.estimatedOneRepMax, 116.67);
    });
  });

  group('ExerciseProgressData', () {
    test('creates exercise progress data', () {
      final dataPoints = [
        ProgressDataPoint(
          date: DateTime(2024, 1, 15),
          maxWeight: 100,
          maxReps: 5,
          totalVolume: 500,
          totalSets: 3,
          estimatedOneRepMax: 116.67,
        ),
      ];

      final progressData = ExerciseProgressData(
        dataPoints: dataPoints,
        totalWorkouts: 1,
        totalSets: 3,
      );

      expect(progressData.dataPoints.length, 1);
      expect(progressData.totalWorkouts, 1);
      expect(progressData.totalSets, 3);
    });
  });
}
