class PomodoroSession {
  final DateTime start;
  final int focusMinutes;   // фактически отработанные минуты фокуса
  final int breakMinutes;   // минуты перерывов
  final bool completed;     // дошёл до конца фокус-цикла
  final int distractions;   // отмеченные отвлечения

  PomodoroSession({
    required this.start,
    required this.focusMinutes,
    required this.breakMinutes,
    required this.completed,
    required this.distractions,
  });

  Map<String, dynamic> toMap() => {
    'start': start.toIso8601String(),
    'focusMinutes': focusMinutes,
    'breakMinutes': breakMinutes,
    'completed': completed,
    'distractions': distractions,
  };

  static PomodoroSession fromMap(Map map) => PomodoroSession(
    start: DateTime.parse(map['start'] as String),
    focusMinutes: map['focusMinutes'] as int,
    breakMinutes: map['breakMinutes'] as int,
    completed: map['completed'] as bool,
    distractions: map['distractions'] as int,
  );
}
