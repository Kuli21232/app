import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import 'hive_init.dart';

class GoalsRepository {
  final Box _box = Hive.box(Boxes.goals);
  final _uuid = const Uuid();

  List<Goal> goalsForDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return _box.values
        .cast<Map>()
        .map(Goal.fromMap)
        .where((g) {
          final d = DateTime(g.plannedDate.year, g.plannedDate.month, g.plannedDate.day);
          return d == day;
        })
        .toList()
      ..sort((a, b) => (a.isDone ? 1 : 0).compareTo(b.isDone ? 1 : 0));
  }

  /// Все цели в диапазоне [start..end] (включительно) по plannedDate.
  List<Goal> goalsInRange(DateTime start, DateTime end) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return _box.values
        .cast<Map>()
        .map(Goal.fromMap)
        .where((g) {
          final d = DateTime(g.plannedDate.year, g.plannedDate.month, g.plannedDate.day);
          return !d.isBefore(s) && !d.isAfter(e);
        })
        .toList();
  }

  Future<Goal> add({
    required String title,
    String? note,
    int priority = 2,
    required DateTime plannedDate,
  }) async {
    final now = DateTime.now();
    final g = Goal(
      id: _uuid.v4(),
      title: title,
      note: note,
      priority: priority,
      plannedDate: plannedDate,
      createdAt: now,
      doneAt: null,
    );
    await _box.put(g.id, g.toMap());
    return g;
  }

  Future<void> toggleDone(String id) async {
    final m = Map.of(_box.get(id));
    m['doneAt'] = m['doneAt'] == null ? DateTime.now().toIso8601String() : null;
    await _box.put(id, m);
  }

  Future<void> delete(String id) async => _box.delete(id);

  Future<void> moveToDate(String id, DateTime newDate) async {
    final m = Map.of(_box.get(id));
    m['plannedDate'] = DateTime(newDate.year, newDate.month, newDate.day).toIso8601String();
    await _box.put(id, m);
  }

  /// Поко-дневная статистика (за последние 7 дней по умолчанию)
  Map<DateTime, (int planned, int done)> weeklyStats({DateTime? until}) {
    final end = until ?? DateTime.now();
    final start = end.subtract(const Duration(days: 6));

    final map = <DateTime, (int, int)>{};
    for (var i = 0; i < 7; i++) {
      final d = DateTime(start.year, start.month, start.day + i);
      map[d] = (0, 0);
    }

    for (final v in _box.values.cast<Map>()) {
      final g = Goal.fromMap(v);
      final d = DateTime(g.plannedDate.year, g.plannedDate.month, g.plannedDate.day);
      if (d.isBefore(start) || d.isAfter(end)) continue;
      final t = map[d] ?? (0, 0);
      map[d] = (t.$1 + 1, t.$2 + (g.isDone ? 1 : 0));
    }
    return map;
  }

  /// Разбивка по приоритетам за последние 7 дней: map[priority] = (plan, fact)
  Map<int, (int plan, int fact)> weeklyPriorityBreakdown({DateTime? until}) {
    final end = until ?? DateTime.now();
    final start = end.subtract(const Duration(days: 6));

    final res = <int, (int, int)>{1: (0, 0), 2: (0, 0), 3: (0, 0)};
    for (final v in _box.values.cast<Map>()) {
      final g = Goal.fromMap(v);
      final d = DateTime(g.plannedDate.year, g.plannedDate.month, g.plannedDate.day);
      if (d.isBefore(start) || d.isAfter(end)) continue;
      final cur = res[g.priority] ?? (0, 0);
      res[g.priority] = (cur.$1 + 1, cur.$2 + (g.isDone ? 1 : 0));
    }
    return res;
  }
}
