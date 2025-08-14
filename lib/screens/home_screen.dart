import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

import '../data/goals_repository.dart';
import '../models/goal.dart';
import '../ui/adaptive.dart';
import 'package:motivego/l10n/app_localizations.dart';
import '../ui/home_button.dart';

/// Репозиторий задач
final repoProvider = Provider((ref) => GoalsRepository());

/// Выбранная дата (день)
final selectedDateProvider = StateProvider<DateTime>((_) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Задачи на выбранную дату (без сортировки/фильтрации)
final goalsProvider = Provider<List<Goal>>((ref) {
  final repo = ref.watch(repoProvider);
  final date = ref.watch(selectedDateProvider);
  return repo.goalsForDate(date);
});

/// ID целей, которые сейчас «заняты» (идёт анимация/обработка)
final _busyGoalsProvider = StateProvider<Set<String>>((_) => <String>{});

/// Сортировка/фильтрация
enum SortMode { activeFirst, priorityHigh, titleAZ, doneFirst }
final sortModeProvider = StateProvider<SortMode>((_) => SortMode.activeFirst);
final hideCompletedProvider = StateProvider<bool>((_) => false);

DateTime _monday(DateTime d) => d.subtract(Duration(days: d.weekday - 1));
List<DateTime> _weekOf(DateTime anchor) {
  final start = _monday(anchor);
  return List.generate(7, (i) => DateTime(start.year, start.month, start.day + i));
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final localeTag = Localizations.localeOf(context).toLanguageTag();

    final warmup = Offstage(
      offstage: true,
      child: Lottie.network(
        'https://assets9.lottiefiles.com/packages/lf20_jbrw3hcz.json',
        repeat: false,
      ),
    );

    return Scaffold(
      appBar: _GradientHeader(t: t, localeTag: localeTag),
      body: Stack(
        children: [
          const _GradientBackground(),
          const CenteredContent(child: _PlannerBody()),
          warmup,
        ],
      ),
      floatingActionButton: _AddGoalFab(
        onPressed: () => _showAddGoalSheet(context, ref),
        t: t,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  static void _showAddGoalSheet(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final titleCtrl = TextEditingController();
    int priority = 2;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) {
        final scheme = Theme.of(c).colorScheme;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                color: scheme.surface.withOpacity(0.92),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: StatefulBuilder(
                    builder: (context, setState) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        TextField(
                          controller: titleCtrl,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: t.goalNameLabel,
                            filled: true,
                            fillColor: scheme.surfaceContainerHighest.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(t.priority, style: Theme.of(context).textTheme.labelLarge),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            _PriorityChip(
                              label: t.priorityLow,
                              selected: priority == 1,
                              color: Colors.teal,
                              onTap: () => setState(() => priority = 1),
                            ),
                            _PriorityChip(
                              label: t.priorityMedium,
                              selected: priority == 2,
                              color: const Color(0xFF6C4DFF),
                              onTap: () => setState(() => priority = 2),
                            ),
                            _PriorityChip(
                              label: t.priorityHigh,
                              selected: priority == 3,
                              color: Colors.pinkAccent,
                              onTap: () => setState(() => priority = 3),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () async {
                              final text = titleCtrl.text.trim();
                              if (text.isEmpty) return;
                              final date = ref.read(selectedDateProvider);
                              await ref.read(repoProvider).add(
                                title: text,
                                priority: priority,
                                plannedDate: date,
                              );
                              if (context.mounted) Navigator.pop(context);
                              ref.invalidate(goalsProvider);
                            },
                            child: Text(t.addButton),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static void _showSortSheet(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    SortMode tmpMode = ref.read(sortModeProvider);
    bool tmpHide = ref.read(hideCompletedProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (c) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              color: scheme.surface.withOpacity(0.92),
              child: StatefulBuilder(
                builder: (c, setState) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(c).dividerColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.sort_rounded),
                          const SizedBox(width: 8),
                          Text('Сортировка и фильтр',
                              style: Theme.of(c).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _SortTile(
                        title: 'Активные → приоритет → название',
                        value: SortMode.activeFirst,
                        group: tmpMode,
                        onChanged: (v) => setState(() => tmpMode = v!),
                      ),
                      _SortTile(
                        title: 'Приоритет (высокий → низкий)',
                        value: SortMode.priorityHigh,
                        group: tmpMode,
                        onChanged: (v) => setState(() => tmpMode = v!),
                      ),
                      _SortTile(
                        title: 'Название (А → Я)',
                        value: SortMode.titleAZ,
                        group: tmpMode,
                        onChanged: (v) => setState(() => tmpMode = v!),
                      ),
                      _SortTile(
                        title: 'Выполненные сначала',
                        value: SortMode.doneFirst,
                        group: tmpMode,
                        onChanged: (v) => setState(() => tmpMode = v!),
                      ),
                      const SizedBox(height: 4),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Скрывать выполненные'),
                        value: tmpHide,
                        onChanged: (v) => setState(() => tmpHide = v),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                ref.read(sortModeProvider.notifier).state = tmpMode;
                                ref.read(hideCompletedProvider.notifier).state = tmpHide;
                                Navigator.of(c).pop();
                              },
                              child: const Text('Готово'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                tmpMode = SortMode.activeFirst;
                                tmpHide = false;
                              });
                            },
                            child: const Text('Сброс'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SortTile extends StatelessWidget {
  final String title;
  final SortMode value;
  final SortMode group;
  final ValueChanged<SortMode?> onChanged;
  const _SortTile({
    required this.title,
    required this.value,
    required this.group,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return RadioListTile<SortMode>(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      groupValue: group,
      onChanged: onChanged,
    );
  }
}

class _GradientHeader extends ConsumerWidget implements PreferredSizeWidget {
  final AppLocalizations t;
  final String localeTag;
  const _GradientHeader({required this.t, required this.localeTag});

  @override
  Size get preferredSize => const Size.fromHeight(96);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedDateProvider);
    final goals = ref.watch(goalsProvider);
    final done = goals.where((g) => g.isDone).length;
    final planned = goals.length;

    String ddm(DateTime d) => DateFormat('dd MMM', localeTag).format(d);

    return AppBar(
      toolbarHeight: 56,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2E1A68), Color(0xFF6C4DFF)],
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.black.withOpacity(0.08)),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.calendar_today),
        tooltip: t.chooseDate,
        onPressed: () async {
          final now = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: ref.read(selectedDateProvider),
            firstDate: DateTime(now.year - 2),
            lastDate: DateTime(now.year + 2),
            locale: Locale(Intl.shortLocale(localeTag)),
          );
          if (picked != null) {
            ref.read(selectedDateProvider.notifier).state =
                DateTime(picked.year, picked.month, picked.day);
            ref.invalidate(goalsProvider);
          }
        },
      ),
      title: Text(t.tabPlanner, style: const TextStyle(fontWeight: FontWeight.w700)),
      actions: [
        const HomeButton(),
        IconButton(
          onPressed: () => HomeScreen._showSortSheet(context, ref),
          icon: const Icon(Icons.sort_rounded),
          tooltip: 'Сортировка',
        ),
        IconButton(
          onPressed: () => context.push('/stats'),
          icon: const Icon(Icons.bar_chart_rounded),
          tooltip: t.statsTitle,
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Row(
            children: [
              _SmallPill(icon: Icons.today, label: ddm(date)),
              const SizedBox(width: 8),
              Expanded(child: _SmallProgress(done: done, planned: planned)),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F0E1A), Color(0xFF16142A)],
        ),
      ),
    );
  }
}

class _PlannerBody extends ConsumerWidget {
  const _PlannerBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final localeTag = Localizations.localeOf(context).toLanguageTag();

    final date = ref.watch(selectedDateProvider);
    final rawGoals = ref.watch(goalsProvider);
    final busy = ref.watch(_busyGoalsProvider);
    final sortMode = ref.watch(sortModeProvider);
    final hideCompleted = ref.watch(hideCompletedProvider);

    // фильтрация
    List<Goal> goals = hideCompleted
        ? rawGoals.where((g) => !g.isDone).toList()
        : List.of(rawGoals);

    // сортировка
    int cmpTitle(Goal a, Goal b) =>
        a.title.toLowerCase().compareTo(b.title.toLowerCase());
    int asBool(bool v) => v ? 1 : 0;

    goals.sort((a, b) {
      switch (sortMode) {
        case SortMode.activeFirst:
          final c1 = asBool(a.isDone).compareTo(asBool(b.isDone)); // false < true
          if (c1 != 0) return c1;
          final c2 = b.priority.compareTo(a.priority); // 3>2>1
          if (c2 != 0) return c2;
          return cmpTitle(a, b);
        case SortMode.priorityHigh:
          final c0 = b.priority.compareTo(a.priority);
          if (c0 != 0) return c0;
          final c1 = asBool(a.isDone).compareTo(asBool(b.isDone));
          if (c1 != 0) return c1;
          return cmpTitle(a, b);
        case SortMode.titleAZ:
          final c0 = cmpTitle(a, b);
          if (c0 != 0) return c0;
          final c1 = asBool(a.isDone).compareTo(asBool(b.isDone));
          if (c1 != 0) return c1;
          return b.priority.compareTo(a.priority);
        case SortMode.doneFirst:
          final c1 = asBool(b.isDone).compareTo(asBool(a.isDone)); // true < false -> done first
          if (c1 != 0) return c1;
          final c2 = b.priority.compareTo(a.priority);
          if (c2 != 0) return c2;
          return cmpTitle(a, b);
      }
    });

    final done = rawGoals.where((g) => g.isDone).length;
    final planned = rawGoals.length;
    final progress = planned == 0 ? 0.0 : done / planned;

    final weekDays = _weekOf(date);
    final scheme = Theme.of(context).colorScheme;

    String ddm(DateTime d) => DateFormat('dd.MM', localeTag).format(d);
    String weekdayShort(DateTime d) => DateFormat.E(localeTag).format(d);

    const animDur = Duration(milliseconds: 260);
    const animCurve = Curves.easeOutCubic;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, isNarrow ? 8 : 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Неделя
              SizedBox(
                height: isNarrow ? 58 : 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: weekDays.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (c, i) {
                    final d = weekDays[i];
                    final isSel = d.year == date.year && d.month == date.month && d.day == date.day;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(selectedDateProvider.notifier).state = d;
                        ref.invalidate(goalsProvider);
                      },
                      child: AnimatedContainer(
                        duration: animDur,
                        curve: animCurve,
                        width: isNarrow ? 64 : 72,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: isSel
                              ? const LinearGradient(
                                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                                  colors: [Color(0xFF3E2C8A), Color(0xFF6C4DFF)],
                                )
                              : null,
                          color: isSel ? null : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSel ? Colors.transparent : Theme.of(context).dividerColor,
                            width: 1.1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FittedBox(
                              child: Text(
                                ddm(d),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isSel ? Colors.white : scheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              child: Text(
                                weekdayShort(d),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isSel ? Colors.white70 : null,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Прогресс (мягкое появление при смене дня)
              AnimatedSwitcher(
                duration: animDur,
                switchInCurve: animCurve,
                switchOutCurve: animCurve,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, .05), end: Offset.zero)
                        .animate(CurvedAnimation(parent: anim, curve: animCurve)),
                    child: child,
                  ),
                ),
                child: Hero(
                  key: ValueKey(date), // новая карточка на каждый день
                  tag: 'progressHero',
                  child: Card(
                    elevation: 0,
                    clipBehavior: Clip.hardEdge,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    child: SizedBox(
                      height: isNarrow ? 92 : 100,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    ddm(date),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(t.doneOfPlanned(done, planned),
                                    style: Theme.of(context).textTheme.labelMedium),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: TweenAnimationBuilder<double>(
                                duration: animDur,
                                curve: animCurve,
                                tween: Tween(begin: 0, end: progress),
                                builder: (_, v, __) => LinearProgressIndicator(
                                  value: v,
                                  minHeight: 10,
                                  backgroundColor: scheme.surfaceContainerHighest.withOpacity(0.5),
                                  valueColor: const AlwaysStoppedAnimation(Color(0xFF6C4DFF)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Отображение активных фильтров (если есть)
              Builder(
                builder: (_) {
                  final chips = <Widget>[];
                  String labelFor(SortMode m) {
                    switch (m) {
                      case SortMode.activeFirst: return 'Активные→Приоритет';
                      case SortMode.priorityHigh: return 'Приоритет';
                      case SortMode.titleAZ: return 'Название A→Я';
                      case SortMode.doneFirst: return 'Выполненные';
                    }
                  }

                  chips.add(_TinyChip(icon: Icons.sort_rounded, label: labelFor(sortMode)));
                  if (hideCompleted) {
                    chips.add(const SizedBox(width: 6));
                    chips.add(const _TinyChip(icon: Icons.visibility_off, label: 'Скрыты выполненные'));
                  }

                  return Wrap(children: chips);
                },
              ),

              const SizedBox(height: 10),

              // Список задач
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: goals.isEmpty
                      ? _EmptyState(t: t)
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: goals.length,
                          itemBuilder: (c, i) {
                            final g = goals[i];
                            final isBusy = busy.contains(g.id);

                            return _GoalTile(
                              goal: g,
                              disabled: isBusy,
                              onToggle: () async {
                                // ДЕБАУНС: игнорируем повторные тапы, пока идёт обработка
                                final nowBusy = ref.read(_busyGoalsProvider);
                                if (nowBusy.contains(g.id)) return;

                                ref.read(_busyGoalsProvider.notifier)
                                   .update((s) => {...s, g.id});

                                try {
                                  final wasDone = g.isDone;
                                  await ref.read(repoProvider).toggleDone(g.id);
                                  ref.invalidate(goalsProvider);

                                  if (!wasDone && c.mounted) {
                                    // показываем диалог и закрываем ИМЕННО его
                                    await showDialog(
                                      context: c,
                                      barrierDismissible: true,
                                      builder: (dialogCtx) {
                                        // авто-закрытие только этого диалога
                                        Future.delayed(const Duration(milliseconds: 1100), () {
                                          if (dialogCtx.mounted) {
                                            Navigator.of(dialogCtx).maybePop();
                                          }
                                        });
                                        return Dialog(
                                          insetPadding: const EdgeInsets.all(40),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                  height: 160,
                                                  child: Lottie.network(
                                                    'https://assets9.lottiefiles.com/packages/lf20_jbrw3hcz.json',
                                                    repeat: false,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(t.goalCompletedDialog),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );

                                    if (c.mounted) {
                                      ScaffoldMessenger.of(c).showSnackBar(
                                        SnackBar(content: Text(t.goalCompletedToast)),
                                      );
                                    }
                                  }
                                } finally {
                                  // снимаем «занято»
                                  ref.read(_busyGoalsProvider.notifier).update((s) {
                                    final ss = {...s};
                                    ss.remove(g.id);
                                    return ss;
                                  });
                                }
                              },
                              onDelete: () async {
                                // Не позволяем удалять во время анимации/обработки
                                if (ref.read(_busyGoalsProvider).contains(g.id)) return;

                                await ref.read(repoProvider).delete(g.id);
                                ref.invalidate(goalsProvider);
                                if (c.mounted) {
                                  ScaffoldMessenger.of(c).showSnackBar(
                                    SnackBar(content: Text(t.goalDeletedToast)),
                                  );
                                }
                              },
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// --- UI атомы и мелкие виджеты ---

class _TinyChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TinyChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: s.surfaceContainerHighest.withOpacity(0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: s.outline.withOpacity(.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SmallPill({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SmallProgress extends StatelessWidget {
  final int done;
  final int planned;
  const _SmallProgress({required this.done, required this.planned});
  @override
  Widget build(BuildContext context) {
    final ratio = planned == 0 ? 0.0 : done / planned;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: ratio,
        minHeight: 8,
        backgroundColor: Colors.white.withOpacity(0.18),
        valueColor: const AlwaysStoppedAnimation(Color(0xFFE3D9FF)),
      ),
    );
  }
}

/// Плитка задачи с плавными анимациями
class _GoalTile extends StatelessWidget {
  final Goal goal;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final bool disabled; // NEW

  const _GoalTile({
    required this.goal,
    required this.onToggle,
    required this.onDelete,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    const animDur = Duration(milliseconds: 220);
    const animCurve = Curves.easeOutCubic;

    return AnimatedOpacity(
      duration: animDur,
      opacity: disabled ? 0.7 : 1.0,
      child: AnimatedContainer(
        duration: animDur,
        curve: animCurve,
        transform: Matrix4.identity()..scale(goal.isDone ? 0.98 : 1.0),
        margin: const EdgeInsets.only(bottom: 8),
        child: IgnorePointer( // блокируем любые тапы, когда disabled
          ignoring: disabled,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              leading: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: goal.isDone ? 1.0 : 0.0),
                duration: animDur,
                curve: animCurve,
                builder: (_, v, __) => Transform.scale(
                  scale: 1 + v * 0.1,
                  child: IconButton(
                    icon: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: 1 - v,
                          child: const Icon(Icons.radio_button_unchecked),
                        ),
                        Opacity(
                          opacity: v,
                          child: const Icon(Icons.check_circle),
                        ),
                      ],
                    ),
                    onPressed: onToggle,
                  ),
                ),
              ),
              title: AnimatedDefaultTextStyle(
                duration: animDur, curve: animCurve,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: goal.isDone ? TextDecoration.lineThrough : null,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
                child: Text(goal.title, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              subtitle: AnimatedSize(
                duration: animDur, curve: animCurve,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (goal.note != null && goal.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 6),
                        child: Text(
                          goal.note!,
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Row(children: [_PriorityPill(priority: goal.priority)]),
                  ],
                ),
              ),
              trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddGoalFab extends StatelessWidget {
  final VoidCallback onPressed;
  final AppLocalizations t;
  const _AddGoalFab({required this.onPressed, required this.t});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      label: Text(t.addGoal),
      backgroundColor: const Color(0xFF6C4DFF),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  final int priority;
  const _PriorityPill({required this.priority});
  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final String label;
    switch (priority) {
      case 1: color = Colors.teal; label = 'P1'; break;
      case 3: color = Colors.pinkAccent; label = 'P3'; break;
      default: color = const Color(0xFF6C4DFF); label = 'P2';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _PriorityChip({required this.label, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(color: selected ? Colors.white : null, fontWeight: FontWeight.w600),
      selectedColor: color,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations t;
  const _EmptyState({required this.t});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: 0.8,
              child: Icon(Icons.inbox_outlined, size: 64, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 10),
            Text(
              t.noGoalsToday,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
