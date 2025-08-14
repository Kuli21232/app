import 'dart:convert';

/* =================== Типы целей =================== */

enum LifeGoalType { savings, habit, sport }

extension LifeGoalTypeX on LifeGoalType {
  String get emoji => switch (this) {
        LifeGoalType.savings => '💰',
        LifeGoalType.habit => '🚫',
        LifeGoalType.sport => '🏃',
      };
}

/* =================== Накопить =================== */

class Contribution {
  final DateTime date;
  final double amount;
  Contribution({required this.date, required this.amount});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'amount': amount,
      };

  factory Contribution.fromJson(Map<String, dynamic> j) => Contribution(
        date: DateTime.parse(j['date']),
        amount: (j['amount'] as num).toDouble(),
      );
}

class SavingsData {
  final double targetAmount;
  final double weeklyIncome;
  final List<Contribution> contributions;
  SavingsData({
    required this.targetAmount,
    required this.weeklyIncome,
    List<Contribution>? contributions,
  }) : contributions = contributions ?? [];

  double get saved => contributions.fold(0.0, (s, c) => s + c.amount);
  double get progress =>
      targetAmount <= 0 ? 0 : (saved / targetAmount).clamp(0, 1);

  Map<String, dynamic> toJson() => {
        'targetAmount': targetAmount,
        'weeklyIncome': weeklyIncome,
        'contributions': contributions.map((e) => e.toJson()).toList(),
      };

