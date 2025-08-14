import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:motivego/l10n/app_localizations.dart';
import '../data/life_goals_repository.dart' show lifeGoalsRepoProvider;
import '../models/life_goal.dart';

import '../data/goals_repository.dart';
import '../data/pomodoro_repository.dart';
import 'reflection_screen.dart' show reflectionRepoProvider;

final _goalsRepoProvider = Provider((ref) => GoalsRepository());
final _pomodoroRepoProvider = Provider((ref) => PomodoroRepository());

class HubScreen extends ConsumerWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.hubTitle),
        centerTitle: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary.withOpacity(.20),
                scheme.secondaryContainer.withOpacity(.06),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: t.settings,
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: const [
          _HeroHeader(),               // Новый красивый хэдэр со сводкой за сегодня
          SizedBox(height: 12),
          _PlannerPanel(),
          SizedBox(height: 12),
          _FocusPanel(),
          SizedBox(height: 12),
          _StatsPanel(),
          SizedBox(height: 12),
          _QuickActionsPanel(),        // большие кнопки: Цель и Старт
          SizedBox(height: 12),
          _ReflectionPanel(),
          SizedBox(height: 12),
          _NavPanel(),                 // Coach и Настройки
        ],
      ),
    );
  }
}

/* -------------------- Общие элементы -------------------- */

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: s.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: s.outlineVariant.withOpacity(0.35), width: 1),
        boxShadow: [
          BoxShadow(
            color: s.primary.withOpacity(0.07),
            blurRadius: 24,
            spreadRadius: -6,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Универсальная строчка внутри панели
class _RowCardButton extends StatelessWidget {
  const _RowCardButton({
    required this.leading,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailingWidget,
    this.bottom,
  });

  final IconData leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailingWidget; // если нужен свой виджет справа
  final Widget? bottom;         // прогресс/заметка и т.п.

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final compact = MediaQuery.sizeOf(context).width < 360;

    final defaultTrailing = compact
        ? IconButton(
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward_rounded),
            tooltip: AppLocalizations.of(context)!.open,
          )
        : FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(AppLocalizations.of(context)!.open),
            style: FilledButton.styleFrom(
              backgroundColor: s.primaryContainer.withOpacity(0.9),
              foregroundColor: s.onPrimaryContainer,
              side: BorderSide(color: s.primary, width: 1.2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        s.primary.withOpacity(.20),
                        s.primaryContainer.withOpacity(.14),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(leading, size: 20, color: s.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: s.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                trailingWidget ?? defaultTrailing,
              ],
            ),
            if (bottom != null) ...[
              const SizedBox(height: 12),
              bottom!,
            ],
          ],
        ),
      ),
    );
  }
}

/* -------------------- Новый «hero»-хэдэр -------------------- */

