import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'features/workouts/ui/active_workout_screen.dart';

void main() {
  // Initialize sqflite for desktop platforms
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const ProviderScope(child: GymTrackerApp()));
}

class GymTrackerApp extends StatelessWidget {
  const GymTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ActiveWorkoutScreen(),
    );
  }
}