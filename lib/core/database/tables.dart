class Tables {
  static const String exercises = 'exercises';
  static const String workouts = 'workouts';
  static const String workoutExercises = 'workout_exercises';
  static const String sets = 'sets';

  static const String createExercises = '''
    CREATE TABLE $exercises (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      category TEXT,
      is_builtin INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL
    )
  ''';

  static const String createWorkouts = '''
    CREATE TABLE $workouts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date INTEGER NOT NULL,
      note TEXT,
      created_at INTEGER NOT NULL
    )
  ''';

  static const String createWorkoutExercises = '''
    CREATE TABLE $workoutExercises (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      workout_id INTEGER NOT NULL,
      exercise_id INTEGER NOT NULL,
      order_index INTEGER NOT NULL,
      FOREIGN KEY (workout_id) REFERENCES $workouts (id),
      FOREIGN KEY (exercise_id) REFERENCES $exercises (id)
    )
  ''';

  static const String createSets = '''
    CREATE TABLE $sets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      workout_exercise_id INTEGER NOT NULL,
      reps INTEGER,
      weight REAL,
      duration INTEGER,
      order_index INTEGER NOT NULL,
      FOREIGN KEY (workout_exercise_id) REFERENCES $workoutExercises (id)
    )
  ''';

  // Built-in exercises data
  static const List<Map<String, dynamic>> builtInExercises = [
    {'name': 'Squat', 'category': 'Legs'},
    {'name': 'Bench Press', 'category': 'Chest'},
    {'name': 'Deadlift', 'category': 'Back'},
    {'name': 'Overhead Press', 'category': 'Shoulders'},
    {'name': 'Pull-up', 'category': 'Back'},
    {'name': 'Lat Pulldown', 'category': 'Back'},
    {'name': 'Barbell Row', 'category': 'Back'},
    {'name': 'Dumbbell Curl', 'category': 'Arms'},
    {'name': 'Triceps Pushdown', 'category': 'Arms'},
    {'name': 'Leg Press', 'category': 'Legs'},
    {'name': 'Romanian Deadlift', 'category': 'Legs'},
    {'name': 'Leg Curl', 'category': 'Legs'},
    {'name': 'Calf Raise', 'category': 'Legs'},
    {'name': 'Incline Bench Press', 'category': 'Chest'},
    {'name': 'Dumbbell Fly', 'category': 'Chest'},
    {'name': 'Lateral Raise', 'category': 'Shoulders'},
    {'name': 'Face Pull', 'category': 'Shoulders'},
    {'name': 'Hammer Curl', 'category': 'Arms'},
    {'name': 'Skull Crusher', 'category': 'Arms'},
    {'name': 'Plank', 'category': 'Core'},
  ];
}