class Reflection {
  final DateTime date;
  final int mood;       // 1..5
  final String note;
  final int happiness;  // 0..100  ⬅️ новое

  const Reflection({
    required this.date,
    required this.mood,
    required this.note,
    required this.happiness,
  });

  Map<String, dynamic> toMap() => {
        'date': DateTime(date.year, date.month, date.day).toIso8601String(),
        'mood': mood,
        'note': note,
        'happiness': happiness,
      };

  static Reflection fromMap(Map m) => Reflection(
        date: DateTime.parse(m['date']),
        mood: (m['mood'] ?? 3) as int,
        note: (m['note'] ?? '') as String,
        happiness: (m['happiness'] ?? 50) as int, // совместимость со старыми записями
      );
}
