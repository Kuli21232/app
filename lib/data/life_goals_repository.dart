import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/life_goal.dart';

/// Провайдер репозитория долгих целей
final lifeGoalsRepoProvider =
    ChangeNotifierProvider((ref) => LifeGoalsRepository());

class LifeGoalsRepository extends ChangeNotifier {
  static const _boxName = 'life_goals_v1';
  static const _key = 'items'; // в боксе лежит одна строка JSON со всем списком

  final List<LifeGoal> _items = [];
  UnmodifiableListView<LifeGoal> get items => UnmodifiableListView(_items);

  StreamSubscription? _hiveSub;

  LifeGoalsRepository() {
    _load();
    _subscribeBox(); // слушаем изменения, которые кладёт SyncService
  }

  /* ========================= Hive helpers ========================= */

  Future<Box> _box() async => Hive.openBox(_boxName);

  Future<void> _load() async {
    final box = await _box();
    final raw = box.get(_key);
    _items.clear();
    if (raw is String && raw.isNotEmpty) {
      try {
        _items.addAll(LifeGoal.decodeList(raw));
      } catch (e) {
        if (kDebugMode) {
          print('[LifeGoalsRepo] decode error: $e');
        }
      }
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final box = await _box();
    await box.put(_key, LifeGoal.encodeList(_items));
  }

  Future<void> _subscribeBox() async {
    final box = await _box();
    _hiveSub?.cancel();
    _hiveSub = box.watch(key: _key).listen((event) {
      // Это сработает как при приходе из облака, так и при локальном put.
      if (event.deleted == true) {
        _items.clear();
        notifyListeners();
        return;
      }
      final val = event.value;
      if (val is String) {
        try {
          final list = LifeGoal.decodeList(val);
          _items
            ..clear()
            ..addAll(list);
          notifyListeners();
        } catch (e) {
          if (kDebugMode) {
            print('[LifeGoalsRepo] watch decode error: $e');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _hiveSub?.cancel();
    super.dispose();
  }

  /* =========================== CRUD ============================== */

  /// Получить цель по id
  LifeGoal? getById(String id) {
    try {
      return _items.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(LifeGoal goal) async {
    _items.add(goal);
    await _save();
    notifyListeners();
  }

  Future<void> update(LifeGoal goal) async {
    final i = _items.indexWhere((g) => g.id == goal.id);
    if (i >= 0) {
      _items[i] = goal;
      await _save();
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    _items.removeWhere((g) => g.id == id);
    await _save();
    notifyListeners();
  }

  /* ========================= Бизнес-логика ======================== */

  /// Накопить: добавить взнос
  Future<void> addContribution(String id, double amount) async {
    final g = _items.firstWhere((e) => e.id == id);
    final s = g.savings!;
    s.contributions.add(Contribution(date: DateTime.now(), amount: amount));
    await update(
      g.copyWith(
        savings: SavingsData(
          targetAmount: s.targetAmount,
          weeklyIncome: s.weeklyIncome,
          contributions: s.contributions,
        ),
      ),
    );
  }

  /// Привычка / Спорт: отметить «Готово сегодня» (увеличивает серию, если сегодня ещё не отмечено)
  Future<void> markTodayDone(String id) async {
    final g = _items.firstWhere((e) => e.id == id);
    final today = DateTime.now();

    bool sameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    if (g.habit != null) {
      final h = g.habit!;
      if (h.lastDone == null || !sameDay(h.lastDone!, today)) {
        h.streak += 1;
        h.lastDone = today;
      }
      await update(
        g.copyWith(
          habit: HabitData(
            kind: h.kind,
            stages: h.stages,        // у HabitData этапная структура
            streak: h.streak,
            lastDone: h.lastDone,
            quitAchieved: h.quitAchieved,
          ),
        ),
      );
    } else if (g.sport != null) {
      final s = g.sport!;
      if (s.lastDone == null || !sameDay(s.lastDone!, today)) {
        s.streak += 1;
        s.lastDone = today;
      }
      await update(
        g.copyWith(
          sport: SportData(
            kind: s.kind,
            dailyTasks: s.dailyTasks,
            streak: s.streak,
            lastDone: s.lastDone,
          ),
        ),
      );
    }
  }
}
