import 'dart:math';
import 'package:motivego/l10n/app_localizations.dart';

/// ===== Пороговые значения/константы =====
const kAvgPlannedHigh = 10;   // высокий средний план на день
const kMaxPlannedDay  = 15;   // перегрузка за день
const kTotalPlannedHigh = 40; // перегруз за неделю

const kLowCompletion = 0.35;
const kMidCompletion = 0.70;
const kTrendEps = 0.05;

/// ===== Утилиты локализации с безопасными RU/EN фолбэками =====
class _L {
  final AppLocalizations t;
  final String lang; // 'ru' | 'en'
  _L(this.t) : lang = _langOf(t);

  static String _langOf(AppLocalizations t) {
    try {
      final ln = (t as dynamic).localeName as String?;
      if (ln != null && ln.toLowerCase().startsWith('ru')) return 'ru';
    } catch (_) {}
    return 'en';
  }

  String tr({required String ru, required String en}) => lang == 'ru' ? ru : en;

  // ---- Pomodoro short tips ----
  String get pomoTipStart => _safe(() => (t as dynamic).pomoTipStart,
      tr(ru: 'Начни с одного полного цикла 25/5. Маленькая победа = импульс.',
         en: 'Start with one full 25/5 cycle. Small win = best momentum.'));
  String get pomoTipGoodPace => _safe(() => (t as dynamic).pomoTipGoodPace,
      tr(ru: 'Хороший темп. Сделай 3–4 цикла подряд, затем длинный перерыв 15–20 мин.',
         en: 'Good pace. Try 3–4 cycles in a row, then a 15–20 min long break.'));
  String get pomoTipGreat => _safe(() => (t as dynamic).pomoTipGreat,
      tr(ru: 'Отличная концентрация! Зафиксируй, что сработало, и повтори завтра в то же время.',
         en: 'Great focus! Capture what worked and repeat tomorrow at the same time.'));
  String get pomoTipTooManyDistr => _safe(() => (t as dynamic).pomoTipTooManyDistr,
      tr(ru: 'Слишком много отвлечений: включи «Не беспокоить», убери телефон, сядь у окна.',
         en: 'Too many distractions: enable Do Not Disturb, put the phone away, work by a window.'));
  String get pomoTipRaiseCompletion => _safe(() => (t as dynamic).pomoTipRaiseCompletion,
      tr(ru: 'Доведи сегодня хотя бы 2 цикла до конца — это поднимет 7-дневную метрику.',
         en: 'Finish at least 2 cycles today to lift your 7-day completion rate.'));
  String get pomoTipIncreaseInterval => _safe(() => (t as dynamic).pomoTipIncreaseInterval,
      tr(ru: 'Высокая стабильность! Попробуй увеличить фокус-интервал до 30 минут.',
         en: 'High consistency! Consider increasing the focus interval to 30 minutes.'));

  // ---- Coach titles/bodies (минимальный набор для советов ниже) ----
  // Перегруз по объёму
  List<String> get coachOverloadTitles => [
    _safe(() => (t as dynamic).coachOverloadTitleA,
      tr(ru: 'План перегружен', en: 'Your plan is overloaded')),
    _safe(() => (t as dynamic).coachOverloadTitleB,
      tr(ru: 'Сбавь обороты', en: 'Ease the throttle')),
    _safe(() => (t as dynamic).coachOverloadTitleC,
      tr(ru: 'Слишком много на неделю', en: 'Too much for this week')),
  ];
  List<String> get coachOverloadBodies => [
    _safe(() => (t as dynamic).coachOverloadBodyA,
      tr(ru: 'Сократи план на 15–25% и оставь зазор под непредвиденное.',
         en: 'Trim your plan by 15–25% and leave buffer for the unexpected.')),
    _safe(() => (t as dynamic).coachOverloadBodyB,
      tr(ru: 'Сконцентрируйся на 3–5 ключевых задачах. Остальное позже.',
         en: 'Focus on 3–5 key tasks. Defer the rest.')),
    _safe(() => (t as dynamic).coachOverloadBodyC,
      tr(ru: 'Выбери одну большую цель недели и «протолкни» её первой.',
         en: 'Pick one weekly flagship goal and push it first.')),
  ];

