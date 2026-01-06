import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/providers.dart';
import '../../../core/constants/ui_constants.dart';
import '../../exercises/data/models/exercise.dart';
import '../../settings/data/settings_provider.dart';
import '../../settings/data/settings_repository.dart';
import '../domain/exercise_progress_calculator.dart';
import 'predictive_calculator_screen.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  Exercise? _selectedExercise;

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
      ),
      body: exercisesAsync.when(
        data: (exercises) => _buildProgressView(exercises),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCalculator(context),
        icon: const Icon(Icons.calculate),
        label: const Text('Calculator'),
      ),
    );
  }

  Widget _buildProgressView(List<Exercise> exercises) {
    if (exercises.isEmpty) {
      return const Center(child: Text('No exercises yet'));
    }

    return Column(
      children: [
        _buildExerciseSelector(exercises),
        Expanded(
          child: _selectedExercise != null
              ? _buildChartsForExercise(_selectedExercise!)
              : _buildSelectExercisePrompt(),
        ),
      ],
    );
  }

  Widget _buildExerciseSelector(List<Exercise> exercises) {
    return Card(
      margin: const EdgeInsets.all(UIConstants.mediumSpacing),
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.mediumSpacing),
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
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectExercisePrompt() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 80, color: Colors.grey),
          SizedBox(height: UIConstants.mediumSpacing),
          Text(
            'Select an exercise to view progress',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsForExercise(Exercise exercise) {
    final progressDataAsync = ref.watch(
      exerciseProgressProvider(exercise.id!),
    );

    return progressDataAsync.when(
      data: (progressData) {
        if (progressData.dataPoints.isEmpty) {
          return const Center(
            child: Text('No workout data for this exercise yet'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(UIConstants.mediumSpacing),
          child: Column(
            children: [
              _buildMaxWeightChart(progressData),
              const SizedBox(height: UIConstants.largeSpacing),
              _buildOneRepMaxChart(progressData),
              const SizedBox(height: UIConstants.largeSpacing),
              _buildVolumeChart(progressData),
              const SizedBox(height: UIConstants.largeSpacing),
              _buildStatsCards(progressData),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildMaxWeightChart(ExerciseProgressData progressData) {
    final weightUnit = ref.watch(weightUnitProvider);
    final unitLabel = weightUnit == WeightUnit.kg ? 'kg' : 'lb';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Max Weight Over Time ($unitLabel)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.mediumSpacing),
            SizedBox(
              height: 200,
              child: LineChart(
                _createLineChartData(
                  progressData.dataPoints,
                  (point) => point.maxWeight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOneRepMaxChart(ExerciseProgressData progressData) {
    final weightUnit = ref.watch(weightUnitProvider);
    final unitLabel = weightUnit == WeightUnit.kg ? 'kg' : 'lb';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated 1RM Over Time ($unitLabel)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Using Epley formula: weight × (1 + reps/30)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.mediumSpacing),
            SizedBox(
              height: 200,
              child: LineChart(
                _createLineChartData(
                  progressData.dataPoints,
                  (point) => point.estimatedOneRepMax,
                  color: Colors.purple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeChart(ExerciseProgressData progressData) {
    final weightUnit = ref.watch(weightUnitProvider);
    final unitLabel = weightUnit == WeightUnit.kg ? 'kg' : 'lb';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Volume per Workout ($unitLabel)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UIConstants.mediumSpacing),
            SizedBox(
              height: 200,
              child: LineChart(
                _createLineChartData(
                  progressData.dataPoints,
                  (point) => point.totalVolume,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards(ExerciseProgressData progressData) {
    final weightUnit = ref.watch(weightUnitProvider);
    final unitLabel = weightUnit == WeightUnit.kg ? 'kg' : 'lb';

    final latestOneRepMax = progressData.dataPoints.isNotEmpty
        ? progressData.dataPoints.last.estimatedOneRepMax
        : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Workouts',
                progressData.totalWorkouts.toString(),
                Icons.fitness_center,
              ),
            ),
            const SizedBox(width: UIConstants.mediumSpacing),
            Expanded(
              child: _buildStatCard(
                'Total Sets',
                progressData.totalSets.toString(),
                Icons.format_list_numbered,
              ),
            ),
          ],
        ),
        const SizedBox(height: UIConstants.mediumSpacing),
        _buildStatCard(
          'Current Estimated 1RM',
          '${latestOneRepMax.toStringAsFixed(1)} $unitLabel',
          Icons.trending_up,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon, {
    bool isFullWidth = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(UIConstants.cardPadding),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: UIConstants.smallSpacing),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _createLineChartData(
    List<ProgressDataPoint> dataPoints,
    double Function(ProgressDataPoint) valueExtractor, {
    Color color = Colors.blue,
  }) {
    final spots = dataPoints.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        valueExtractor(entry.value),
      );
    }).toList();

    return LineChartData(
      gridData: const FlGridData(show: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < dataPoints.length) {
                final date = dataPoints[value.toInt()].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('M/d').format(date),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: true),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: color,
          barWidth: 3,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: color.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  void _openCalculator(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PredictiveCalculatorScreen(),
      ),
    );
  }
}
