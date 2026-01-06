import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers.dart';
import '../../../core/constants/ui_constants.dart';
import '../../workouts/data/models/workout.dart';
import '../../workouts/data/models/workout_exercise.dart';
import '../../workouts/data/models/set.dart';
import '../../exercises/data/models/exercise.dart';
import '../../settings/data/settings_provider.dart';
import '../../settings/data/settings_repository.dart';

final workoutDetailProvider = FutureProvider.family<List<WorkoutExerciseDetail>, int>(
  (ref, workoutId) async {
    final workoutRepository = ref.watch(workoutRepositoryProvider);
    final exerciseRepository = ref.watch(exerciseRepositoryProvider);

    final workoutExercises = await workoutRepository.getWorkoutExercises(workoutId);
    final details = <WorkoutExerciseDetail>[];

    for (final workoutExercise in workoutExercises) {
      final exercise = await exerciseRepository.getExerciseById(
        workoutExercise.exerciseId,
      );
      final sets = await workoutRepository.getSets(workoutExercise.id!);

      if (exercise != null) {
        details.add(WorkoutExerciseDetail(
          workoutExercise: workoutExercise,
          exercise: exercise,
          sets: sets,
        ));
      }
    }

    return details;
  },
);

class WorkoutExerciseDetail {
  final WorkoutExercise workoutExercise;
  final Exercise exercise;
  final List<ExerciseSet> sets;

  WorkoutExerciseDetail({
    required this.workoutExercise,
    required this.exercise,
    required this.sets,
  });

  double get totalVolume {
    return sets.fold(0.0, (sum, set) {
      if (set.weight != null && set.reps != null) {
        return sum + (set.weight! * set.reps!);
      }
      return sum;
    });
  }

  int get totalReps {
    return sets.fold(0, (sum, set) => sum + (set.reps ?? 0));
  }
}

class WorkoutDetailScreen extends ConsumerWidget {
  final Workout workout;

  const WorkoutDetailScreen({
    required this.workout,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(workoutDetailProvider(workout.id!));
    final weightUnit = ref.watch(weightUnitProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('EEEE, MMM d, y').format(workout.date)),
      ),
      body: detailsAsync.when(
        data: (details) => _buildWorkoutDetails(context, details, weightUnit),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildWorkoutDetails(
    BuildContext context,
    List<WorkoutExerciseDetail> details,
    WeightUnit weightUnit,
  ) {
    if (details.isEmpty) {
      return const Center(child: Text('No exercises in this workout'));
    }

    final unitLabel = weightUnit == WeightUnit.kg ? 'kg' : 'lb';

    return ListView(
      padding: const EdgeInsets.all(UIConstants.mediumSpacing),
      children: [
        if (workout.note != null) _buildNoteCard(),
        _buildWorkoutSummary(details, unitLabel),
        const SizedBox(height: UIConstants.mediumSpacing),
        ...details.map((detail) => _buildExerciseCard(detail, unitLabel)),
      ],
    );
  }

  Widget _buildNoteCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.mediumSpacing),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.note, size: 20),
                SizedBox(width: UIConstants.smallSpacing),
                Text(
                  'Note',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.smallSpacing),
            Text(workout.note!),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutSummary(
    List<WorkoutExerciseDetail> details,
    String unitLabel,
  ) {
    final totalVolume = details.fold<double>(
      0.0,
      (sum, detail) => sum + detail.totalVolume,
    );
    final totalSets = details.fold<int>(
      0,
      (sum, detail) => sum + detail.sets.length,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          children: [
            const Text(
              'Workout Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.mediumSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Exercises',
                  details.length.toString(),
                  Icons.fitness_center,
                ),
                _buildSummaryItem(
                  'Total Sets',
                  totalSets.toString(),
                  Icons.format_list_numbered,
                ),
                _buildSummaryItem(
                  'Volume',
                  '${totalVolume.toStringAsFixed(0)} $unitLabel',
                  Icons.show_chart,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: UIConstants.smallSpacing),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(WorkoutExerciseDetail detail, String unitLabel) {
    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.cardVerticalMargin),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.exercise.name,
              style: const TextStyle(
                fontSize: UIConstants.exerciseNameFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.smallSpacing),
            Text(
              '${detail.sets.length} sets • ${detail.totalReps} reps • ${detail.totalVolume.toStringAsFixed(0)} $unitLabel',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: UIConstants.mediumSpacing),
            _buildSetsTable(detail.sets, unitLabel),
          ],
        ),
      ),
    );
  }

  Widget _buildSetsTable(List<ExerciseSet> sets, String unitLabel) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(50),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Set',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Weight ($unitLabel)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Reps',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        ...sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('${index + 1}'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(set.weight?.toStringAsFixed(1) ?? '-'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(set.reps?.toString() ?? '-'),
              ),
            ],
          );
        }),
      ],
    );
  }
}
