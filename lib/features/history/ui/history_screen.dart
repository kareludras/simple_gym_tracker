import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/date_picker_dialog.dart';
import 'workout_detail_screen.dart';
import 'widgets/calendar_view.dart';

enum HistoryViewMode { list, calendar }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  HistoryViewMode _viewMode = HistoryViewMode.list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: Icon(
              _viewMode == HistoryViewMode.list
                  ? Icons.calendar_month
                  : Icons.list,
            ),
            tooltip: _viewMode == HistoryViewMode.list
                ? 'Calendar View'
                : 'List View',
            onPressed: _toggleViewMode,
          ),
        ],
      ),
      body: _viewMode == HistoryViewMode.list
          ? _buildListView()
          : const CalendarView(),
    );
  }

  Widget _buildListView() {
    final workoutsAsync = ref.watch(workoutListProvider);

    return workoutsAsync.when(
      data: (workouts) {
        if (workouts.isEmpty) {
          return const Center(
            child: Text('No workouts yet. Start your first workout!'),
          );
        }

        return ListView.builder(
          itemCount: workouts.length,
          itemBuilder: (context, index) {
            final workout = workouts[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.fitness_center),
                ),
                title: InkWell(
                  onTap: () => _editWorkoutDate(workout),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(DateFormat('EEEE, MMMM d, y').format(workout.date)),
                      const SizedBox(width: 8),
                      const Icon(Icons.edit, size: 16),
                    ],
                  ),
                ),
                subtitle: workout.note != null
                    ? Text(
                        workout.note!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteWorkout(context, ref, workout.id!),
                ),
                onTap: () => _navigateToWorkoutDetail(context, workout),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == HistoryViewMode.list
          ? HistoryViewMode.calendar
          : HistoryViewMode.list;
    });
  }

  Future<void> _editWorkoutDate(dynamic workout) async {
    final newDate = await WorkoutDatePicker.showWithConfirmation(
      context: context,
      currentDate: workout.date,
    );

    if (newDate != null && mounted) {
      final updatedWorkout = workout.copyWith(date: newDate);
      final repository = ref.read(workoutRepositoryProvider);
      await repository.updateWorkout(updatedWorkout);
      ref.invalidate(workoutListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout date updated')),
        );
      }
    }
  }

  void _navigateToWorkoutDetail(BuildContext context, workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetailScreen(workout: workout),
      ),
    );
  }

  Future<void> _deleteWorkout(BuildContext context, WidgetRef ref, int workoutId) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Workout',
      message: 'Are you sure you want to delete this workout?',
      confirmText: 'Delete',
      isDangerous: true,
    );

    if (confirmed && context.mounted) {
      final repository = ref.read(workoutRepositoryProvider);
      await repository.deleteWorkoutCompletely(workoutId);
      ref.invalidate(workoutListProvider);
    }
  }
}
