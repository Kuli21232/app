import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/life_goals_repository.dart';
import '../models/life_goal.dart';
import 'package:motivego/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class LifeGoalsScreen extends ConsumerWidget {
  const LifeGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final repo = ref.watch(lifeGoalsRepoProvider);
    final s = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.goalsTitle),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                s.primary.withOpacity(.20),
                s.secondaryContainer.withOpacity(.06)
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const _AddGoalSheet(),
        ),
        label: Text(t.goalsAdd),
        icon: const Icon(Icons.add),
      ),
      body: repo.items.isEmpty
          ? Center(child: Text(t.goalsEmpty))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              itemCount: repo.items.length + 1, // + сводка
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                if (i == 0) return _SummaryCard(items: repo.items);
                return _GoalCard(goal: repo.items[i - 1]);
              },
            ),
    );
  }
}

/* ------------------------- Сводка сверху ------------------------- */

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.items});
  final List<LifeGoal> items;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final s = Theme.of(context).colorScheme;

    if (items.isEmpty) return const SizedBox.shrink();

    int savingsCnt = 0, habitCnt = 0, sportCnt = 0, finished = 0;
    double sumProgress = 0, totalTarget = 0, totalSaved = 0;

    for (final g in items) {
      sumProgress += g.overallProgress.clamp(0, 1);
      if (g.overallProgress >= 1) finished++;

      switch (g.type) {
        case LifeGoalType.savings:
          savingsCnt++;
          final sd = g.savings;
          if (sd != null) {
            totalTarget += sd.targetAmount;
            totalSaved += sd.saved;
          }
          break;
        case LifeGoalType.habit:
          habitCnt++;
          break;
        case LifeGoalType.sport:
          sportCnt++;
          break;
      }
    }

    final double avg = (sumProgress / items.length).clamp(0.0, 1.0).toDouble();
    final avgPct = (avg * 100).round();
    final df = NumberFormat.decimalPattern();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: s.surface.withOpacity(.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: s.outlineVariant.withOpacity(.35)),
        boxShadow: [
          BoxShadow(
            color: s.primary.withOpacity(.07),
            blurRadius: 24,
            spreadRadius: -6,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.goalsTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: avg,
              minHeight: 10,
              backgroundColor: s.surfaceContainerHighest.withOpacity(.18),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(context, '💰 ${df.format(totalSaved)}'
                  '${totalTarget > 0 ? '/${df.format(totalTarget)}' : ''}'),
              _chip(context, '🚫 $habitCnt'),
              _chip(context, '🏃 $sportCnt'),
              _chip(context, '${t.completed}: $finished/${items.length}'),
              _chip(context, '$avgPct%'),
            ],
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
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

/* --------------------------- Карточка цели --------------------------- */

class _GoalCard extends ConsumerWidget {
  final LifeGoal goal;
  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final double percent =
        goal.overallProgress.clamp(0.0, 1.0).toDouble();
    final df = NumberFormat.decimalPattern();
    final s = Theme.of(context).colorScheme;

    Widget typePill() {
      final name = switch (goal.type) {
        LifeGoalType.savings => t.goalSavings,
        LifeGoalType.habit => t.goalHabit,
        LifeGoalType.sport => t.goalSport,
      };
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: s.primaryContainer.withOpacity(.16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: s.outlineVariant.withOpacity(.28)),
        ),
        child: Text('${goal.type.emoji} $name',
            style: Theme.of(context).textTheme.labelSmall),
      );
    }

    Widget trailingForType(BoxConstraints bc) {
      switch (goal.type) {
        case LifeGoalType.savings:
          final sv = goal.savings!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(t.goalsSavedOf(df.format(sv.saved), df.format(sv.targetAmount))),
              const SizedBox(height: 8),
              SizedBox(
                // ширина строго под правую колонку
                width: bc.maxWidth,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(value: percent, minHeight: 10),
                ),
              ),
            ],
          );
        case LifeGoalType.habit:
          final hd = goal.habit!;
          final stage = hd.currentStage;
          final day = hd.dayInCurrent;
          final total = stage.days;
          return Text(
            '${t.streakDays(hd.streak)} · ${stage.title}: $day/$total',
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodySmall,
          );
        case LifeGoalType.sport:
          final sp = goal.sport!;
          return Text(
            t.streakDays(sp.streak),
            style: Theme.of(context).textTheme.bodySmall,
          );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: s.surface.withOpacity(.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: s.outlineVariant.withOpacity(.35)),
        boxShadow: [
          BoxShadow(
            color: s.primary.withOpacity(.07),
            blurRadius: 24,
            spreadRadius: -6,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/goals/${goal.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, bc) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // аватар с эмодзи и лёгким градиентом
                Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      s.primary.withOpacity(.22),
                      s.primaryContainer.withOpacity(.10),
                    ]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(goal.type.emoji, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 14),

                // средняя колонка: заголовок, чип, общий прогресс
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Wrap(spacing: 8, runSpacing: 8, children: [typePill()]),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: percent,
                          minHeight: 8,
                          backgroundColor:
                              s.surfaceContainerHighest.withOpacity(.18),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // правая колонка: адаптивная ширина
                SizedBox(
                  width: (bc.maxWidth * 0.35).clamp(100.0, 180.0),
                  child: LayoutBuilder(
                    builder: (context, rightBc) => Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        trailingForType(rightBc),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chevron_right_rounded,
                                color: s.onSurfaceVariant),
                            PopupMenuButton<String>(
                              tooltip: '',
                              onSelected: (v) async {
                                if (v == 'remove') {
                                  final ok = await _confirm(
                                    context,
                                    AppLocalizations.of(context)!
                                        .confirmDeleteGoal,
                                  );
                                  if (ok) {
                                    await ref
                                        .read(lifeGoalsRepoProvider)
                                        .remove(goal.id);
                                  }
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                    value: 'remove', child: Text(t.delete)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ----------------------- Добавление цели ----------------------- */

class _AddGoalSheet extends ConsumerStatefulWidget {
  const _AddGoalSheet();

  @override
  ConsumerState<_AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends ConsumerState<_AddGoalSheet> {
  LifeGoalType _type = LifeGoalType.savings;

  // Общие поля
  final _title = TextEditingController();
  final _photoUrl = TextEditingController();

  // Накопить
  final _target = TextEditingController();
  final _income = TextEditingController();

  // Привычка/Спорт — выбираем из рекомендаций, своё только доп.
  HabitKind _habit = HabitKind.smoking;
  SportKind _sport = SportKind.running;
  final Set<String> _selectedTasks = {}; // выбранные рекомендации
  final List<String> _customTasks = []; // дополнительные собственные

  @override
  void initState() {
    super.initState();
    _title.text = '';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final sheet = MediaQuery.of(context).size.height * 0.9;
    return Container(
      height: sheet,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: ListView(
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(t.createGoal,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),

              // Тип
              DropdownButtonFormField<LifeGoalType>(
                value: _type,
                decoration: InputDecoration(labelText: t.goalType),
                items: [
                  DropdownMenuItem(
                      value: LifeGoalType.savings,
                      child: Text('💰 ${t.goalSavings}')),
                  DropdownMenuItem(
                      value: LifeGoalType.habit,
                      child: Text('🚫 ${t.goalHabit}')),
                  DropdownMenuItem(
                      value: LifeGoalType.sport,
                      child: Text('🏃 ${t.goalSport}')),
                ],
                onChanged: (v) {
                  setState(() {
                    _type = v!;
                    _selectedTasks.clear();
                    _customTasks.clear();
                  });
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _title,
                decoration: InputDecoration(labelText: t.goalName),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _photoUrl,
                decoration: InputDecoration(labelText: t.photoUrlOptional),
              ),
              const SizedBox(height: 12),

              // Контекстная форма
              _buildContextForm(context),

              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submit,
                child: Text(t.save),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContextForm(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    switch (_type) {
      case LifeGoalType.savings:
        return Column(
          children: [
            TextFormField(
              controller: _income,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: t.weeklyIncome),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _target,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: t.targetAmount),
            ),
          ],
        );

      case LifeGoalType.habit:
        final suggestions = _habitSuggestions(t, _habit);
        if (_selectedTasks.isEmpty) _selectedTasks.addAll(suggestions);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<HabitKind>(
              value: _habit,
              decoration: InputDecoration(labelText: t.habitKind),
              items: HabitKind.values
                  .map((k) => DropdownMenuItem(
                      value: k, child: Text(_habitTitle(t, k))))
                  .toList(),
              onChanged: (v) => setState(() {
                _habit = v!;
                _selectedTasks
                  ..clear()
                  ..addAll(_habitSuggestions(t, _habit));
                _customTasks.clear();
              }),
            ),
            const SizedBox(height: 12),
            Text(t.suggestedTasks,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions.map((e) {
                final sel = _selectedTasks.contains(e);
                return ChoiceChip(
                  label: Text(e),
                  selected: sel,
                  onSelected: (_) => setState(() {
                    if (sel) {
                      _selectedTasks.remove(e);
                    } else {
                      _selectedTasks.add(e);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final v = await _askText(context, t.addCustomTask);
                if (v != null && v.trim().isNotEmpty) {
                  setState(() => _customTasks.add(v.trim()));
                }
              },
              icon: const Icon(Icons.add),
              label: Text(t.addCustomTask),
            ),
            if (_customTasks.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _customTasks
                    .map((e) => InputChip(
                          label: Text(e),
                          onDeleted: () =>
                              setState(() => _customTasks.remove(e)),
                        ))
                    .toList(),
              ),
            ],
          ],
        );

      case LifeGoalType.sport:
        final suggestions = _sportSuggestions(t, _sport);
        if (_selectedTasks.isEmpty) _selectedTasks.addAll(suggestions);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<SportKind>(
              value: _sport,
              decoration: InputDecoration(labelText: t.sportKind),
              items: SportKind.values
                  .map((k) => DropdownMenuItem(
                      value: k, child: Text(_sportTitle(t, k))))
                  .toList(),
              onChanged: (v) => setState(() {
                _sport = v!;
                _selectedTasks
                  ..clear()
                  ..addAll(_sportSuggestions(t, _sport));
                _customTasks.clear();
              }),
            ),
            const SizedBox(height: 12),
            Text(t.suggestedTasks,
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions.map((e) {
                final sel = _selectedTasks.contains(e);
                return ChoiceChip(
                  label: Text(e),
                  selected: sel,
                  onSelected: (_) => setState(() {
                    if (sel) {
                      _selectedTasks.remove(e);
                    } else {
                      _selectedTasks.add(e);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final v = await _askText(context, t.addCustomTask);
                if (v != null && v.trim().isNotEmpty) {
                  setState(() => _customTasks.add(v.trim()));
                }
              },
              icon: const Icon(Icons.add),
              label: Text(t.addCustomTask),
            ),
            if (_customTasks.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _customTasks
                    .map((e) => InputChip(
                          label: Text(e),
                          onDeleted: () =>
                              setState(() => _customTasks.remove(e)),
                        ))
                    .toList(),
              ),
            ],
          ],
        );
    }
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context)!;
    final repo = ref.read(lifeGoalsRepoProvider);

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final created = DateTime.now();

    late final LifeGoal goal;

    if (_type == LifeGoalType.savings) {
      final target =
          double.tryParse(_target.text.replaceAll(',', '.')) ?? 0;
      final income =
          double.tryParse(_income.text.replaceAll(',', '.')) ?? 0;

      goal = LifeGoal(
        id: id,
        type: LifeGoalType.savings,
        title:
            _title.text.trim().isEmpty ? t.goalSavings : _title.text.trim(),
        photoUrl:
            _photoUrl.text.trim().isEmpty ? null : _photoUrl.text.trim(),
        createdAt: created,
        savings: SavingsData(targetAmount: target, weeklyIncome: income),
      );
    } else if (_type == LifeGoalType.habit) {
      final stages = _defaultHabitStages(_habit, t);

      List<String> uniq(List<String> src) {
        final seen = <String>{};
        final out = <String>[];
        for (final s in src) {
          if (seen.add(s)) out.add(s);
        }
        return out;
      }

      if (_selectedTasks.isNotEmpty || _customTasks.isNotEmpty) {
        final first = stages.first;
        stages[0] = HabitStage(
          id: first.id,
          title: first.title,
          days: first.days,
          tasks: uniq([...first.tasks, ..._selectedTasks, ..._customTasks]),
        );
      }

      goal = LifeGoal(
        id: id,
        type: LifeGoalType.habit,
        title: _title.text.trim().isEmpty
            ? '${t.goalHabit}: ${_habitTitle(t, _habit)}'
            : _title.text.trim(),
        photoUrl:
            _photoUrl.text.trim().isEmpty ? null : _photoUrl.text.trim(),
        createdAt: created,
        habit: HabitData(kind: _habit, stages: stages),
      );
    } else {
      final tasks = [..._selectedTasks, ..._customTasks];

      goal = LifeGoal(
        id: id,
        type: LifeGoalType.sport,
        title: _title.text.trim().isEmpty
            ? '${t.goalSport}: ${_sportTitle(t, _sport)}'
            : _title.text.trim(),
        photoUrl:
            _photoUrl.text.trim().isEmpty ? null : _photoUrl.text.trim(),
        createdAt: created,
        sport: SportData(kind: _sport, dailyTasks: tasks),
      );
    }

    await repo.add(goal);
    if (mounted) Navigator.of(context).pop();
  }

  // ===== Локализованные заголовки и рекомендации =====
  String _habitTitle(AppLocalizations t, HabitKind k) => switch (k) {
        HabitKind.smoking => t.habitSmoking,
        HabitKind.alcohol => t.habitAlcohol,
        HabitKind.sugar => t.habitSugar,
        HabitKind.junkFood => t.habitJunkFood,
        HabitKind.socialMedia => t.habitSocialMedia,
        HabitKind.gaming => t.habitGaming,
        HabitKind.other => t.other,
      };

  String _sportTitle(AppLocalizations t, SportKind k) => switch (k) {
        SportKind.running => t.sportRunning,
        SportKind.gym => t.sportGym,
        SportKind.yoga => t.sportYoga,
        SportKind.swimming => t.sportSwimming,
        SportKind.cycling => t.sportCycling,
        SportKind.other => t.other,
      };

  List<String> _habitSuggestions(AppLocalizations t, HabitKind k) =>
      switch (k) {
        HabitKind.smoking =>
          [t.taskNoSmoking, t.taskDrinkWater, t.taskBreathing5m],
        HabitKind.alcohol =>
          [t.taskNoAlcohol, t.taskWalk20m, t.taskDrinkWater],
        HabitKind.socialMedia => [t.taskNoSocial2h, t.taskRead10p],
        HabitKind.sugar => [t.taskNoSugar, t.taskFruitInstead],
        HabitKind.junkFood => [t.taskNoJunk, t.taskSaladPortion],
        HabitKind.gaming => [t.taskNoGames3h, t.taskSport20m],
        HabitKind.other => [t.taskStep1, t.taskStep2],
      };

  List<String> _sportSuggestions(AppLocalizations t, SportKind k) =>
      switch (k) {
        SportKind.running => [t.taskWarmup10m, t.taskRun20_30m, t.taskStretching],
        SportKind.gym => [t.taskWarmup, t.taskStrength30_40m, t.taskCooldown],
        SportKind.yoga => [t.taskYoga20_30m],
        SportKind.swimming => [t.taskSwim30m],
        SportKind.cycling => [t.taskBike30_60m],
        SportKind.other => [t.taskActivity20_30m],
      };

  /// Этапы по умолчанию для привычки: 3 → 7 → 21 с базовыми задачами.
  List<HabitStage> _defaultHabitStages(HabitKind kind, AppLocalizations t) {
    final prep = [t.taskDrinkWater, t.taskWalk20m, t.taskRead10p];
    final stabilize = [t.taskNoSocial2h, t.taskBreathing5m, t.taskSport20m];

    final consolidation = switch (kind) {
      HabitKind.smoking => [t.taskNoSmoking, t.taskBreathing5m, t.taskDrinkWater],
      HabitKind.alcohol => [t.taskNoAlcohol, t.taskWalk20m, t.taskDrinkWater],
      HabitKind.sugar => [t.taskNoSugar, t.taskFruitInstead],
      HabitKind.junkFood => [t.taskNoJunk, t.taskSaladPortion],
      HabitKind.socialMedia => [t.taskNoSocial2h, t.taskRead10p],
      HabitKind.gaming => [t.taskNoGames3h, t.taskSport20m],
      HabitKind.other => [t.taskStep1, t.taskStep2],
    };

    return [
      HabitStage(id: 'st1', title: t.stage1Title, days: 3, tasks: prep),
      HabitStage(id: 'st2', title: t.stage2Title, days: 7, tasks: stabilize),
      HabitStage(id: 'st3', title: t.stage3Title, days: 21, tasks: consolidation),
    ];
  }
}

// — helpers —
Future<String?> _askText(BuildContext context, String title) async {
  final c = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content:
          TextField(controller: c, decoration: const InputDecoration(hintText: '...')),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel)),
        FilledButton(
            onPressed: () => Navigator.pop(context, c.text),
            child: Text(AppLocalizations.of(context)!.add)),
      ],
    ),
  );
}

Future<bool> _confirm(BuildContext context, String title) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel)),
        FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(AppLocalizations.of(context)!.delete)),
      ],
    ),
  );
  return ok ?? false;
}