class _HeroHeader extends ConsumerWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);

    // Планы на сегодня
    final goalsRepo = ref.watch(_goalsRepoProvider);
    final goals = goalsRepo.goalsForDate(day);
    final total = goals.length;
    final done = goals.where((g) => g.isDone).length;
    final ratio = total == 0 ? 0.0 : done / total;

    // Фокус/отвлечения за сегодня
    final pomoRepo = ref.watch(_pomodoroRepoProvider);

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        pomoRepo.totalFocusMinutesForDay(day),
        pomoRepo.totalDistractionsForDay(day),
      ]),
      builder: (context, snap) {
        final focusMin = (snap.data?[0] ?? 0) as int;
        final distractions = (snap.data?[1] ?? 0) as int;

        final dateStr = DateFormat('EEEE, d MMM', locale).format(now);
        final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
        final wDistr = isRu ? 'Отвлечений' : 'Distractions';
        final completedLabel = AppLocalizations.of(context)!.completed;

        return Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1, -1),
              end: Alignment(1, 1),
              colors: [
                s.primary.withOpacity(.85),
                s.secondaryContainer.withOpacity(.60),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              // «пузыри» для фактуры
              Positioned(
                left: 24,
                top: 22,
                child: _heroBubble(78, s.primaryContainer.withOpacity(.25)),
              ),
              Positioned(
                right: 28,
                bottom: 18,
                child: _heroBubble(90, s.secondary.withOpacity(.18)),
              ),

              // Контент
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Дата
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(.14)),
                      ),
                      child: Text(
                        _capitalize(dateStr),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Прогресс по задачам
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 10,
                              backgroundColor: Colors.white.withOpacity(.18),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(.92),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$done/$total',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Чипы сводки
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatChip(
                          icon: Icons.event_available,
                          text: '$completedLabel: $done/$total',
                        ),
                        _StatChip(
                          icon: Icons.timer_outlined,
                          text: '$focusMin ${AppLocalizations.of(context)!.minutes}',
                        ),
                        _StatChip(
                          icon: Icons.notifications_off_outlined,
                          text: '$wDistr: $distractions',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _heroBubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            spreadRadius: -8,
            color: color.withOpacity(.6),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/* -------------------- Панели -------------------- */

class _PlannerPanel extends ConsumerWidget {
  const _PlannerPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final repo = ref.watch(_goalsRepoProvider);

    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    final goals = repo.goalsForDate(day);
    final total = goals.length;
    final done = goals.where((g) => g.isDone).length;
    final ratio = total == 0 ? 0.0 : done / total;

    final s = Theme.of(context).colorScheme;

    return _SectionCard(
      child: _RowCardButton(
        leading: Icons.event_available,
        title: t.planner,
        subtitle: total == 0 ? t.noTasks : '${t.completed}: $done / $total',
        onTap: () => context.push('/planner'),
        bottom: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            backgroundColor: s.surfaceContainerHighest.withOpacity(0.18),
          ),
        ),
      ),
    );
  }
}

class _FocusPanel extends ConsumerWidget {
  const _FocusPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final repo = ref.watch(_pomodoroRepoProvider);

    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
    final w7d = isRu ? '7д' : '7d';
    final wDistr = isRu ? 'Отвлечений' : 'Distractions';

    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);

    return _SectionCard(
      child: FutureBuilder<List<dynamic>>(
        future: Future.wait([
          repo.totalFocusMinutesForDay(day),
          repo.totalDistractionsForDay(day),
          repo.completionRateLast7Days(),
        ]),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return _RowCardButton(
              leading: Icons.timer,
              title: t.focus,
              subtitle: '…',
              onTap: () => context.push('/focus'),
              trailingWidget: FilledButton.icon(
                onPressed: () => context.push('/focus'),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(t.start),
              ),
            );
          }
          final focusMin = (snap.data?[0] ?? 0) as int;
          final distractions = (snap.data?[1] ?? 0) as int;
          final ratePct = (((snap.data?[2] ?? 0.0) as double) * 100).round();

          return _RowCardButton(
            leading: Icons.timer,
            title: t.focus,
            subtitle:
                '$focusMin ${t.minutes} · $wDistr: $distractions · $w7d: $ratePct%',
            onTap: () => context.push('/focus'),
            trailingWidget: FilledButton.icon(
              onPressed: () => context.push('/focus'),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(t.start),
            ),
          );
        },
      ),
    );
  }
}

class _StatsPanel extends ConsumerWidget {
  const _StatsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final repo = ref.watch(_goalsRepoProvider);
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');

    final today = DateTime.now();
    final values = <double>[];
    for (int i = 6; i >= 0; i--) {
      final d = DateTime(today.year, today.month, today.day).subtract(Duration(days: i));
      final goals = repo.goalsForDate(d);
      if (goals.isEmpty) {
        values.add(0);
      } else {
        final done = goals.where((g) => g.isDone).length;
        values.add(done / goals.length);
      }
    }

    return _SectionCard(
      child: _RowCardButton(
        leading: Icons.bar_chart_rounded,
        title: t.stats,
        subtitle: isRu ? '7д' : '7d',
        onTap: () => context.push('/stats'),
        bottom: _SparkBar(values: values),
      ),
    );
  }
}

