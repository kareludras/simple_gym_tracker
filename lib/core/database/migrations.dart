import 'package:sqflite/sqflite.dart';
import 'tables.dart';

class Migrations {
  static Future<void> onCreate(Database db, int version) async {
    await db.execute(Tables.createExercises);
    await db.execute(Tables.createWorkouts);
    await db.execute(Tables.createWorkoutExercises);
    await db.execute(Tables.createSets);

    final now = DateTime.now().millisecondsSinceEpoch;
    for (final exercise in Tables.builtInExercises) {
      await db.insert(Tables.exercises, {
        'name': exercise['name'],
        'category': exercise['category'],
        'is_builtin': 1,
        'created_at': now,
      });
    }
  }

  static Future<void> onUpgrade(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    // Future schema changes
  }
}