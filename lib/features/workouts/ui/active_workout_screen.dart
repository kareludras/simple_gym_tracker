import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/workout_draft_provider.dart';
import 'widgets/exercise_card.dart';
import '../../../core/providers.dart';
import '../../../core/exceptions/app_exceptions.dart';
import '../../../core/widgets/date_picker_dialog.dart';

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
      appBar: _buildAppBar(draft),
      body: _isWorkoutActive ? _buildActiveWorkout() : _buildEmptyState(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(WorkoutDraft draft) {
    return AppBar(
      title: _isWorkoutActive
          ? InkWell(
              onTap: _showDatePicker,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(DateFormat('EEEE, MMM d').format(draft.date)),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit, size: 18),
                ],
              ),
            )
          : const Text('Workout'),
      actions: _isWorkoutActive ? _buildAppBarActions() : null,
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        icon: const Icon(Icons.note_add),
        onPressed: _showAddNoteDialog,
      ),
      IconButton(
        icon: const Icon(Icons.save),
        onPressed: _saveWorkout,
      ),
    ];
  }

  Widget? _buildFloatingActionButton() {
    if (!_isWorkoutActive) return null;

    return FloatingActionButton.extended(
      onPressed: _showExercisePicker,
      icon: const Icon(Icons.add),
      label: const Text('Add Exercise'),
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
      return _buildEmptyWorkoutState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: draft.exercises.length,
      itemBuilder: (context, index) => _buildExerciseCard(draft.exercises[index], index),
    );
  }

  Widget _buildEmptyWorkoutState() {
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
            onPressed: _showExercisePicker,
            icon: const Icon(Icons.add),
            label: const Text('Add your first exercise'),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(DraftWorkoutExercise draftExercise, int index) {
    return ExerciseCard(
      key: ValueKey(draftExercise.exercise.id),
      draftExercise: draftExercise,
      exerciseIndex: index,
      onRemove: () => _removeExercise(index),
    );
  }

  void _startWorkout() {
    ref.read(workoutDraftProvider.notifier).startNewWorkout();
    setState(() {
      _isWorkoutActive = true;
    });
  }

  Future<void> _showDatePicker() async {
    final draft = ref.read(workoutDraftProvider);
    final newDate = await WorkoutDatePicker.show(
      context: context,
      initialDate: draft.date,
      title: 'Change Workout Date',
    );

    if (newDate != null) {
      ref.read(workoutDraftProvider.notifier).setDate(newDate);
    }
  }

  Future<void> _showExercisePicker() async {
    final exercises = await ref.read(exerciseListProvider.future);
    
    if (!mounted) return;

    final selectedIndex = await showDialog<int>(
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
                subtitle: Text(exercises[index].category ?? ''),
                onTap: () => Navigator.pop(context, index),
              );
            },
          ),
        ),
      ),
    );

    if (selectedIndex != null) {
      _addExerciseToWorkout(exercises[selectedIndex]);
    }
  }

  void _addExerciseToWorkout(dynamic exercise) {
    ref.read(workoutDraftProvider.notifier).addExercise(exercise);
  }

  void _removeExercise(int index) {
    ref.read(workoutDraftProvider.notifier).removeExercise(index);
  }

  void _showAddNoteDialog() {
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
              final noteText = controller.text.trim();
              _saveWorkoutNote(noteText.isEmpty ? null : noteText);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveWorkoutNote(String? note) {
    ref.read(workoutDraftProvider.notifier).setNote(note);
  }

  Future<void> _saveWorkout() async {
    final draft = ref.read(workoutDraftProvider);

    if (!_isWorkoutValid(draft)) {
      return;
    }

    try {
      await _persistWorkoutToDatabase(draft);
      _cleanupAfterSuccessfulSave();
      _showSuccessMessage();
    } on InvalidWorkoutException catch (e) {
      _showErrorMessage(e.toString());
    } catch (error) {
      _showErrorMessage('Error saving workout: $error');
    }
  }

  bool _isWorkoutValid(WorkoutDraft draft) {
    if (draft.isEmpty) {
      _showErrorMessage('Add at least one exercise');
      return false;
    }
    return true;
  }

  Future<void> _persistWorkoutToDatabase(WorkoutDraft draft) async {
    final repository = ref.read(workoutRepositoryProvider);
    await repository.saveWorkoutDraft(draft);
  }

  void _cleanupAfterSuccessfulSave() {
    ref.read(workoutDraftProvider.notifier).clear();
    ref.invalidate(workoutListProvider);
    setState(() {
      _isWorkoutActive = false;
    });
  }

  void _showSuccessMessage() {
    _showSnackBar('Workout saved!');
  }

  void _showErrorMessage(String message) {
    _showSnackBar(message);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
