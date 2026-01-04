import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database/db.dart';
import '../features/exercises/data/exercise_repository.dart';
import '../features/exercises/data/models/exercise.dart';

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ExerciseRepository(db);
});

final exerciseListProvider = FutureProvider<List<Exercise>>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return await repo.getAll();
});