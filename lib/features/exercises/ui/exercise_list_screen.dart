import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../data/models/exercise.dart';
import '../../../features/settings/data/settings_provider.dart';
import '../../../features/settings/data/settings_repository.dart';

class ExerciseListScreen extends ConsumerWidget {
  const ExerciseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exerciseListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddExerciseDialog(context, ref),
          ),
        ],
      ),
      body: exercisesAsync.when(
        data: (exercises) => _buildExerciseList(exercises, ref, context),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildExerciseList(List<Exercise> exercises, WidgetRef ref, BuildContext context) {
    if (exercises.isEmpty) {
      return const Center(
        child: Text('No exercises yet. Add one!'),
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
              return _ExerciseListItem(
                exercise: exercise,
                onEdit: exercise.isBuiltin
                    ? null
                    : () => _showEditExerciseDialog(context, ref, exercise),
                onDelete: exercise.isBuiltin
                    ? null
                    : () => _deleteExercise(context, ref, exercise),
              );
            }),
            const Divider(),
          ],
        );
      },
    );
  }

  void _showAddExerciseDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
                hintText: 'e.g., Barbell Squat',
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category (optional)',
                hintText: 'e.g., Legs',
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter exercise name')),
                );
                return;
              }

              final exercise = Exercise(
                name: name,
                category: categoryController.text.trim().isEmpty
                    ? null
                    : categoryController.text.trim(),
              );

              final repository = ref.read(exerciseRepositoryProvider);
              await repository.createCustomExercise(exercise);
              ref.invalidate(exerciseListProvider);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added $name')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditExerciseDialog(BuildContext context, WidgetRef ref, Exercise exercise) {
    final nameController = TextEditingController(text: exercise.name);
    final categoryController = TextEditingController(text: exercise.category ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Exercise Name',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category (optional)',
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter exercise name')),
                );
                return;
              }

              final updated = exercise.copyWith(
                name: name,
                category: categoryController.text.trim().isEmpty
                    ? null
                    : categoryController.text.trim(),
              );

              final repository = ref.read(exerciseRepositoryProvider);
              await repository.updateCustomExercise(updated);
              ref.invalidate(exerciseListProvider);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exercise updated')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExercise(BuildContext context, WidgetRef ref, Exercise exercise) async {
    final confirmed = await ConfirmationDialog.showDeleteConfirmation(
      context: context,
      itemName: exercise.name,
    );

    if (confirmed && context.mounted) {
      try {
        final repository = ref.read(exerciseRepositoryProvider);
        await repository.deleteCustomExercise(exercise.id!);
        ref.invalidate(exerciseListProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted ${exercise.name}')),
          );
        }
      } on BuiltInExerciseException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      } on ExerciseInUseException catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}

class _ExerciseListItem extends ConsumerWidget {
  final Exercise exercise;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ExerciseListItem({
    required this.exercise,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prMapAsync = ref.watch(prMapProvider);
    final weightUnit = ref.watch(weightUnitProvider);
    final unitLabel = weightUnit == WeightUnit.kg ? 'kg' : 'lb';

    return prMapAsync.when(
      data: (prMap) {
        final pr = prMap[exercise.id];

        return ListTile(
          title: Text(exercise.name),
          subtitle: pr != null
              ? Text(
                  'PR: ${pr.maxWeight?.toStringAsFixed(1) ?? '-'} $unitLabel × ${pr.maxReps ?? '-'} reps',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                  ),
                )
              : null,
          trailing: exercise.isBuiltin
              ? const Chip(
                  label: Text('Built-in'),
                  labelStyle: TextStyle(fontSize: 12),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: onEdit,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: onDelete,
                      ),
                  ],
                ),
        );
      },
      loading: () => ListTile(
        title: Text(exercise.name),
        trailing: exercise.isBuiltin
            ? const Chip(
                label: Text('Built-in'),
                labelStyle: TextStyle(fontSize: 12),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: onDelete,
                    ),
                ],
              ),
      ),
      error: (_, __) => ListTile(
        title: Text(exercise.name),
        trailing: exercise.isBuiltin
            ? const Chip(
                label: Text('Built-in'),
                labelStyle: TextStyle(fontSize: 12),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: onEdit,
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: onDelete,
                    ),
                ],
              ),
      ),
    );
  }
}
