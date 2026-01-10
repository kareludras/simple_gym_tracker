import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/exercises/data/models/exercise.dart';
import 'models/set.dart';

class DraftSet {
  final int? reps;
  final double? weight;
  final int? duration;
  final bool isComplete;
  final int orderIndex;

  DraftSet({
    this.reps,
    this.weight,
    this.duration,
    this.isComplete = false,
    required this.orderIndex,
  });

  DraftSet copyWith({
    int? reps,
    double? weight,
    int? duration,
    bool? isComplete,
    int? orderIndex,
  }) {
    return DraftSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      isComplete: isComplete ?? this.isComplete,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  ExerciseSet toExerciseSet(int workoutExerciseId) {
    return ExerciseSet(
      workoutExerciseId: workoutExerciseId,
      reps: reps,
      weight: weight,
      duration: duration,
      orderIndex: orderIndex,
    );
  }
}

class DraftWorkoutExercise {
  final Exercise exercise;
  final List<DraftSet> sets;
  final int orderIndex;

  DraftWorkoutExercise({
    required this.exercise,
    required this.sets,
    required this.orderIndex,
  });

  DraftWorkoutExercise copyWith({
    Exercise? exercise,
    List<DraftSet>? sets,
    int? orderIndex,
  }) {
    return DraftWorkoutExercise(
      exercise: exercise ?? this.exercise,
      sets: sets ?? this.sets,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}

class WorkoutDraft {
  final DateTime date;
  final String? note;
  final List<DraftWorkoutExercise> exercises;

  WorkoutDraft({
    required this.date,
    this.note,
    required this.exercises,
  });

  bool get isEmpty => exercises.isEmpty;

  WorkoutDraft copyWith({
    DateTime? date,
    String? note,
    List<DraftWorkoutExercise>? exercises,
  }) {
    return WorkoutDraft(
      date: date ?? this.date,
      note: note ?? this.note,
      exercises: exercises ?? this.exercises,
    );
  }
}

class WorkoutDraftNotifier extends StateNotifier<WorkoutDraft> {
  WorkoutDraftNotifier()
      : super(WorkoutDraft(
          date: DateTime.now(),
          exercises: [],
        ));

  void startNewWorkout() {
    state = WorkoutDraft(
      date: DateTime.now(),
      exercises: [],
    );
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void setNote(String? note) {
    state = state.copyWith(note: note);
  }

  void addExercise(Exercise exercise) {
    final newExercise = DraftWorkoutExercise(
      exercise: exercise,
      sets: [
        DraftSet(orderIndex: 0),
      ],
      orderIndex: state.exercises.length,
    );

    state = state.copyWith(
      exercises: [...state.exercises, newExercise],
    );
  }

  void removeExercise(int index) {
    final updatedExercises = List<DraftWorkoutExercise>.from(state.exercises);
    updatedExercises.removeAt(index);

    for (int i = 0; i < updatedExercises.length; i++) {
      updatedExercises[i] = updatedExercises[i].copyWith(orderIndex: i);
    }

    state = state.copyWith(exercises: updatedExercises);
  }

  void addSet(int exerciseIndex) {
    final updatedExercises = List<DraftWorkoutExercise>.from(state.exercises);
    final exercise = updatedExercises[exerciseIndex];

    final newSet = DraftSet(orderIndex: exercise.sets.length);
    final updatedSets = [...exercise.sets, newSet];

    updatedExercises[exerciseIndex] = exercise.copyWith(sets: updatedSets);
    state = state.copyWith(exercises: updatedExercises);
  }

  void removeSet(int exerciseIndex, int setIndex) {
    final updatedExercises = List<DraftWorkoutExercise>.from(state.exercises);
    final exercise = updatedExercises[exerciseIndex];

    final updatedSets = List<DraftSet>.from(exercise.sets);
    updatedSets.removeAt(setIndex);

    for (int i = 0; i < updatedSets.length; i++) {
      updatedSets[i] = updatedSets[i].copyWith(orderIndex: i);
    }

    updatedExercises[exerciseIndex] = exercise.copyWith(sets: updatedSets);
    state = state.copyWith(exercises: updatedExercises);
  }

  void updateSet(int exerciseIndex, int setIndex, DraftSet updatedSet) {
    final updatedExercises = List<DraftWorkoutExercise>.from(state.exercises);
    final exercise = updatedExercises[exerciseIndex];

    final updatedSets = List<DraftSet>.from(exercise.sets);
    updatedSets[setIndex] = updatedSet;

    updatedExercises[exerciseIndex] = exercise.copyWith(sets: updatedSets);
    state = state.copyWith(exercises: updatedExercises);
  }

  void clear() {
    state = WorkoutDraft(
      date: DateTime.now(),
      exercises: [],
    );
  }
}

final workoutDraftProvider =
    StateNotifierProvider<WorkoutDraftNotifier, WorkoutDraft>((ref) {
  return WorkoutDraftNotifier();
});
