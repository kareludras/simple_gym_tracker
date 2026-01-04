import '../../../core/database/db.dart';
import '../../../core/database/tables.dart';
import 'models/exercise.dart';

class ExerciseRepository {
  final DatabaseService _db;

  ExerciseRepository(this._db);

  Future<List<Exercise>> getAll() async {
    final db = await _db.database;
    final maps = await db.query(
      Tables.exercises,
      orderBy: 'is_builtin DESC, name ASC',
    );
    return maps.map((m) => Exercise.fromMap(m)).toList();
  }

  Future<Exercise?> getById(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      Tables.exercises,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Exercise.fromMap(maps.first);
  }

  Future<Exercise> create(Exercise exercise) async {
    final db = await _db.database;
    final id = await db.insert(Tables.exercises, exercise.toMap());
    return exercise.copyWith(id: id);
  }

  Future<void> update(Exercise exercise) async {
    if (exercise.isBuiltin) {
      throw Exception('Cannot update built-in exercise');
    }
    final db = await _db.database;
    await db.update(
      Tables.exercises,
      exercise.toMap(),
      where: 'id = ?',
      whereArgs: [exercise.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;

    final exercise = await getById(id);
    if (exercise?.isBuiltin == true) {
      throw Exception('Cannot delete built-in exercise');
    }

    final usage = await db.query(
      Tables.workoutExercises,
      where: 'exercise_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (usage.isNotEmpty) {
      throw Exception('Cannot delete exercise used in workouts');
    }

    await db.delete(
      Tables.exercises,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}