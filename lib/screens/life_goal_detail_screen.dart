import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:motivego/l10n/app_localizations.dart';

import '../data/life_goals_repository.dart';
import '../models/life_goal.dart';

class LifeGoalDetailScreen extends ConsumerWidget {
  final String id;
  const LifeGoalDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final repo = ref.watch(lifeGoalsRepoProvider);
    final g = repo.getById(id);

    if (g == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text(t.notFound)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(g.title),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _HeaderCard(goal: g),               // новый красивый хедер
          const SizedBox(height: 12),
          _GoalCoachCard(goalId: g.id),
          const SizedBox(height: 12),
          switch (g.type) {
            LifeGoalType.savings => _SavingsSection(goalId: g.id),
            LifeGoalType.habit   => _HabitSection(goalId: g.id),
            LifeGoalType.sport   => _SportSection(goalId: g.id),
          },
        ],
      ),
    );
  }
}

/* ===================== HERO-ШАПКА С ПРОГРЕССОМ ===================== */

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.goal});
  final LifeGoal goal;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final s = Theme.of(context).colorScheme;
    final df = NumberFormat.decimalPattern();

    final double pct = goal.overallProgress.clamp(0.0, 1.0).toDouble();
    final pctText = '${(pct * 100).round()}%';

    // чипы под заголовком
    final chips = <Widget>[];
    switch (goal.type) {
      case LifeGoalType.savings:
        final sd = goal.savings!;
        chips.addAll([
          _chip(context, '💰 ${df.format(sd.saved)} / ${df.format(sd.targetAmount)}'),
          _chip(context, '${t.weeklyIncome}: ${df.format(sd.weeklyIncome)}'),
        ]);
        break;
      case LifeGoalType.habit:
        final hd = goal.habit!;
        chips.addAll([
          _chip(context, '🚫 ${t.streakDays(hd.streak)}'),
          _chip(context, '${t.stage1Title.split(" ").first} ${hd.currentStageIndex + 1}/${hd.stages.length}'),
        ]);
        break;
      case LifeGoalType.sport:
        chips.add(_chip(context, '🏃 ${t.streakDays(goal.sport!.streak)}'));
        break;
    }

    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: s.outlineVariant.withOpacity(.35)),
        boxShadow: [
          BoxShadow(
            color: s.primary.withOpacity(.08),
            blurRadius: 24,
            spreadRadius: -6,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ФОН: фото или мягкий градиент
          if (goal.photoUrl != null && goal.photoUrl!.isNotEmpty)
            Image.network(goal.photoUrl!, fit: BoxFit.cover)
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1, -1),
                  end: Alignment(1, 1),
                  colors: [
                    s.primary.withOpacity(.85),
                    s.secondaryContainer.withOpacity(.60),
                  ],
                ),
              ),
            ),
          // ФИОЛЕТОВАЯ Вуаль для читабельности
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(.35),
                  Colors.black.withOpacity(.15),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Контент
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // верхняя строка: эмодзи + тип
                Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(.20)),
                      ),
                      alignment: Alignment.center,
                      child: Text(goal.type.emoji, style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 10),
                    _chipGlass(context, switch (goal.type) {
                      LifeGoalType.savings => t.goalSavings,
                      LifeGoalType.habit   => t.goalHabit,
                      LifeGoalType.sport   => t.goalSport,
                    }),
                    const Spacer(),
                    _chipGlass(context, pctText),
                  ],
                ),
                const Spacer(),
                // Заголовок
                Text(
                  goal.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                // Прогресс
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(.22),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(.95),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      pctText,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: chips),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(.28)),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white)),
    );
  }

  Widget _chipGlass(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.18)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }
}

/* ===================== COACH / AI подсказки ===================== */