  String get coachLowCompletionTitle => _safe(() => (t as dynamic).coachLowCompletionTitle,
      tr(ru: 'Недовыполнение', en: 'Low completion'));
  String get coachLowCompletionBody => _safe(() => (t as dynamic).coachLowCompletionBody,
      tr(ru: 'Сократи дневной план и закрой 1–2 задачи приоритета P1 сегодня.',
         en: 'Cut your daily plan and close 1–2 P1 tasks today.'));

  String get coachMidCompletionTitle => _safe(() => (t as dynamic).coachMidCompletionTitle,
      tr(ru: 'Есть прогресс', en: 'Progress is there'));
  String get coachMidCompletionBody => _safe(() => (t as dynamic).coachMidCompletionBody,
      tr(ru: 'Чуть меньше распыления: утром P1, днём P2, вечером короткие P3.',
         en: 'Reduce fragmentation: P1 in the morning, P2 midday, short P3 in the evening.'));

  String get coachGreatPaceTitle => _safe(() => (t as dynamic).coachGreatPaceTitle,
      tr(ru: 'Отличный темп', en: 'Great pace'));
  String get coachGreatPaceBody => _safe(() => (t as dynamic).coachGreatPaceBody,
      tr(ru: 'Зафиксируй рутину и попробуй чуть увеличить сложность.',
         en: 'Lock in your routine and nudge difficulty up slightly.'));

  String get coachWeakP3Title => _safe(() => (t as dynamic).coachWeakP3Title,
      tr(ru: 'Хвосты по P3', en: 'Lagging on P3'));
  String get coachWeakP3Body => _safe(() => (t as dynamic).coachWeakP3Body,
      tr(ru: 'Ограничь P3 одной задачей в день или перенеси их на выходные.',
         en: 'Limit P3 to one per day or move them to the weekend.'));

  String get coachNoP3Title => _safe(() => (t as dynamic).coachNoP3Title,
      tr(ru: 'Нет лёгких задач', en: 'No light tasks'));
  String get coachNoP3Body => _safe(() => (t as dynamic).coachNoP3Body,
      tr(ru: 'Добавь лёгкие задачи для разогрева и быстрого допамина.',
         en: 'Add a few light tasks for warm-up and quick wins.'));

  String get coachP1StuckTitle => _safe(() => (t as dynamic).coachP1StuckTitle,
      tr(ru: 'Застревание в P1', en: 'Stuck on P1'));
  String get coachP1StuckBody => _safe(() => (t as dynamic).coachP1StuckBody,
      tr(ru: 'Разбей крупную P1 на 3 шага и начинай день с первого.',
         en: 'Split big P1 into 3 steps and start your day with the first.'));

  String get coachPrioritySkewTitle => _safe(() => (t as dynamic).coachPrioritySkewTitle,
      tr(ru: 'Дисбаланс приоритетов', en: 'Priority imbalance'));
  String get coachPrioritySkewBody => _safe(() => (t as dynamic).coachPrioritySkewBody,
      tr(ru: 'Выравнивай доли P1–P3 по плану и по факту.',
         en: 'Align P1–P3 shares in plan vs. actual.'));

  String get coachGoodBalanceTitle => _safe(() => (t as dynamic).coachGoodBalanceTitle,
      tr(ru: 'Качественный баланс', en: 'Solid balance'));
  String get coachGoodBalanceBody => _safe(() => (t as dynamic).coachGoodBalanceBody,
      tr(ru: 'Сохраняй распределение и закрепляй привычку в одно и то же время.',
         en: 'Keep this distribution and stabilize at the same daily time.'));

