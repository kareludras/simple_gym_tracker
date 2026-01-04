import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../data/models/exercise.dart';

class ExerciseListScreen extends ConsumerWidget {
  const ExerciseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exerciseListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
      ),
      body: exercisesAsync.when(
        data: (exercises) => _buildExerciseList(exercises),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildExerciseList(List<Exercise> exercises) {
    if (exercises.isEmpty) {
      return const Center(
        child: Text('No exercises found'),
      );
    }

    final grouped = <String, List<Exercise>>{};
    for (final exercise in exercises) {
      final category = exercise.category ?? 'Other';
      grouped.putIfAbsent(category, () => []).add(exercise);
    }

    return ListView.builder(
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final category = grouped.keys.elementAt(index);
        final categoryExercises = grouped[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...categoryExercises.map((exercise) {
              return ListTile(
                title: Text(exercise.name),
                trailing: exercise.isBuiltin
                    ? const Chip(
                  label: Text('Built-in'),
                  labelStyle: TextStyle(fontSize: 12),
                )
                    : null,
              );
            }),
            const Divider(),
          ],
        );
      },
    );
  }
}