class _GoalCoachCard extends ConsumerWidget {
  final String goalId;
  const _GoalCoachCard({required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final s = Theme.of(context).colorScheme;

    final repo = ref.watch(lifeGoalsRepoProvider);
    final g = repo.getById(goalId)!;

    final tips = _makeTipsForGoal(t, g);

    return Container(
      decoration: BoxDecoration(
        color: s.surface.withOpacity(.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: s.outlineVariant.withOpacity(.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.psychology_alt_rounded),
              const SizedBox(width: 10),
              Text(t.coachTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              IconButton(
                tooltip: t.coachRefresh,
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => (context as Element).markNeedsBuild(),
              ),
            ]),
            const SizedBox(height: 8),
            if (tips.isEmpty)
              Text(t.coachNoData, style: Theme.of(context).textTheme.bodySmall)
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tips.take(3).map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  '),
                        Expanded(child: Text(e, style: Theme.of(context).textTheme.bodySmall)),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  List<String> _makeTipsForGoal(AppLocalizations t, LifeGoal g) {
    final tips = <String>[];

    switch (g.type) {
      case LifeGoalType.savings:
        final s = g.savings!;
        final pct = g.overallProgress;
        final left = (s.targetAmount - s.saved).clamp(0, s.targetAmount);
        if (s.weeklyIncome <= 0) tips.add(t.sv_tip_fill_income);
        if (pct < 0.1) tips.add(t.sv_tip_start_auto);
        if (left > 0) {
          final recommended = (s.weeklyIncome * 0.2).clamp(0, left);
          final df = NumberFormat.decimalPattern();
          tips.add(t.sv_tip_small_deposit(df.format(recommended)));
        }
        if (pct >= 0.8) tips.add(t.sv_tip_visualize);
        break;

        case LifeGoalType.habit:
        final h = g.habit!;
        final idx = h.currentStageIndex;
        final stageTips = [
          [t.hb_s1_1, t.hb_s1_2, t.hb_s1_3],
          [t.hb_s2_1, t.hb_s2_2, t.hb_s2_3],
          [t.hb_s3_1, t.hb_s3_2, t.hb_s3_3],
        ];
        tips.addAll(stageTips[idx.clamp(0, stageTips.length - 1)]);
        if (h.quitAchieved) {
          tips..clear()..addAll([t.hb_maintain_1, t.hb_maintain_2, t.hb_maintain_3]);
        } else if (h.streak == 0) {
          tips.add(t.hb_start_small);
        } else if (h.streak < 7) {
          tips.add(t.hb_keep_chain);
        } else {
          tips.add(t.hb_high_streak);
        }
        break;

      case LifeGoalType.sport:
        final s = g.sport!;
        if (s.streak == 0) {
          tips.addAll([t.sp_beginner_1, t.sp_beginner_2]);
        } else if (s.streak < 10) {
          tips.addAll([t.sp_consistency_1, t.sp_consistency_2]);
        } else {
          tips.addAll([t.sp_deload_1, t.sp_deload_2]);
        }
        break;
    }
    return tips;
  }
}

/* ================= Накопить ================= */

class _SavingsSection extends ConsumerWidget {
  final String goalId;
  const _SavingsSection({required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final repo = ref.watch(lifeGoalsRepoProvider);
    final g = repo.getById(goalId)!;
    final s = g.savings!;
    final df = NumberFormat.decimalPattern();
    final double pct = g.overallProgress.clamp(0.0, 1.0).toDouble();

    final recommended =
        (s.weeklyIncome * 0.2).clamp(0, (s.targetAmount - s.saved));

    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя строка: сумма/цель
            Row(
              children: [
                Text(
                  '${df.format(s.saved)} / ${df.format(s.targetAmount)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                _miniPill(context, '${(pct * 100).round()}%'),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(value: pct, minHeight: 10),
            ),
            const SizedBox(height: 12),

            // инфо-чипы
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _pill(context, '${t.weeklyIncome}: ${df.format(s.weeklyIncome)}'),
                _pill(context, t.recommendedWeeklyDeposit(df.format(recommended))),
              ],
            ),

            // последние взносы (без заголовка, чтобы не добавлять новый ключ)
            if (s.contributions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: s.contributions
                    .take(6)
                    .toList()
                    .reversed
                    .map((c) => _pill(
                          context,
                          '${df.format(c.amount)} • ${DateFormat.yMMMd().format(c.date)}',
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 12),

            // действия
            Row(
              children: [
                FilledButton.tonal(
                  onPressed: () async {
                    final v = await _askNumber(context, t.depositAmount);
                    if (v != null && v > 0) {
                      await ref
                          .read(lifeGoalsRepoProvider)
                          .addContribution(goalId, v);
                    }
                  },
                  child: Text(t.deposit),
                ),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: () async {
                    final v = await _askNumber(context, t.weeklyIncome);
                    if (v != null) {
                      final gg = repo.getById(goalId)!;
                      final s0 = gg.savings!;
                      final upd = gg.copyWith(
                        savings: SavingsData(
                          targetAmount: s0.targetAmount,
                          weeklyIncome: v,
                          contributions: s0.contributions,
                        ),
                      );
                      await ref.read(lifeGoalsRepoProvider).update(upd);
                    }
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(t.weeklyIncome),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(.28)),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }

  Widget _miniPill(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(.28)),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

/* ================= Привычка: дорога этапов + чеклист ================= */

class _HabitSection extends ConsumerStatefulWidget {
  final String goalId;
  const _HabitSection({required this.goalId});

  @override
  ConsumerState<_HabitSection> createState() => _HabitSectionState();
}

class _HabitSectionState extends ConsumerState<_HabitSection> {
  final Set<int> _checked = {};
  int? _lastStageIndex;

  String? _currentChecklistKey;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final repo = ref.watch(lifeGoalsRepoProvider);
    final g = repo.getById(widget.goalId)!;
    final h = g.habit!;
    final s = Theme.of(context).colorScheme;

    final todayKey = _dateKey(DateTime.now());
    final checklistKey = 'habit:${widget.goalId}:${h.currentStageIndex}:$todayKey';

    if (_currentChecklistKey != checklistKey && !_loading) {
      _currentChecklistKey = checklistKey;
      _loadChecklist(checklistKey);
    }
    if (_lastStageIndex != h.currentStageIndex) {
      _lastStageIndex = h.currentStageIndex;
      _checked.clear();
    }

    final curStage = h.currentStage;
    final current = h.currentStageIndex + 1;
    final total = h.stages.length;

    return Container(
      decoration: BoxDecoration(
        color: s.surface.withOpacity(.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: s.outlineVariant.withOpacity(.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HabitRoad(stages: h.stages, streak: h.streak),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(t.stageProgress(current, total),
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(width: 10),
                _miniPill(context, '${curStage.title} • ${h.dayInCurrent}/${curStage.days}'),
                const Spacer(),
                Text(h.quitAchieved ? t.statusQuit : t.streakDays(h.streak)),
              ],
            ),
            const SizedBox(height: 12),

            Text(t.todayChecklist, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            ...curStage.tasks.asMap().entries.map((entry) {
              final i = entry.key;
              final text = entry.value;
              final checked = _checked.contains(i);
              return CheckboxListTile(
                value: checked,
                onChanged: (v) {
                  setState(() {
                    v == true ? _checked.add(i) : _checked.remove(i);
                  });
                  _saveChecklist(_currentChecklistKey, _checked);
                },
                title: Text(text),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }),

            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton(
                  onPressed: h.quitAchieved
                      ? null
                      : () async {
                          if (_checked.length < curStage.tasks.length) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(t.completeChecklistHint)),
                            );
                          }

                          final beforeIndex = h.currentStageIndex;
                          await ref.read(lifeGoalsRepoProvider).markTodayDone(widget.goalId);

                          final fresh = ref.read(lifeGoalsRepoProvider).getById(widget.goalId)!;
                          final hh = fresh.habit!;
                          final afterIndex = hh.currentStageIndex;
                          final atBoundary = hh.dayInCurrent == hh.currentStage.days;
                          final finishedPath = hh.streak >= hh.totalDays || hh.quitAchieved;

                          if (afterIndex > beforeIndex || atBoundary || finishedPath) {
                            if (!mounted) return;
                            final choice = await showDialog<String>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(t.didYouQuit),
                                content: Text(t.didYouQuitDesc),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, 'no'),
                                    child: Text(t.continueRoad),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(context, 'yes'),
                                    child: Text(t.iQuit),
                                  ),
                                ],
                              ),
                            );

                            if (choice == 'yes') {
                              final h0 = hh;
                              final updated = fresh.copyWith(
                                habit: HabitData(
                                  kind: h0.kind,
                                  stages: h0.stages,
                                  streak: h0.streak,
                                  lastDone: h0.lastDone,
                                  quitAchieved: true,
                                ),
                              );
                              await ref.read(lifeGoalsRepoProvider).update(updated);
                            } else {
                              final h0 = hh;
                              final isLastStage = h0.currentStageIndex == h0.stages.length - 1;
                              final reachedEnd =
                                  h0.streak >= h0.totalDays ||
                                  h0.dayInCurrent == h0.currentStage.days;

                              if (isLastStage && reachedEnd) {
                                final last = h0.stages.last;
                                final extra = HabitStage(
                                  id: 'ext_${DateTime.now().millisecondsSinceEpoch}',
                                  title: '${last.title} +',
                                  days: last.days,
                                  tasks: List<String>.from(last.tasks),
                                );
                                final newStages = List<HabitStage>.from(h0.stages)..add(extra);
                                final updated = fresh.copyWith(
                                  habit: HabitData(
                                    kind: h0.kind,
                                    stages: newStages,
                                    streak: h0.streak,
                                    lastDone: h0.lastDone,
                                    quitAchieved: h0.quitAchieved,
                                  ),
                                );
                                await ref.read(lifeGoalsRepoProvider).update(updated);
                              }
                            }

                            if (mounted) setState(() {});
                          }
                        },
                  child: Text(t.doneToday),
                ),
                const SizedBox(width: 12),
                Text(
                  h.quitAchieved ? t.statusQuit : t.streakDays(h.streak),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniPill(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(.28)),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }

  Future<void> _loadChecklist(String key) async {
    _loading = true;
    try {
      final box = await Hive.openBox('life_goals_daily_v1');
      final raw = box.get(key);
      _checked
        ..clear()
        ..addAll((raw is List ? raw.cast<int>() : const <int>[]));
      if (mounted) setState(() {});
    } finally {
      _loading = false;
    }
  }

  Future<void> _saveChecklist(String? key, Set<int> checked) async {
    if (key == null) return;
    final box = await Hive.openBox('life_goals_daily_v1');
    await box.put(key, checked.toList()..sort());
  }
}

/* ================= Визуализация дороги ================= */

class _HabitRoad extends StatelessWidget {
  final List<HabitStage> stages;
  final int streak;
  const _HabitRoad({required this.stages, required this.streak});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          height: 72,
          child: CustomPaint(
            size: const Size(double.infinity, 72),
            painter: _RoadPainter(
              stages: stages,
              streak: streak,
              active: s.primary,
              inactive: s.outlineVariant,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: stages
              .map((st) => Expanded(
                    child: Center(
                      child: Text(
                        st.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _RoadPainter extends CustomPainter {
  final List<HabitStage> stages;
  final int streak;
  final Color active;
  final Color inactive;

  _RoadPainter({
    required this.stages,
    required this.streak,
    required this.active,
    required this.inactive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (stages.isEmpty) return;
    final totalDays = stages.fold(0, (s, e) => s + e.days).toDouble();
    final progress = (streak / totalDays).clamp(0.0, 1.0).toDouble();

    final y = size.height / 2;
    const left = 16.0;
    final right = size.width - 16.0;

    final base = Paint()
      ..color = inactive.withOpacity(0.6)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(left, y), Offset(right, y), base);

    final act = Paint()
      ..color = active
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final xProg = left + (right - left) * progress;
    canvas.drawLine(Offset(left, y), Offset(xProg, y), act);

    final n = stages.length;
    double acc = 0;
    for (int i = 0; i < n; i++) {
      acc += stages[i].days;
      final cx = left + (right - left) * (acc / totalDays);
      final isDone = streak >= acc;
      final paint = Paint()
        ..color = isDone ? active : inactive
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, y), 8, paint);
      final ring = Paint()
        ..color = isDone ? active : inactive
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(cx, y), 12, ring);
    }
  }

  @override
  bool shouldRepaint(covariant _RoadPainter old) =>
      old.stages != stages || old.streak != streak || old.active != active || old.inactive != inactive;
}

/* ================= Спорт (персистентные чекбоксы) ================= */

class _SportSection extends ConsumerStatefulWidget {
  final String goalId;
  const _SportSection({required this.goalId});

  @override
  ConsumerState<_SportSection> createState() => _SportSectionState();
}

class _SportSectionState extends ConsumerState<_SportSection> {
  final Set<int> _checked = {};
  String? _currentChecklistKey;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final repo = ref.watch(lifeGoalsRepoProvider);
    final g = repo.getById(widget.goalId)!;
    final s = g.sport!;
    final cs = Theme.of(context).colorScheme;

    final todayKey = _dateKey(DateTime.now());
    final checklistKey = 'sport:${widget.goalId}:$todayKey';

    if (_currentChecklistKey != checklistKey && !_loading) {
      _currentChecklistKey = checklistKey;
      _loadChecklist(checklistKey);
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withOpacity(.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.todayChecklist, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            ...s.dailyTasks.asMap().entries.map((entry) {
              final i = entry.key;
              final text = entry.value;
              final checked = _checked.contains(i);
              return CheckboxListTile(
                value: checked,
                onChanged: (v) {
                  setState(() {
                    v == true ? _checked.add(i) : _checked.remove(i);
                  });
                  _saveChecklist(_currentChecklistKey, _checked);
                },
                title: Text(text),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }),
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton(
                  onPressed: () => ref.read(lifeGoalsRepoProvider).markTodayDone(widget.goalId),
                  child: Text(t.doneToday),
                ),
                const SizedBox(width: 12),
                Text(t.streakDays(s.streak)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadChecklist(String key) async {
    _loading = true;
    try {
      final box = await Hive.openBox('life_goals_daily_v1');
      final raw = box.get(key);
      _checked..clear()..addAll((raw is List ? raw.cast<int>() : const <int>[]));
      if (mounted) setState(() {});
    } finally {
      _loading = false;
    }
  }

  Future<void> _saveChecklist(String? key, Set<int> checked) async {
    if (key == null) return;
    final box = await Hive.openBox('life_goals_daily_v1');
    await box.put(key, checked.toList()..sort());
  }
}

/* ================= helpers ================= */

Future<double?> _askNumber(BuildContext context, String title) async {
  final c = TextEditingController();
  return showDialog<double>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: '500'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: () {
            final v = double.tryParse(c.text.replaceAll(',', '.'));
            Navigator.pop(context, v);
          },
          child: Text(AppLocalizations.of(context)!.ok),
        ),
      ],
    ),
  );
}

String _dateKey(DateTime d) {
  String two(int x) => x < 10 ? '0$x' : '$x';
  return '${d.year}${two(d.month)}${two(d.day)}';
}