  String get coachTrendDownTitle => _safe(() => (t as dynamic).coachTrendDownTitle,
      tr(ru: 'Нисходящий тренд', en: 'Downward trend'));
  String get coachTrendDownBody => _safe(() => (t as dynamic).coachTrendDownBody,
      tr(ru: 'Сократи план и добавь день восстановления.',
         en: 'Reduce scope and add a recovery day.'));

  String get coachTrendUpTitle => _safe(() => (t as dynamic).coachTrendUpTitle,
      tr(ru: 'Восходящий тренд', en: 'Upward trend'));
  String get coachTrendUpBody => _safe(() => (t as dynamic).coachTrendUpBody,
      tr(ru: 'Подними сложность одной-двух задач на 10–15%.',
         en: 'Increase difficulty of 1–2 tasks by 10–15%.'));

  String get coachCareTitle => _safe(() => (t as dynamic).coachCareTitle,
      tr(ru: 'Забота о себе', en: 'Self-care'));
  String get coachCareBody => _safe(() => (t as dynamic).coachCareBody,
      tr(ru: 'Сон, вода, прогулка 20 мин. Сегодня — мягкий режим.',
         en: 'Sleep, water, 20-min walk. Keep today gentle.'));

  String get coachUsePeakTitle => _safe(() => (t as dynamic).coachUsePeakTitle,
      tr(ru: 'Используй пик', en: 'Use the peak'));
  String get coachUsePeakBody => _safe(() => (t as dynamic).coachUsePeakBody,
      tr(ru: 'Закрой одну P1 на потоке, пока энергия высока.',
         en: 'Close one P1 while energy is high.'));

  String coachStreakTitle(int streak) => _safe(
    () => (t as dynamic).coachStreakTitle(streak),
    tr(ru: 'Серия: $streak дн.', en: 'Streak: $streak days'),
  );
  String get coachStreakBody => _safe(() => (t as dynamic).coachStreakBody,
      tr(ru: 'Отметь рутину и сделай мини-ритуал старта.',
         en: 'Mark the routine and keep a tiny start ritual.'));
  String get coachNeedStartTitle => _safe(() => (t as dynamic).coachNeedStartTitle,
      tr(ru: 'Нужен разгон', en: 'Need ignition'));
  String get coachNeedStartBody => _safe(() => (t as dynamic).coachNeedStartBody,
      tr(ru: 'Начни с 10 минут и одной самой простой задачи.',
         en: 'Start with 10 minutes and one easiest task.'));

  // ---- Motivation phrases ----
  List<String> get motPhrases => [
    _safe(() => (t as dynamic).motPhrase1,  tr(ru: 'Малые шаги дают большие результаты.', en: 'Small steps — big results.')),
    _safe(() => (t as dynamic).motPhrase2,  tr(ru: 'Делай важное, а не срочное.',       en: 'Do what matters, not what’s urgent.')),
    _safe(() => (t as dynamic).motPhrase3,  tr(ru: 'Прогресс — это галочки, а не идеал.', en: 'Progress is checkmarks, not perfection.')),
    _safe(() => (t as dynamic).motPhrase4,  tr(ru: 'Лучший день начать — сегодня.',       en: 'The best day to start is today.')),
    _safe(() => (t as dynamic).motPhrase5,  tr(ru: '25 минут фокуса творят чудеса.',      en: '25 minutes of focus works wonders.')),
    _safe(() => (t as dynamic).motPhrase6,  tr(ru: 'Отдых — часть работы.',               en: 'Rest is part of the work.')),
    _safe(() => (t as dynamic).motPhrase7,  tr(ru: 'Сделай одно сложное до обеда.',       en: 'Do one hard thing before lunch.')),
    _safe(() => (t as dynamic).motPhrase8,  tr(ru: 'Не сразу, но каждый день понемногу.', en: 'Not all at once, but every day a little.')),
    _safe(() => (t as dynamic).motPhrase9,  tr(ru: 'Будь стабильным, а не идеальным.',    en: 'Be consistent, not perfect.')),
    _safe(() => (t as dynamic).motPhrase10, tr(ru: 'Сомневаешься? Начни с 10 минут.',     en: 'In doubt? Start with 10 minutes.')),
  ];
}

