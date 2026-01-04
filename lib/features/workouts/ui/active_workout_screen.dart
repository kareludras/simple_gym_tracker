import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/workout_draft_provider.dart';
import 'widgets/exercise_card.dart';
import '../../../core/providers.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  bool _isWorkoutActive = false;

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(workoutDraftProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isWorkoutActive
            ? Text(DateFormat('EEEE, MMM d').format(draft.date))
            : const Text('Workout'),
        actions: _isWorkoutActive
            ? [
          IconButton(
            icon: const Icon(Icons.note_add),
            onPressed: _addNote,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveWorkout,
          ),
        ]
            : null,
      ),
      body: _isWorkoutActive ? _buildActiveWorkout() : _buildEmptyState(),
      floatingActionButton: _isWorkoutActive
          ? FloatingActionButton.extended(
        onPressed: _addExercise,
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise'),
      )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.fitness_center,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          Text(
            'Ready to start your workout?',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _startWorkout,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Workout'),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveWorkout() {
    final draft = ref.watch(workoutDraftProvider);

    if (draft.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.fitness_center_outlined,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No exercises yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add),
              label: const Text('Add your first exercise'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: draft.exercises.length,
      itemBuilder: (context, index) {
        final draftExercise = draft.exercises[index];
        return ExerciseCard(
          key: ValueKey(draftExercise.exercise.id),
          draftExercise: draftExercise,
          exerciseIndex: index,
          onRemove: () => _removeExercise(index),
        );
      },
    );
  }

  void _startWorkout() {
    ref.read(workoutDraftProvider.notifier).startNewWorkout();
    setState(() {
      _isWorkoutActive = true;
    });
  }

  void _addExercise() async {
    //exercise picker later
    final exercises = await ref.read(exerciseListProvider.future);
    if (!mounted) return;

    final selected = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Exercise'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(exercises[index].name),
                onTap: () => Navigator.pop(context, index),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null) {
      ref.read(workoutDraftProvider.notifier).addExercise(exercises[selected]);
    }
  }

  void _removeExercise(int index) {
    ref.read(workoutDraftProvider.notifier).removeExercise(index);
  }

  void _addNote() {
    final draft = ref.read(workoutDraftProvider);
    final controller = TextEditingController(text: draft.note);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workout Note'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Add a note about this workout...',
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(workoutDraftProvider.notifier)
                  .setNote(controller.text.trim().isEmpty ? null : controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveWorkout() async {
    final draft = ref.read(workoutDraftProvider);

    if (draft.isEmpty) {
      _showSnackBar('Add at least one exercise');
      return;
    }

    try {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.saveWorkoutDraft(draft);

      ref.read(workoutDraftProvider.notifier).clear();
      ref.invalidate(workoutListProvider);

      setState(() {
        _isWorkoutActive = false;
      });

      _showSnackBar('Workout saved!');
    } catch (e) {
      _showSnackBar('Error saving workout: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}