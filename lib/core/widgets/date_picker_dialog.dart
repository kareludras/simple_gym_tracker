import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkoutDatePicker {
  WorkoutDatePicker._();

  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    String title = 'Select Date',
  }) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: title,
    );

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      helpText: 'Select Time',
    );

    if (selectedTime == null) return selectedDate;

    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  static Future<DateTime?> showWithConfirmation({
    required BuildContext context,
    required DateTime currentDate,
  }) async {
    final newDate = await show(
      context: context,
      initialDate: currentDate,
      title: 'Change Workout Date',
    );

    if (newDate == null) return null;

    if (!context.mounted) return newDate;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Date Change'),
        content: Text(
          'Change workout date to ${DateFormat('EEEE, MMMM d, y \'at\' h:mm a').format(newDate)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    return confirmed == true ? newDate : null;
  }
}
