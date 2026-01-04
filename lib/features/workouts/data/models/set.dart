class ExerciseSet {
  final int? id;
  final int workoutExerciseId;
  final int? reps;
  final double? weight;
  final int? duration;
  final int orderIndex;

  ExerciseSet({
    this.id,
    required this.workoutExerciseId,
    this.reps,
    this.weight,
    this.duration,
    required this.orderIndex,
  });

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      id: map['id'] as int,
      workoutExerciseId: map['workout_exercise_id'] as int,
      reps: map['reps'] as int?,
      weight: map['weight'] as double?,
      duration: map['duration'] as int?,
      orderIndex: map['order_index'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'workout_exercise_id': workoutExerciseId,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'order_index': orderIndex,
    };
  }

  ExerciseSet copyWith({
    int? id,
    int? workoutExerciseId,
    int? reps,
    double? weight,
    int? duration,
    int? orderIndex,
  }) {
    return ExerciseSet(
      id: id ?? this.id,
      workoutExerciseId: workoutExerciseId ?? this.workoutExerciseId,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      duration: duration ?? this.duration,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}