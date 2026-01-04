import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/workout_draft_provider.dart';

class ExerciseCard extends ConsumerWidget {
  final DraftWorkoutExercise draftExercise;
  final int exerciseIndex;
  final VoidCallback onRemove;

  const ExerciseCard({
    required this.draftExercise,
    required this.exerciseIndex,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draftExercise.exercise.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (draftExercise.exercise.category != null)
                        Text(
                          draftExercise.exercise.category!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onRemove,
                ),
              ],
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  const SizedBox(width: 40, child: Text('Set', style: TextStyle(fontWeight: FontWeight.bold))),
                  const Expanded(child: Text('Weight (kg)', style: TextStyle(fontWeight: FontWeight.bold))),
                  const Expanded(child: Text('Reps', style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(width: 40, child: Text('✓', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const Divider(),

            ...List.generate(draftExercise.sets.length, (setIndex) {
              return _SetRow(
                set: draftExercise.sets[setIndex],
                setNumber: setIndex + 1,
                exerciseIndex: exerciseIndex,
                setIndex: setIndex,
                onRemove: draftExercise.sets.length > 1
                    ? () => ref
                    .read(workoutDraftProvider.notifier)
                    .removeSet(exerciseIndex, setIndex)
                    : null,
              );
            }),

            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () => ref
                    .read(workoutDraftProvider.notifier)
                    .addSet(exerciseIndex),
                icon: const Icon(Icons.add),
                label: const Text('Add Set'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetRow extends ConsumerStatefulWidget {
  final DraftSet set;
  final int setNumber;
  final int exerciseIndex;
  final int setIndex;
  final VoidCallback? onRemove;

  const _SetRow({
    required this.set,
    required this.setNumber,
    required this.exerciseIndex,
    required this.setIndex,
    this.onRemove,
  });

  @override
  ConsumerState<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends ConsumerState<_SetRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set.weight?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.set.reps?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${widget.setNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // Weight input
          Expanded(
            child: TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _updateWeight(value),
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _updateReps(value),
            ),
          ),
          const SizedBox(width: 8),

          SizedBox(
            width: 40,
            child: Checkbox(
              value: widget.set.isComplete,
              onChanged: (value) => _toggleComplete(value ?? false),
            ),
          ),
        ],
      ),
    );
  }

  void _updateWeight(String value) {
    final weight = double.tryParse(value);
    final updated = widget.set.copyWith(weight: weight);
    ref
        .read(workoutDraftProvider.notifier)
        .updateSet(widget.exerciseIndex, widget.setIndex, updated);
  }

  void _updateReps(String value) {
    final reps = int.tryParse(value);
    final updated = widget.set.copyWith(reps: reps);
    ref
        .read(workoutDraftProvider.notifier)
        .updateSet(widget.exerciseIndex, widget.setIndex, updated);
  }

  void _toggleComplete(bool value) {
    final updated = widget.set.copyWith(isComplete: value);
    ref
        .read(workoutDraftProvider.notifier)
        .updateSet(widget.exerciseIndex, widget.setIndex, updated);
  }
}