  factory SavingsData.fromJson(Map<String, dynamic> j) => SavingsData(
        targetAmount: (j['targetAmount'] as num).toDouble(),
        weeklyIncome: (j['weeklyIncome'] as num).toDouble(),
        contributions: (j['contributions'] as List? ?? [])
            .map((e) =>
                Contribution.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

/* =================== Привычка: этапы =================== */

enum HabitKind {
  smoking,
  alcohol,
  sugar,
  junkFood,
  socialMedia,
  gaming,
  other,
}

class HabitStage {
  final String id;
  final String title;
  final int days; // длина этапа
  final List<String> tasks; // чеклист этапа

  HabitStage({
    required this.id,
    required this.title,
    required this.days,
    required this.tasks,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'days': days,
        'tasks': tasks,
      };

  factory HabitStage.fromJson(Map<String, dynamic> j) => HabitStage(
        id: j['id'],
        title: j['title'],
        days: (j['days'] as num).toInt(),
        tasks: (j['tasks'] as List).cast<String>(),
      );
}

class HabitData {
  final HabitKind kind;
  final List<HabitStage> stages;
  int streak; // общий счёт завершённых дней по привычке
  DateTime? lastDone;
  bool quitAchieved; // «да, бросил»

  HabitData({
    required this.kind,
    required this.stages,
    this.streak = 0,
    this.lastDone,
    this.quitAchieved = false,
  });

  int get totalDays => stages.fold(0, (s, e) => s + e.days);

  int get currentStageIndex {
    if (streak <= 0) return 0;
    int acc = 0;
    for (int i = 0; i < stages.length; i++) {
      acc += stages[i].days;
      if (streak <= acc) return i;
    }
    return stages.length - 1;
  }

  int get daysBeforeCurrent {
    int acc = 0;
    for (int i = 0; i < currentStageIndex; i++) {
      acc += stages[i].days;
    }
    return acc;
  }

  HabitStage get currentStage => stages[currentStageIndex];

  int get dayInCurrent {
    final d = streak - daysBeforeCurrent;
    if (d <= 0) return 0;
    return d.clamp(0, currentStage.days);
  }

  bool get finished => quitAchieved || streak >= totalDays;

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'stages': stages.map((e) => e.toJson()).toList(),
        'streak': streak,
        'lastDone': lastDone?.toIso8601String(),
        'quitAchieved': quitAchieved,
      };

  factory HabitData.fromJson(Map<String, dynamic> j) {
    // обратная совместимость: если старое поле dailyTasks — делаем 1 этап на 7 дней
    if (j['stages'] == null && j['dailyTasks'] != null) {
      final tasks = (j['dailyTasks'] as List).cast<String>();
      return HabitData(
        kind: HabitKind.values.byName(j['kind']),
        stages: [
          HabitStage(
            id: 's1',
            title: 'Stage 1',
            days: 7,
            tasks: tasks,
          ),
        ],
        streak: (j['streak'] ?? 0) as int,
        lastDone:
            j['lastDone'] == null ? null : DateTime.parse(j['lastDone']),
        quitAchieved: (j['quitAchieved'] ?? false) as bool,
      );
    }

    return HabitData(
      kind: HabitKind.values.byName(j['kind']),
      stages: (j['stages'] as List)
          .map((e) => HabitStage.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      streak: (j['streak'] ?? 0) as int,
      lastDone: j['lastDone'] == null ? null : DateTime.parse(j['lastDone']),
      quitAchieved: (j['quitAchieved'] ?? false) as bool,
    );
  }
}

/* =================== Спорт (без этапов) =================== */

enum SportKind { running, gym, yoga, swimming, cycling, other }

class SportData {
  final SportKind kind;
  final List<String> dailyTasks;
  int streak;
  DateTime? lastDone;

  SportData({
    required this.kind,
    required this.dailyTasks,
    this.streak = 0,
    this.lastDone,
  });

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'dailyTasks': dailyTasks,
        'streak': streak,
        'lastDone': lastDone?.toIso8601String(),
      };

  factory SportData.fromJson(Map<String, dynamic> j) => SportData(
        kind: SportKind.values.byName(j['kind']),
        dailyTasks: (j['dailyTasks'] as List).cast<String>(),
        streak: (j['streak'] ?? 0) as int,
        lastDone: j['lastDone'] == null ? null : DateTime.parse(j['lastDone']),
      );
}

/* =================== Корневая модель цели =================== */

class LifeGoal {
  final String id;
  final LifeGoalType type;
  final String title;
  final String? photoUrl;
  final DateTime createdAt;

  final SavingsData? savings;
  final HabitData? habit;
  final SportData? sport;

  const LifeGoal({
    required this.id,
    required this.type,
    required this.title,
    this.photoUrl,
    required this.createdAt,
    this.savings,
    this.habit,
    this.sport,
  });

  double get overallProgress => switch (type) {
        LifeGoalType.savings => savings?.progress ?? 0,
        LifeGoalType.habit =>
          (habit == null || habit!.totalDays == 0)
              ? 0
              : (habit!.streak / habit!.totalDays).clamp(0, 1),
        LifeGoalType.sport => (sport?.streak ?? 0) / 30.0,
      };

  LifeGoal copyWith({
    String? id,
    LifeGoalType? type,
    String? title,
    String? photoUrl,
    DateTime? createdAt,
    SavingsData? savings,
    HabitData? habit,
    SportData? sport,
  }) =>
      LifeGoal(
        id: id ?? this.id,
        type: type ?? this.type,
        title: title ?? this.title,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt ?? this.createdAt,
        savings: savings ?? this.savings,
        habit: habit ?? this.habit,
        sport: sport ?? this.sport,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'photoUrl': photoUrl,
        'createdAt': createdAt.toIso8601String(),
        'savings': savings?.toJson(),
        'habit': habit?.toJson(),
        'sport': sport?.toJson(),
      };

  factory LifeGoal.fromJson(Map<String, dynamic> j) => LifeGoal(
        id: j['id'],
        type: LifeGoalType.values.byName(j['type']),
        title: j['title'],
        photoUrl: j['photoUrl'],
        createdAt: DateTime.parse(j['createdAt']),
        savings: j['savings'] == null
            ? null
            : SavingsData.fromJson(
                Map<String, dynamic>.from(j['savings'])),
        habit: j['habit'] == null
            ? null
            : HabitData.fromJson(
                Map<String, dynamic>.from(j['habit'])),
        sport: j['sport'] == null
            ? null
            : SportData.fromJson(
                Map<String, dynamic>.from(j['sport'])),
      );

  static String encodeList(List<LifeGoal> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<LifeGoal> decodeList(String raw) =>
      (jsonDecode(raw) as List)
          .map((e) => LifeGoal.fromJson(Map<String, dynamic>.from(e)))
          .toList();
}
