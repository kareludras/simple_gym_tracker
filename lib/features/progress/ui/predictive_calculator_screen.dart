import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/providers.dart';
import '../../exercises/data/models/exercise.dart';
import '../../settings/data/settings_provider.dart';
import '../../settings/data/settings_repository.dart';
import '../domain/exercise_progress_calculator.dart';

enum CalculationMode { predictWeight, predictReps }

class PredictiveCalculatorScreen extends ConsumerStatefulWidget {
  const PredictiveCalculatorScreen({super.key});

  @override
  ConsumerState<PredictiveCalculatorScreen> createState() =>
      _PredictiveCalculatorScreenState();
}

class _PredictiveCalculatorScreenState
    extends ConsumerState<PredictiveCalculatorScreen> {
  Exercise? _selectedExercise;
  CalculationMode _mode = CalculationMode.predictWeight;
  final _inputController = TextEditingController();
  
  double? _predictedValue;
  double? _currentEstimated1RM;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseListProvider);
    final weightUnit = ref.watch(weightUnitProvider);
    final unitLabel = weightUnit == WeightUnit.kg ? 'kg' : 'lb';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Predictive Calculator'),
      ),
      body: exercisesAsync.when(
        data: (exercises) => _buildCalculator(exercises, unitLabel),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildCalculator(List<Exercise> exercises, String unitLabel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(UIConstants.mediumSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildExerciseSelector(exercises),
          const SizedBox(height: UIConstants.mediumSpacing),
          _buildModeSelector(),
          const SizedBox(height: UIConstants.mediumSpacing),
          if (_selectedExercise != null) ...[
            _buildInputCard(unitLabel),
            const SizedBox(height: UIConstants.mediumSpacing),
            if (_currentEstimated1RM != null) ...[
              _buildCurrentStatsCard(unitLabel),
              const SizedBox(height: UIConstants.mediumSpacing),
            ],
            if (_predictedValue != null)
              _buildPredictionCard(unitLabel),
          ],
        ],
      ),
    );
  }

  Widget _buildExerciseSelector(List<Exercise> exercises) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Exercise',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.smallSpacing),
            DropdownButtonFormField<Exercise>(
              initialValue: _selectedExercise,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: UIConstants.mediumSpacing,
                  vertical: UIConstants.smallSpacing,
                ),
              ),
              hint: const Text('Choose an exercise'),
              items: exercises.map((exercise) {
                return DropdownMenuItem(
                  value: exercise,
                  child: Text(exercise.name),
                );
              }).toList(),
              onChanged: (exercise) {
                setState(() {
                  _selectedExercise = exercise;
                  _predictedValue = null;
                  _currentEstimated1RM = null;
                  _inputController.clear();
                });
                if (exercise != null) {
                  _loadExerciseData(exercise.id!);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What do you want to predict?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.smallSpacing),
            SegmentedButton<CalculationMode>(
              segments: const [
                ButtonSegment(
                  value: CalculationMode.predictWeight,
                  label: Text('Weight for Reps'),
                  icon: Icon(Icons.fitness_center),
                ),
                ButtonSegment(
                  value: CalculationMode.predictReps,
                  label: Text('Reps at Weight'),
                  icon: Icon(Icons.repeat),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (Set<CalculationMode> newSelection) {
                setState(() {
                  _mode = newSelection.first;
                  _predictedValue = null;
                  _inputController.clear();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(String unitLabel) {
    final label = _mode == CalculationMode.predictWeight
        ? 'Target Reps'
        : 'Target Weight ($unitLabel)';
    
    final hint = _mode == CalculationMode.predictWeight
        ? 'e.g., 5'
        : 'e.g., 100';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _inputController,
              keyboardType: _mode == CalculationMode.predictWeight
                  ? TextInputType.number
                  : const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: _mode == CalculationMode.predictWeight
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
              decoration: InputDecoration(
                labelText: label,
                hintText: hint,
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  _mode == CalculationMode.predictWeight
                      ? Icons.repeat
                      : Icons.fitness_center,
                ),
              ),
            ),
            const SizedBox(height: UIConstants.mediumSpacing),
            ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(UIConstants.mediumSpacing),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatsCard(String unitLabel) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          children: [
            const Text(
              'Your Current Stats',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.smallSpacing),
            Text(
              'Estimated 1RM: ${_currentEstimated1RM!.toStringAsFixed(1)} $unitLabel',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Based on your workout history',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(String unitLabel) {
    final String resultLabel;
    final String resultValue;
    final String explanation;

    if (_mode == CalculationMode.predictWeight) {
      final reps = int.parse(_inputController.text);
      resultLabel = 'Predicted Weight for $reps Reps';
      resultValue = '${_predictedValue!.toStringAsFixed(1)} $unitLabel';
      explanation = 'Based on your estimated 1RM of ${_currentEstimated1RM!.toStringAsFixed(1)} $unitLabel';
    } else {
      final weight = double.parse(_inputController.text);
      resultLabel = 'Predicted Reps at $weight $unitLabel';
      resultValue = '${_predictedValue!.toStringAsFixed(0)} reps';
      explanation = 'Based on your estimated 1RM of ${_currentEstimated1RM!.toStringAsFixed(1)} $unitLabel';
    }

    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 48,
            ),
            const SizedBox(height: UIConstants.mediumSpacing),
            Text(
              resultLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.smallSpacing),
            Text(
              resultValue,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: UIConstants.smallSpacing),
            Text(
              explanation,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.mediumSpacing),
            Container(
              padding: const EdgeInsets.all(UIConstants.mediumSpacing),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: Colors.amber),
                  const SizedBox(width: UIConstants.smallSpacing),
                  Expanded(
                    child: Text(
                      'This is an estimate based on the Epley formula. Actual performance may vary.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadExerciseData(int exerciseId) async {
    final progressData = await ref.read(
      exerciseProgressProvider(exerciseId).future,
    );

    if (progressData.dataPoints.isNotEmpty) {
      setState(() {
        _currentEstimated1RM = progressData.dataPoints.last.estimatedOneRepMax;
      });
    } else {
      setState(() {
        _currentEstimated1RM = null;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No workout history for this exercise yet'),
          ),
        );
      }
    }
  }

  void _calculate() {
    if (_currentEstimated1RM == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log some workouts first'),
        ),
      );
      return;
    }

    final input = _inputController.text;
    if (input.isEmpty) return;

    if (_mode == CalculationMode.predictWeight) {
      final reps = int.tryParse(input);
      if (reps == null || reps <= 0) return;

      final predictedWeight = _currentEstimated1RM! / (1 + reps / 30);
      
      setState(() {
        _predictedValue = predictedWeight;
      });
    } else {
      final weight = double.tryParse(input);
      if (weight == null || weight <= 0) return;

      final predictedReps = (_currentEstimated1RM! / weight - 1) * 30;
      
      setState(() {
        _predictedValue = predictedReps > 0 ? predictedReps : 0;
      });
    }
  }
}
