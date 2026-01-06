class DatabaseConstants {
  DatabaseConstants._();

  static const String databaseName = 'gym_tracker.db';
  static const int databaseVersion = 1;

  static const String exerciseDefaultOrder = 'is_builtin DESC, name ASC';
  static const String workoutDefaultOrder = 'date DESC';
  static const String setDefaultOrder = 'order_index ASC';
  static const String workoutExerciseDefaultOrder = 'order_index ASC';
}
