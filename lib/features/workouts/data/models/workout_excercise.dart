class WorkoutExercise {
  final int? id;
  final int workoutId;
  final int exerciseId;
  final int orderIndex;

  WorkoutExercise({
    this.id,
    required this.workoutId,
    required this.exerciseId,
    required this.orderIndex,
  });

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      id: map['id'] as int,
      workoutId: map['workout_id'] as int,
      exerciseId: map['exercise_id'] as int,
      orderIndex: map['order_index'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'workout_id': workoutId,
      'exercise_id': exerciseId,
      'order_index': orderIndex,
    };
  }

  WorkoutExercise copyWith({
    int? id,
    int? workoutId,
    int? exerciseId,
    int? orderIndex,
  }) {
    return WorkoutExercise(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      exerciseId: exerciseId ?? this.exerciseId,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}