/// ==== Модель «пункта совета» ====
class AdvicePoint {
  final String title;
  final String body;
  const AdvicePoint(this.title, this.body);
}

/// ==== Короткие советы по Помодоро ====
class AiCoach {
  AiCoach._();
  static final instance = AiCoach._();

  Future<String> pomodoroAdvice({
    required AppLocalizations t,
    required int focusMinutesToday,
    required double completionRate7d,
    required int distractionsToday,
  }) async {
    final L = _L(t);
    final tips = <String>[];

    if (focusMinutesToday < 25) {
      tips.add(L.pomoTipStart);
    } else if (focusMinutesToday < 100) {
      tips.add(L.pomoTipGoodPace);
    } else {
      tips.add(L.pomoTipGreat);
    }

    if (distractionsToday > 3) {
      tips.add(L.pomoTipTooManyDistr);
    }

    if (completionRate7d < 0.4) {
      tips.add(L.pomoTipRaiseCompletion);
    } else if (completionRate7d > 0.8) {
      tips.add(L.pomoTipIncreaseInterval);
    }

    return tips.join(' ');
  }
}

/// ==== Детальная метрика по приоритету ====
class PriorityMetric {
  final int priority; // 1..3
  final int planned;
  final int done;
  double get completion => planned == 0 ? 0.0 : done / planned;

  const PriorityMetric({
    required this.priority,
    required this.planned,
    required this.done,
  });
}

/// ==== Итоговый отчёт (расширен) ====
class AdviceReport {
  final double completionOverall;     // доля выполненного за неделю
  final int streakDays;               // серия дней с прогрессом
  final double balanceScore;          // 0..1, совпадение плана/факта по приоритетам
  final double trend;                 // нормированный наклон тренда 0..1 (отрицательный/положительный)
  final int happinessAvg;             // 0..100
  final List<PriorityMetric> byPriority;
  final List<AdvicePoint> tips;

  // --- Новые «умные» поля ---
  final double consistency;           // 0..1 (стабильность по дням)
  final double burnoutRisk;           // 0..1 (оценка риска выгорания)
  final int suggestedFocusMin;        // 20/25/30
  final int suggestedDailyPlan;       // рекомендуемое кол-во задач/единиц на день
  final String persona;               // персональный профиль
  final List<String> actionPlan;      // 3–6 шагов на завтра/неделю

  const AdviceReport({
    required this.completionOverall,
    required this.streakDays,
    required this.balanceScore,
    required this.trend,
    required this.happinessAvg,
    required this.byPriority,
    required this.tips,
    required this.consistency,
    required this.burnoutRisk,
    required this.suggestedFocusMin,
    required this.suggestedDailyPlan,
    required this.persona,
    required this.actionPlan,
  });
}

double _clamp01(double v) => max(0, min(1, v));

double _balanceScore(Map<int, (int plan, int fact)> data) {
  final totalPlan = data.values.fold<int>(0, (p, e) => p + e.$1);
  final totalFact = data.values.fold<int>(0, (p, e) => p + e.$2);
  if (totalPlan == 0 || totalFact == 0) return 0.5;

  double diff = 0;
  for (final p in [1, 2, 3]) {
    final tPlan = data[p]?.$1 ?? 0;
    final tFact = data[p]?.$2 ?? 0;
    final pShare = totalPlan == 0 ? 0.0 : tPlan / totalPlan;
    final fShare = totalFact == 0 ? 0.0 : tFact / totalFact;
    diff += (pShare - fShare).abs();
  }
  return _clamp01(1.0 - diff / 2.0);
}

