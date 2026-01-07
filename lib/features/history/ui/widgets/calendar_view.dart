import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers.dart';
import '../../../../core/constants/ui_constants.dart';
import '../../../workouts/data/models/workout.dart';
import '../workout_detail_screen.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(workoutListProvider);

    return workoutsAsync.when(
      data: (workouts) {
        return _buildCalendarView(workouts);
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, stack) {
        return Center(child: Text('Error: $error'));
      },
    );
  }

  Widget _buildCalendarView(List<Workout> workouts) {
    final workoutMap = _buildWorkoutMap(workouts);
    
    final selectedDayWorkouts = _selectedDay != null
        ? _getWorkoutsForDay(_selectedDay!, workoutMap)
        : <Workout>[];

    return Column(
      children: [
        _buildCalendar(workoutMap),
        const Divider(height: 1),
        Expanded(
          child: _buildWorkoutsList(selectedDayWorkouts),
        ),
      ],
    );
  }

  Widget _buildCalendar(Map<DateTime, List<Workout>> workoutMap) {
    return Card(
      margin: const EdgeInsets.all(UIConstants.mediumSpacing),
      child: TableCalendar<Workout>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        eventLoader: (day) => _getWorkoutsForDay(day, workoutMap),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          markersMaxCount: 1,
          markerDecoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
      ),
    );
  }

  Widget _buildWorkoutsList(List<Workout> workouts) {
    if (_selectedDay == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 60, color: Colors.grey),
            SizedBox(height: UIConstants.mediumSpacing),
            Text(
              'Select a day to view workouts',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (workouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 60, color: Colors.grey),
            const SizedBox(height: UIConstants.mediumSpacing),
            Text(
              'No workouts on ${DateFormat('MMMM d, y').format(_selectedDay!)}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(UIConstants.mediumSpacing),
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: UIConstants.cardVerticalMargin),
          child: ListTile(
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
            title: Text(DateFormat('h:mm a').format(workout.date)),
            subtitle: workout.note != null
                ? Text(
                    workout.note!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _navigateToWorkoutDetail(workout),
          ),
        );
      },
    );
  }

  Map<DateTime, List<Workout>> _buildWorkoutMap(List<Workout> workouts) {
    final map = <DateTime, List<Workout>>{};
    
    for (final workout in workouts) {
      final normalizedDate = DateTime(
        workout.date.year,
        workout.date.month,
        workout.date.day,
      );
      
      map.putIfAbsent(normalizedDate, () => []).add(workout);
    }
    
    return map;
  }

  List<Workout> _getWorkoutsForDay(
    DateTime day,
    Map<DateTime, List<Workout>> workoutMap,
  ) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return workoutMap[normalizedDay] ?? [];
  }

  void _navigateToWorkoutDetail(Workout workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetailScreen(workout: workout),
      ),
    );
  }
}