/// две большие кнопки как в «Резервной копии» настроек

class _QuickActionsPanel extends ConsumerWidget {
  const _QuickActionsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final s = Theme.of(context).colorScheme;
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
    final daysShort = isRu ? 'д' : 'd';

    // --- данные из репозиториев ---
    final lifeGoals = ref.watch(lifeGoalsRepoProvider).items;
    final pomoRepo = ref.watch(_pomodoroRepoProvider);

    // ============ агрегаты по LifeGoal ============
    final goalsTotal = lifeGoals.length;
    int finishedCount = 0;

    // накопления
    double totalTarget = 0, totalSaved = 0;
    // привычки
    int habitTotalDays = 0, habitStreakSum = 0;
    // спорт
    int sportStreakSum = 0;

    double sumProgress = 0;
    for (final g in lifeGoals) {
      final p = g.overallProgress.clamp(0, 1);
      sumProgress += p;
      if (p >= 1 - 1e-9) finishedCount++;

      switch (g.type) {
        case LifeGoalType.savings:
          final sd = g.savings;
          if (sd != null) {
            totalTarget += sd.targetAmount;
            totalSaved += sd.saved;
          }
          break;
        case LifeGoalType.habit:
          final hd = g.habit;
          if (hd != null) {
            habitTotalDays += hd.totalDays;
            habitStreakSum += hd.streak;
          }
          break;
        case LifeGoalType.sport:
          final sp = g.sport;
          if (sp != null) {
            sportStreakSum += sp.streak;
          }
          break;
      }
    }

    final avgProgress = goalsTotal == 0 ? 0.0 : (sumProgress / goalsTotal);
    final avgPct = (avgProgress * 100).round();

    String savingsChipText() {
      if (totalTarget <= 0) return '💰 ${lifeGoals.where((g) => g.type == LifeGoalType.savings).length}';
      final saved = totalSaved.round();
      final target = totalTarget.round();
      return '💰 $saved/$target';
    }

    String habitChipText() {
      if (habitTotalDays <= 0) {
        final cnt = lifeGoals.where((g) => g.type == LifeGoalType.habit).length;
        return '🚫 $cnt';
      }
      return '🚫 $habitStreakSum/$habitTotalDays$daysShort';
    }

    String sportChipText() {
      final cnt = lifeGoals.where((g) => g.type == LifeGoalType.sport).length;
      if (sportStreakSum <= 0) return '🏃 $cnt';
      return '🏃 $sportStreakSum$daysShort';
    }

