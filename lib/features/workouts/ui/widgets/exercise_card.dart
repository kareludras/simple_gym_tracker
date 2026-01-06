import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/workout_draft_provider.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../../features/settings/data/settings_provider.dart';
import '../../../../features/settings/data/settings_repository.dart';

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
      margin: const EdgeInsets.symmetric(
        horizontal: UIConstants.cardHorizontalMargin,
        vertical: UIConstants.cardVerticalMargin,
      ),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: UIConstants.mediumSpacing),
            _buildSetsHeader(ref),
            const Divider(),
            _buildSetsList(ref),
            const SizedBox(height: UIConstants.smallSpacing),
            _buildAddSetButton(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                draftExercise.exercise.name,
                style: const TextStyle(
                  fontSize: UIConstants.exerciseNameFontSize,
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
    );
  }

  Widget _buildSetsHeader(WidgetRef ref) {
    final weightUnit = ref.watch(weightUnitProvider);
    final unitLabel = weightUnit == WeightUnit.kg ? 'kg' : 'lb';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UIConstants.smallSpacing),
      child: Row(
        children: [
          SizedBox(
            width: UIConstants.setNumberWidth,
            child: const Text(
              'Set',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              'Weight ($unitLabel)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Expanded(
            child: Text(
              'Reps',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: UIConstants.checkboxWidth,
            child: const Text(
              '✓',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetsList(WidgetRef ref) {
    return Column(
      children: List.generate(draftExercise.sets.length, (setIndex) {
        return _SetRow(
          set: draftExercise.sets[setIndex],
          setNumber: setIndex + 1,
          exerciseIndex: exerciseIndex,
          setIndex: setIndex,
          onRemove: draftExercise.sets.length > UIConstants.minimumSetsBeforeDelete
              ? () => ref
                  .read(workoutDraftProvider.notifier)
                  .removeSet(exerciseIndex, setIndex)
              : null,
        );
      }),
    );
  }

  Widget _buildAddSetButton(WidgetRef ref) {
    return Center(
      child: TextButton.icon(
        onPressed: () => ref
            .read(workoutDraftProvider.notifier)
            .addSet(exerciseIndex),
        icon: const Icon(Icons.add),
        label: const Text('Add Set'),
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
          _buildSetNumber(),
          _buildWeightInput(),
          const SizedBox(width: UIConstants.smallSpacing),
          _buildRepsInput(),
          const SizedBox(width: UIConstants.smallSpacing),
          _buildCompleteCheckbox(),
        ],
      ),
    );
  }

  Widget _buildSetNumber() {
    return SizedBox(
      width: UIConstants.setNumberWidth,
      child: Text(
        '${widget.setNumber}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildWeightInput() {
    return Expanded(
      child: TextField(
        controller: _weightController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: UIConstants.smallSpacing,
            vertical: UIConstants.smallSpacing,
          ),
          border: OutlineInputBorder(),
        ),
        onChanged: _updateWeight,
      ),
    );
  }

  Widget _buildRepsInput() {
    return Expanded(
      child: TextField(
        controller: _repsController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: UIConstants.smallSpacing,
            vertical: UIConstants.smallSpacing,
          ),
          border: OutlineInputBorder(),
        ),
        onChanged: _updateReps,
      ),
    );
  }

  Widget _buildCompleteCheckbox() {
    return SizedBox(
      width: UIConstants.checkboxWidth,
      child: Checkbox(
        value: widget.set.isComplete,
        onChanged: (value) => _toggleComplete(value ?? false),
      ),
    );
  }

  void _updateWeight(String value) {
    final weight = double.tryParse(value);
    final updated = widget.set.copyWith(weight: weight);
    _updateSetInProvider(updated);
  }

  void _updateReps(String value) {
    final reps = int.tryParse(value);
    final updated = widget.set.copyWith(reps: reps);
    _updateSetInProvider(updated);
  }

  void _toggleComplete(bool value) {
    final updated = widget.set.copyWith(isComplete: value);
    _updateSetInProvider(updated);
  }

  void _updateSetInProvider(DraftSet updatedSet) {
    ref
        .read(workoutDraftProvider.notifier)
        .updateSet(widget.exerciseIndex, widget.setIndex, updatedSet);
  }
}
