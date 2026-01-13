class Exercise {
  final int? id;
  final String name;
  final String? category;
  final bool isBuiltin;

  Exercise({
    this.id,
    required this.name,
    this.category,
    this.isBuiltin = false,
  });

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as int,
      name: map['name'] as String,
      category: map['category'] as String?,
      isBuiltin: (map['is_built_in'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'is_built_in': isBuiltin ? 1 : 0,
    };
  }

  Exercise copyWith({
    int? id,
    String? name,
    String? category,
    bool? isBuiltin,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      isBuiltin: isBuiltin ?? this.isBuiltin,
    );
  }
}
