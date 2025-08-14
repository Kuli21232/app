class Goal {
  final String id;
  final String title;
  final String? note;
  final int priority; // 1..3
  final DateTime plannedDate;
  final DateTime createdAt;
  final DateTime? doneAt;

  const Goal({
    required this.id,
    required this.title,
    this.note,
    required this.priority,
    required this.plannedDate,
    required this.createdAt,
    this.doneAt,
  });

  bool get isDone => doneAt != null;

  Goal copyWith({
    String? title,
    String? note,
    int? priority,
    DateTime? plannedDate,
    DateTime? createdAt,
    DateTime? doneAt,
  }) => Goal(
        id: id,
        title: title ?? this.title,
        note: note ?? this.note,
        priority: priority ?? this.priority,
        plannedDate: plannedDate ?? this.plannedDate,
        createdAt: createdAt ?? this.createdAt,
        doneAt: doneAt ?? this.doneAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'note': note,
        'priority': priority,
        'plannedDate': plannedDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'doneAt': doneAt?.toIso8601String(),
      };

  static Goal fromMap(Map m) => Goal(
        id: m['id'],
        title: m['title'],
        note: m['note'],
        priority: m['priority'] ?? 1,
        plannedDate: DateTime.parse(m['plannedDate']),
        createdAt: DateTime.parse(m['createdAt']),
        doneAt: m['doneAt'] == null ? null : DateTime.parse(m['doneAt']),
      );
}