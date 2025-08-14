import 'package:hive/hive.dart';
import '../models/pomodoro_session.dart';

class PomodoroRepository {
  static const _boxName = 'pomodoro_sessions';

  Future<Box> _box() async => await Hive.openBox(_boxName);

  Future<void> add(PomodoroSession s) async {
    final b = await _box();
    await b.add(s.toMap());
  }

  Future<List<PomodoroSession>> all() async {
    final b = await _box();
    return b.values
        .cast<Map>()
        .map((e) => PomodoroSession.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Сессии за конкретный день (локальная дата)
  Future<List<PomodoroSession>> forDay(DateTime day) async {
    final allS = await all();
    return allS.where((s) =>
      s.start.year == day.year &&
      s.start.month == day.month &&
      s.start.day == day.day).toList();
  }

Future<int> totalFocusMinutesForDay(DateTime day) async {
  final list = await forDay(day);
  return list.fold<int>(0, (a, s) => a + s.focusMinutes);
}

Future<int> totalDistractionsForDay(DateTime day) async {
  final list = await forDay(day);
  return list.fold<int>(0, (a, s) => a + s.distractions);
}

  Future<double> completionRateLast7Days() async {
    final list = await all();
    final since = DateTime.now().subtract(const Duration(days: 7));
    final recent = list.where((s) => s.start.isAfter(since)).toList();
    if (recent.isEmpty) return 0;
    final done = recent.where((s) => s.completed).length;
    return done / recent.length;
  }
}
