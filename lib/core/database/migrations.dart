import 'package:flutter/foundation.dart' show debugPrint;
import 'package:sqflite/sqflite.dart';

class Migrations {
  static Future<void> onCreate(Database db, int version) async {
    debugPrint('Creating database tables...');
    
    await db.execute('''
      CREATE TABLE exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT,
        is_built_in INTEGER NOT NULL DEFAULT 0
      )
    ''');
    debugPrint('Created exercises table');

    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        note TEXT
      )
    ''');
    debugPrint('Created workouts table');

    await db.execute('''
      CREATE TABLE workout_exercises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_id INTEGER NOT NULL,
        exercise_id INTEGER NOT NULL,
        order_index INTEGER NOT NULL,
        FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE,
        FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
      )
    ''');
    debugPrint('Created workout_exercises table');

    await db.execute('''
      CREATE TABLE sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        workout_exercise_id INTEGER NOT NULL,
        reps INTEGER,
        weight REAL,
        duration INTEGER,
        order_index INTEGER NOT NULL,
        FOREIGN KEY (workout_exercise_id) REFERENCES workout_exercises (id) ON DELETE CASCADE
      )
    ''');
    debugPrint('Created sets table');

    await _insertBuiltInExercises(db);
    debugPrint('Database creation complete!');
  }

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Handle migrations here
  }

  static Future<void> _insertBuiltInExercises(Database db) async {
    debugPrint('Inserting built-in exercises...');
    
    final exercises = [
      {'name': 'Squat', 'category': 'Legs', 'is_built_in': 1},
      {'name': 'Deadlift', 'category': 'Back', 'is_built_in': 1},
      {'name': 'Bench Press', 'category': 'Chest', 'is_built_in': 1},
      {'name': 'Overhead Press', 'category': 'Shoulders', 'is_built_in': 1},
      {'name': 'Barbell Row', 'category': 'Back', 'is_built_in': 1},
      {'name': 'Pull Up', 'category': 'Back', 'is_built_in': 1},
      {'name': 'Dip', 'category': 'Chest', 'is_built_in': 1},
      {'name': 'Leg Press', 'category': 'Legs', 'is_built_in': 1},
      {'name': 'Leg Curl', 'category': 'Legs', 'is_built_in': 1},
      {'name': 'Leg Extension', 'category': 'Legs', 'is_built_in': 1},
      {'name': 'Calf Raise', 'category': 'Legs', 'is_built_in': 1},
      {'name': 'Bicep Curl', 'category': 'Arms', 'is_built_in': 1},
      {'name': 'Tricep Extension', 'category': 'Arms', 'is_built_in': 1},
      {'name': 'Lateral Raise', 'category': 'Shoulders', 'is_built_in': 1},
      {'name': 'Front Raise', 'category': 'Shoulders', 'is_built_in': 1},
      {'name': 'Shrug', 'category': 'Back', 'is_built_in': 1},
      {'name': 'Crunch', 'category': 'Core', 'is_built_in': 1},
      {'name': 'Plank', 'category': 'Core', 'is_built_in': 1},
      {'name': 'Russian Twist', 'category': 'Core', 'is_built_in': 1},
      {'name': 'Hanging Leg Raise', 'category': 'Core', 'is_built_in': 1},
    ];

    for (final exercise in exercises) {
      await db.insert('exercises', exercise);
    }
    
    debugPrint('Inserted ${exercises.length} built-in exercises');
  }
}