    // ============ верстка ============
    return _SectionCard(
      child: Column(
        children: [
          // ---- Полноценная "Цели" ----
          _RowCardButton(
            leading: Icons.flag_circle_rounded,
            title: t.addGoal, // «Цель»
            subtitle: goalsTotal == 0
                ? (isRu ? 'Нет целей' : 'No goals')
                : '${avgPct}%,  ${finishedCount}/${goalsTotal}',
            onTap: () => context.push('/goals'),
            trailingWidget: Icon(Icons.chevron_right_rounded, color: s.onSurfaceVariant),
            bottom: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // общий прогресс всех целей
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: avgProgress,
                    minHeight: 10,
                    backgroundColor: s.surfaceContainerHighest.withOpacity(0.18),
                  ),
                ),
                const SizedBox(height: 8),
                // чипы по типам
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _miniChip(context, savingsChipText()),
                    _miniChip(context, habitChipText()),
                    _miniChip(context, sportChipText()),
                  ],
                ),
              ],
            ),
          ),

          // разделитель
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Divider(height: 20, color: s.outlineVariant.withOpacity(0.2)),
          ),

          // ---- Строка "Старт" (фокус за сегодня) ----
          FutureBuilder<List<dynamic>>(
            future: () async {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              return Future.wait([
                pomoRepo.totalFocusMinutesForDay(today),
                pomoRepo.totalDistractionsForDay(today),
              ]);
            }(),
            builder: (context, snap) {
              final loading = snap.connectionState != ConnectionState.done;
              final focusMin = loading ? 0 : (snap.data?[0] ?? 0) as int;
              final distractions = loading ? 0 : (snap.data?[1] ?? 0) as int;
              final wDistr = isRu ? 'Отвлечений' : 'Distractions';

              return _RowCardButton(
                leading: Icons.play_circle,
                title: t.start,
                subtitle: loading ? '…' : '$focusMin ${t.minutes} · $wDistr: $distractions',
                onTap: () => context.push('/focus'),
                trailingWidget: FilledButton.icon(
                  onPressed: () => context.push('/focus'),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(t.start),
                  style: FilledButton.styleFrom(
                    backgroundColor: s.primaryContainer.withOpacity(0.9),
                    foregroundColor: s.onPrimaryContainer,
                    side: BorderSide(color: s.primary, width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _miniChip(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(.28)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}


class _ReflectionPanel extends ConsumerWidget {
  const _ReflectionPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final repo = ref.watch(reflectionRepoProvider);
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
    final locale = Localizations.localeOf(context).toLanguageTag();

    final items = repo.lastN(1);
    dynamic last = items.isNotEmpty ? items.first : null;

    int? happiness;
    DateTime? date;
    String? note;

    try {
      happiness = (last as dynamic).happiness as int?;
    } catch (_) {}
    try {
      date = (last as dynamic).date as DateTime?;
    } catch (_) {}
    try {
      date ??= (last as dynamic).day as DateTime?;
    } catch (_) {}
    try {
      note = (last as dynamic).note as String?;
    } catch (_) {}
    try {
      note ??= (last as dynamic).comment as String?;
    } catch (_) {}

    final dateStr = date != null
        ? DateFormat('dd.MM.yyyy', locale).format(date!)
        : (isRu ? 'Нет записей' : 'No entries');

    final happyLabel = isRu ? 'Счастье' : 'Happiness';
    final subtitle =
        last == null ? (isRu ? 'Нет записей' : 'No entries') : '$dateStr · $happyLabel: ${happiness ?? '—'}';

    final s = Theme.of(context).colorScheme;

    Widget? bottom;
    if (note != null && note!.trim().isNotEmpty) {
      bottom = Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: s.surfaceContainerHighest.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: s.outlineVariant.withOpacity(0.3)),
        ),
        child: Text(
          note!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return _SectionCard(
      child: _RowCardButton(
        leading: Icons.edit_note,
        title: t.reflection,
        subtitle: subtitle,
        bottom: bottom,
        onTap: () => context.push('/reflect'),
      ),
    );
  }
}

class _NavPanel extends StatelessWidget {
  const _NavPanel();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    Widget tile({
      required IconData icon,
      required String title,
      required VoidCallback onTap,
    }) {
      return _RowCardButton(
        leading: icon,
        title: title,
        subtitle: t.open,
        onTap: onTap,
      );
    }

    final divider = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
      ),
    );

    return _SectionCard(
      child: Column(
        children: [
          tile(
            icon: Icons.psychology_alt,
            title: 'Coach',
            onTap: () => GoRouter.of(context).push('/coach'),
          ),
          divider,
          tile(
            icon: Icons.settings_applications,
            title: t.settings,
            onTap: () => GoRouter.of(context).push('/settings'),
          ),
        ],
      ),
    );
  }
}

/* -------------------- Спарк-график -------------------- */

class _SparkBar extends StatelessWidget {
  const _SparkBar({required this.values});
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    return SizedBox(
      height: 56,
      child: CustomPaint(
        painter: _SparkPainter(values, s.primary),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  _SparkPainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    if (n == 0) return;
    final barW = size.width / (n * 1.8);
    final gap = barW * 0.8;
    final paint = Paint()..color = color.withOpacity(0.55);
    for (int i = 0; i < n; i++) {
      final h = (values[i].clamp(0.0, 1.0)) * size.height;
      final x = i * (barW + gap);
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - h, barW, h),
        const Radius.circular(8),
      );
      canvas.drawRRect(r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) =>
      old.values != values || old.color != color;
}
