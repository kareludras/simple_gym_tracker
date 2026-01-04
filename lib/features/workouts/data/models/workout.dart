class Workout {
  final int? id;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  Workout({
    this.id,
    required this.date,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      note: map['note'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date.millisecondsSinceEpoch,
      'note': note,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  Workout copyWith({
    int? id,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return Workout(
      id: id ?? this.id,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}