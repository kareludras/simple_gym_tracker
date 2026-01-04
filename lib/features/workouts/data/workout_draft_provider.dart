import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/workout.dart';
import 'models/set.dart';
import '../../exercises/data/models/exercise.dart';

class DraftSet {
  final int orderIndex;
  int? reps;
  double? weight;
  int? duration;
  bool isComplete;

  DraftSet({
    required this.orderIndex,
    this.reps,
    this.weight,
    this.duration,
    this.isComplete = false,
  });

  DraftSet copyWith({
    int? orderIndex,
    int? reps,
    double? weight,
    int? duration,
    bool? isComplete,
  }) {
    return DraftSet(
      orderIndex: orderIndex ?? this.orderIndex,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      isComplete: isComplete ?? this.isComplete,
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

  DraftWorkoutExercise addSet() {
    final newSet = sets.isEmpty
        ? DraftSet(orderIndex: 0)
        : DraftSet(
      orderIndex: sets.length,
      reps: sets.last.reps,
      weight: sets.last.weight,
      duration: sets.last.duration,
    );

    return copyWith(sets: [...sets, newSet]);
  }

  DraftWorkoutExercise updateSet(int index, DraftSet updatedSet) {
    final newSets = [...sets];
    newSets[index] = updatedSet;
    return copyWith(sets: newSets);
  }

  DraftWorkoutExercise removeSet(int index) {
    final newSets = [...sets];
    newSets.removeAt(index);
    for (int i = 0; i < newSets.length; i++) {
      newSets[i] = newSets[i].copyWith(orderIndex: i);
    }
    return copyWith(sets: newSets);
  }
}

class WorkoutDraft {
  final DateTime date;
  final List<DraftWorkoutExercise> exercises;
  final String? note;

  WorkoutDraft({
    DateTime? date,
    this.exercises = const [],
    this.note,
  }) : date = date ?? DateTime.now();

  bool get isEmpty => exercises.isEmpty;

  WorkoutDraft copyWith({
    DateTime? date,
    List<DraftWorkoutExercise>? exercises,
    String? note,
  }) {
    return WorkoutDraft(
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
      note: note ?? this.note,
    );
  }

  WorkoutDraft addExercise(Exercise exercise) {
    final draftExercise = DraftWorkoutExercise(
      exercise: exercise,
      sets: [DraftSet(orderIndex: 0)],
      orderIndex: exercises.length,
    );

    return copyWith(exercises: [...exercises, draftExercise]);
  }

  WorkoutDraft updateExercise(int index, DraftWorkoutExercise updated) {
    final newExercises = [...exercises];
    newExercises[index] = updated;
    return copyWith(exercises: newExercises);
  }

  WorkoutDraft removeExercise(int index) {
    final newExercises = [...exercises];
    newExercises.removeAt(index);
    for (int i = 0; i < newExercises.length; i++) {
      newExercises[i] = newExercises[i].copyWith(orderIndex: i);
    }
    return copyWith(exercises: newExercises);
  }

  WorkoutDraft reorderExercises(int oldIndex, int newIndex) {
    final newExercises = [...exercises];
    final item = newExercises.removeAt(oldIndex);
    newExercises.insert(newIndex, item);
    for (int i = 0; i < newExercises.length; i++) {
      newExercises[i] = newExercises[i].copyWith(orderIndex: i);
    }
    return copyWith(exercises: newExercises);
  }
}

class WorkoutDraftNotifier extends StateNotifier<WorkoutDraft> {
  WorkoutDraftNotifier() : super(WorkoutDraft());

  void startNewWorkout() {
    state = WorkoutDraft();
  }

  void addExercise(Exercise exercise) {
    state = state.addExercise(exercise);
  }

  void removeExercise(int index) {
    state = state.removeExercise(index);
  }

  void addSet(int exerciseIndex) {
    final updated = state.exercises[exerciseIndex].addSet();
    state = state.updateExercise(exerciseIndex, updated);
  }

  void updateSet(int exerciseIndex, int setIndex, DraftSet set) {
    final updated = state.exercises[exerciseIndex].updateSet(setIndex, set);
    state = state.updateExercise(exerciseIndex, updated);
  }

  void removeSet(int exerciseIndex, int setIndex) {
    final updated = state.exercises[exerciseIndex].removeSet(setIndex);
    state = state.updateExercise(exerciseIndex, updated);
  }

  void setNote(String? note) {
    state = state.copyWith(note: note);
  }

  void reorderExercises(int oldIndex, int newIndex) {
    state = state.reorderExercises(oldIndex, newIndex);
  }

  void clear() {
    state = WorkoutDraft();
  }
}

final workoutDraftProvider =
StateNotifierProvider<WorkoutDraftNotifier, WorkoutDraft>((ref) {
  return WorkoutDraftNotifier();
});