String _pick(List<String> variants, int seed) {
  if (variants.isEmpty) return '';
  final r = Random(seed);
  return variants[r.nextInt(variants.length)];
}

/// Безопасное получение локализованной строки через dynamic.
/// Если геттера нет (ещё не сгенерирован), возвращаем фолбэк.
String _safe(String Function() getter, String fallback) {
  try {
    final v = getter();
    if (v.isNotEmpty) return v;
  } catch (_) {}
  return fallback;
}

double _stdDev(List<int> xs) {
  if (xs.isEmpty) return 0;
  final mean = xs.reduce((a, b) => a + b) / xs.length;
  final varSum = xs.fold<double>(0, (p, x) => p + pow(x - mean, 2));
  return sqrt(varSum / xs.length);
}

int _suggestFocus(double completion, double slope, int happiness) {
  if (completion > 0.8 && slope > kTrendEps && happiness >= 60) return 30;
  if (completion < 0.5 || happiness < 45) return 20;
  return 25;
}

/// ==== Главная функция генерации советов ====
AdviceReport makeAdvice({
  required AppLocalizations t,
  required List<(int planned, int done)> weekly,      // 7 значений
  required List<int> happiness,                       // 0..100
  required Map<int, (int plan, int fact)> priority7,  // {1,2,3}
  required List<int> doneByDay,                       // факты по дням
  int seed = 42,
}) {
  final L = _L(t);

  final totalPlanned = weekly.fold<int>(0, (p, e) => p + e.$1);
  final totalDone    = weekly.fold<int>(0, (p, e) => p + e.$2);
  final completionOverall = totalPlanned == 0 ? 0.0 : totalDone / totalPlanned;

  final plannedByDay = weekly.map((e) => e.$1).toList();
  final avgPlannedPerDay = plannedByDay.isEmpty
      ? 0.0
      : plannedByDay.reduce((a, b) => a + b) / plannedByDay.length;
  final maxPlannedDay = plannedByDay.isEmpty
      ? 0
      : plannedByDay.reduce((a, b) => a > b ? a : b);

  final isOverloadedByCount =
      avgPlannedPerDay >= kAvgPlannedHigh ||
      maxPlannedDay   >= kMaxPlannedDay  ||
      totalPlanned    >= kTotalPlannedHigh;

  // Тренд (линейная регрессия по doneByDay)
  double slope = 0;
  if (doneByDay.length >= 2) {
    final n = doneByDay.length;
    final xs = List.generate(n, (i) => i.toDouble());
    final y  = doneByDay.map((e) => e.toDouble()).toList();
    final xMean = (n - 1) / 2.0;
    final yMean = y.reduce((a, b) => a + b) / n;
    double num = 0, den = 0;
    for (var i = 0; i < n; i++) {
      final dx = xs[i] - xMean;
      num += dx * (y[i] - yMean);
      den += dx * dx;
    }
    slope = den == 0 ? 0 : num / den;
    final scale = (y.reduce(max) + 1);
    slope = (slope / scale).clamp(-1.0, 1.0);
  }

  final happinessAvg =
      happiness.isEmpty ? 50 : (happiness.reduce((a, b) => a + b) / happiness.length).round();

  final balance = _balanceScore(priority7);

  // Серия
  int streak = 0;
  for (var i = doneByDay.length - 1; i >= 0; i--) {
    if (doneByDay[i] > 0) {
      streak++;
    } else {
      break;
    }
  }

  // Консистентность 0..1 (по вариативности факта)
  final sd = _stdDev(doneByDay);
  final meanDone = doneByDay.isEmpty
      ? 0.0
      : doneByDay.reduce((a, b) => a + b) / doneByDay.length;
  final consistency = _clamp01(meanDone == 0 ? 0 : 1 - (sd / (meanDone + 1e-6)));

  // Риск выгорания (перегруз + низкое настроение + нисходящий тренд)
  final overloadFrac = totalPlanned == 0 ? 0.0 : max(0, totalPlanned - totalDone) / max(1, totalPlanned);
  final trendNeg = ((-slope) + 1) / 2; // 0..1 (хуже — больше)
  final burnoutRisk = _clamp01(0.45 * overloadFrac + 0.35 * (1 - happinessAvg / 100) + 0.20 * trendNeg);

  // Рекомендуемый фокус-интервал и дневной план
  final focusMin = _suggestFocus(completionOverall, slope, happinessAvg);
  int recommendedDailyPlan = avgPlannedPerDay.round();
  if (completionOverall < 0.5) {
    recommendedDailyPlan = max(3, (avgPlannedPerDay * 0.7).round());
  } else if (completionOverall > 0.85) {
    recommendedDailyPlan = min(kMaxPlannedDay, (avgPlannedPerDay * 1.10).round());
  }

  // Персона
  final String persona = (() {
    if (isOverloadedByCount && completionOverall < 0.6) {
      return L.tr(ru: 'Сверхпланировщик', en: 'Overplanner');
    } else if (balance > 0.8 && completionOverall >= 0.7) {
      return L.tr(ru: 'Сбалансированный достигатор', en: 'Balanced Achiever');
    } else if (slope < -kTrendEps && happinessAvg < 50) {
      return L.tr(ru: 'Усталый восстановитель', en: 'Fatigued Recoverer');
    } else {
      return L.tr(ru: 'Устойчивый строитель', en: 'Steady Builder');
    }
  })();

  // Метрики по приоритетам
  final byPriority = <PriorityMetric>[
    for (final p in [1, 2, 3])
      PriorityMetric(
        priority: p,
        planned: priority7[p]?.$1 ?? 0,
        done:    priority7[p]?.$2 ?? 0,
      ),
  ];
  final p1 = byPriority.firstWhere((e) => e.priority == 1);
  final p2 = byPriority.firstWhere((e) => e.priority == 2);
  final p3 = byPriority.firstWhere((e) => e.priority == 3);

  // ---- Советы (tips) ----
  final tips = <AdvicePoint>[];

  // 1) Объём/выполнение
  if (isOverloadedByCount) {
    tips.add(AdvicePoint(
      _pick(L.coachOverloadTitles, seed),
      _pick(L.coachOverloadBodies, seed + 1),
    ));
  } else if (completionOverall < kLowCompletion) {
    tips.add(AdvicePoint(L.coachLowCompletionTitle, L.coachLowCompletionBody));
  } else if (completionOverall < kMidCompletion) {
    tips.add(AdvicePoint(L.coachMidCompletionTitle, L.coachMidCompletionBody));
  } else {
    tips.add(AdvicePoint(L.coachGreatPaceTitle, L.coachGreatPaceBody));
  }

  // 2) Приоритеты
  if (p3.planned > 0 && p3.completion < 0.5) {
    tips.add(AdvicePoint(L.coachWeakP3Title, L.coachWeakP3Body));
  } else if (p3.planned == 0 && (p2.planned + p1.planned) > 4) {
    tips.add(AdvicePoint(L.coachNoP3Title, L.coachNoP3Body));
  }
  if (p1.planned >= 3 && p1.completion < 0.5) {
    tips.add(AdvicePoint(L.coachP1StuckTitle, L.coachP1StuckBody));
  }

  // 3) Баланс
  if (balance < 0.45) {
    tips.add(AdvicePoint(L.coachPrioritySkewTitle, L.coachPrioritySkewBody));
  } else if (balance > 0.8 && completionOverall >= 0.6) {
    tips.add(AdvicePoint(L.coachGoodBalanceTitle, L.coachGoodBalanceBody));
  }

  // 4) Тренд
  if (slope < -kTrendEps) {
    tips.add(AdvicePoint(L.coachTrendDownTitle, L.coachTrendDownBody));
  } else if (slope > kTrendEps) {
    tips.add(AdvicePoint(L.coachTrendUpTitle, L.coachTrendUpBody));
  }

  // 5) Настроение/энергия
  if (happinessAvg < 40) {
    tips.add(AdvicePoint(L.coachCareTitle, L.coachCareBody));
  } else if (happinessAvg > 70) {
    tips.add(AdvicePoint(L.coachUsePeakTitle, L.coachUsePeakBody));
  }

  // 6) Серия
  tips.addAll([
    if (streak >= 3)
      AdvicePoint(L.coachStreakTitle(streak), L.coachStreakBody)
    else if (streak == 0 && totalDone == 0)
      AdvicePoint(L.coachNeedStartTitle, L.coachNeedStartBody),
  ]);

  // Уникализация советов
  final seen = <String>{};
  final uniqueTips = <AdvicePoint>[];
  for (final tip in tips) {
    final key = '${tip.title}|${tip.body}';
    if (seen.add(key)) uniqueTips.add(tip);
  }

  // ---- Action plan (шаги) ----
  final deltaPct = avgPlannedPerDay == 0
      ? 0
      : (((recommendedDailyPlan - avgPlannedPerDay) / max(1, avgPlannedPerDay)) * 100).round();
  final actionPlan = <String>[
    if (deltaPct < 0)
      L.tr(
        ru: 'На завтра запланируй ≤ $recommendedDailyPlan задач (−${deltaPct.abs()}% от среднего).',
        en: 'For tomorrow, plan ≤ $recommendedDailyPlan tasks ($deltaPct% vs. your average).',
      )
    else if (deltaPct > 0)
      L.tr(
        ru: 'Можно слегка повысить нагрузку: до $recommendedDailyPlan задач (+$deltaPct% от среднего).',
        en: 'You can nudge the load to $recommendedDailyPlan tasks (+$deltaPct% vs. average).',
      )
    else
      L.tr(
        ru: 'Сохрани текущий дневной объём: около $recommendedDailyPlan задач.',
        en: 'Keep your current daily load: about $recommendedDailyPlan tasks.',
      ),
    L.tr(
      ru: 'Работай интервалами по $focusMin минут с перерывами по 5 минут.',
      en: 'Use $focusMin-minute focus intervals with 5-minute breaks.',
    ),
    L.tr(
      ru: 'Начни день с одной задачи приоритета P1 и закрой её до полудня.',
      en: 'Start the day with one P1 task and close it before noon.',
    ),
    if (burnoutRisk > 0.6)
      L.tr(
        ru: 'Снизь недельный план на 15–25% и запланируй 1 длинный отдых.',
        en: 'Reduce weekly scope by 15–25% and schedule one long recovery block.',
      ),
    if (p3.planned > 0 && p3.completion < 0.5)
      L.tr(
        ru: 'Ограничь P3: не более одной в день или перенеси их на выходные.',
        en: 'Cap P3 at one per day or shift them to the weekend.',
      ),
    if (streak >= 5)
      L.tr(
        ru: 'Закрепи рутину: один и тот же старт-ритуал каждый день.',
        en: 'Lock in a start ritual at the same time each day.',
      ),
  ];

  return AdviceReport(
    completionOverall: completionOverall,
    streakDays: streak,
    balanceScore: balance,
    trend: slope,
    happinessAvg: happinessAvg,
    byPriority: byPriority,
    tips: uniqueTips,
    consistency: consistency,
    burnoutRisk: burnoutRisk,
    suggestedFocusMin: focusMin,
    suggestedDailyPlan: recommendedDailyPlan,
    persona: persona,
    actionPlan: actionPlan,
  );
}

/// Локализованные мотивационные фразы (через безопасные RU/EN фолбэки).
List<String> motivationPhrases(AppLocalizations t) => _L(t).motPhrases;
