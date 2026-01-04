class Exercise {
  final int? id;
  final String name;
  final String? category;
  final bool isBuiltin;
  final DateTime createdAt;

  Exercise({
    this.id,
    required this.name,
    this.category,
    this.isBuiltin = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int,
      name: map['name'] as String,
      category: map['category'] as String?,
      isBuiltin: (map['is_builtin'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'is_builtin': isBuiltin ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  Exercise copyWith({
    int? id,
    String? name,
    String? category,
    bool? isBuiltin,
    DateTime? createdAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}