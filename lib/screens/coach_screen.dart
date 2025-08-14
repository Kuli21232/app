import 'dart:math';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/home_button.dart';

import '../services/ai_coach.dart';
import '../ui/adaptive.dart';
import 'home_screen.dart';            // repoProvider (цели)
import 'reflection_screen.dart';     // reflectionRepoProvider (рефлексия)
import 'package:motivego/l10n/app_localizations.dart';

import '../data/pomodoro_repository.dart'; // данные помодоро

final _pomodoroRepoProvider = Provider((ref) => PomodoroRepository());

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});
  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final repo = ref.watch(repoProvider);
    final reflections = ref.watch(reflectionRepoProvider);

    // Данные за 7 дней
    final map = repo.weeklyStats();
    final entries = map.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final weekly = [for (final e in entries) (e.value.$1, e.value.$2)];
    final doneByDay = [for (final e in entries) e.value.$2];

    final lastReflections = reflections.lastN(7);
    final happiness = [for (final r in lastReflections) r.happiness];

    final byPriority = repo.weeklyPriorityBreakdown();

    final report = makeAdvice(
      t: t,
      weekly: weekly,
      happiness: happiness,
      priority7: byPriority,
      doneByDay: doneByDay,
      seed: DateTime.now().day,
    );

    String trendLabel(double v) =>
        v > 0.05 ? t.trendUp : (v < -0.05 ? t.trendDown : t.trendStable);

    // Локальные RU/EN подписи без ARB
    String tr(String ru, String en) =>
        (t as dynamic).localeName?.toString().toLowerCase().startsWith('ru') == true ? ru : en;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: const [HomeButton()],
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
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(color: Colors.black.withOpacity(0.06)),
              ),
            ],
          ),
        ),
        title: Text(t.coachTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(76),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: CenteredContent(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 260, maxWidth: 480),
                  child: _PillTabBar(
                    controller: _tab,
                    tabs: const [],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0E1A), Color(0xFF16142A)],
          ),
        ),
        child: CenteredContent(
          child: TabBarView(
            controller: _tab,
            physics: const BouncingScrollPhysics(),
            children: [
              // ===== Советы =====
              ListView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                children: [
                  // KPI блок — компактные «пилюли»
                  _CoachSectionCard(
                    title: t.coachSummary7d,
                    child: _KpiWrap(children: [
                      _KpiPill(label: t.coachKpiCompletion, value: '${(report.completionOverall * 100).round()}%'),
                      _KpiPill(label: t.coachKpiStreak,     value: '${report.streakDays} ${t.daysShort}'),
                      _KpiPill(label: t.coachKpiBalance,    value: '${(report.balanceScore * 100).round()}%'),
                      _KpiPill(label: t.coachKpiTrend,      value: trendLabel(report.trend)),
                      _KpiPill(label: t.coachKpiHappiness,  value: '${report.happinessAvg}'),
                      _KpiPill(label: tr('Консистентность', 'Consistency'),
                               value: '${(report.consistency * 100).round()}%'),
                      _KpiPill(label: tr('Риск выгорания', 'Burnout risk'),
                               value: '${(report.burnoutRisk * 100).round()}%'),
                    ]),
                  ),
                  const SizedBox(height: 12),

                  // Персона
                  _PersonaCard(persona: report.persona, risk: report.burnoutRisk),

                  const SizedBox(height: 12),

                  // Рекомендации (фокус/объём дня)
                  _PlanHintsCard(
                    focusMin: report.suggestedFocusMin,
                    tasksPerDay: report.suggestedDailyPlan,
                    tr: tr,
                  ),

                  const SizedBox(height: 12),

                  // Фокус / Помодоро
                  const CoachFocusSection(),

                  const SizedBox(height: 12),

                  // Разбивка по приоритетам
                  _CoachSectionCard(
                    title: t.coachPriority7dTitle,
                    child: Column(
                      children: [
                        for (final m in report.byPriority)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 36,
                                  child: Text(
                                    'P${m.priority}',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: (m.completion).clamp(0.0, 1.0),
                                      minHeight: 10,
                                      backgroundColor: Colors.white.withOpacity(0.15),
                                      valueColor: const AlwaysStoppedAnimation(Color(0xFF6C4DFF)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('${m.done}/${m.planned}',
                                    style: Theme.of(context).textTheme.labelMedium),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Советы AI (tips)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(t.coachNextStepsTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  ...report.tips.map(
                    (tip) => Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: const Icon(Icons.tips_and_updates_rounded),
                        title: Text(tip.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text(tip.body),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Action plan (конкретные шаги)
                  _CoachSectionCard(
                    title: tr('План действий', 'Action plan'),
                    child: Column(
                      children: [
                        for (final s in report.actionPlan)
                          ListTile(
                            dense: true,
                            leading: const Icon(Icons.check_circle_outline),
                            title: Text(s),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: const VisualDensity(vertical: -2),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    t.coachAdviceFrom7dNote,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                ],
              ),

              // ===== Мотивация =====
              const _MotivationTab(),
            ],
          ),
        ),
      ),
    );
  }
}

/// KPI «пилюля»
class _KpiPill extends StatelessWidget {
  const _KpiPill({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outline.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

/// Обёртка KPI — переносится и выравнивается красиво на узких экранах
class _KpiWrap extends StatelessWidget {
  const _KpiWrap({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final spacing = c.maxWidth < 360 ? 8.0 : 10.0;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children,
        );
      },
    );
  }
}

/// Универсальная карточка секции
class _CoachSectionCard extends StatelessWidget {
  const _CoachSectionCard({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

/// Персона + риск
class _PersonaCard extends StatelessWidget {
  const _PersonaCard({required this.persona, required this.risk});
  final String persona;
  final double risk;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3E2C8A), Color(0xFF6C4DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                persona,
                style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (Localizations.localeOf(context).languageCode.startsWith('ru'))
                        ? 'Риск выгорания'
                        : 'Burnout risk',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: risk.clamp(0, 1),
                      minHeight: 10,
                      backgroundColor: scheme.surfaceContainerHighest.withOpacity(0.4),
                      valueColor: AlwaysStoppedAnimation(
                        Color.lerp(const Color(0xFF3CD856), const Color(0xFFFF4D67), risk.clamp(0,1))!,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text('${(risk * 100).round()}%', style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

/// Карточка с предложениями по интервалу фокуса и дневному объёму
class _PlanHintsCard extends StatelessWidget {
  const _PlanHintsCard({
    required this.focusMin,
    required this.tasksPerDay,
    required this.tr,
  });
  final int focusMin;
  final int tasksPerDay;
  final String Function(String ru, String en) tr;

  @override
  Widget build(BuildContext context) {
    return _CoachSectionCard(
      title: tr('Рекомендации', 'Recommendations'),
      child: Row(
        children: [
          Expanded(
            child: _KpiMini(
              title: tr('Интервал фокуса', 'Focus interval'),
              value: '$focusMin ${tr("мин", "min")}',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _KpiMini(
              title: tr('Задач/день', 'Tasks/day'),
              value: '$tasksPerDay',
            ),
          ),
        ],
      ),
    );
  }
}

class CoachFocusSection extends ConsumerWidget {
  const CoachFocusSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final repo = ref.read(_pomodoroRepoProvider);
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder(
      future: Future.wait([
        repo.totalFocusMinutesForDay(DateTime.now()),
        repo.totalDistractionsForDay(DateTime.now()),
        repo.completionRateLast7Days(),
      ]),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
          );
        }
        final minutes = snap.data![0] as int;
        final distractions = snap.data![1] as int;
        final rate = snap.data![2] as double;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.focusTodayCard, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                // KPI-ряд — всегда помещается
                Row(
                  children: [
                    Expanded(child: _KpiMini(title: t.focusToday,      value: t.minutesLabel(minutes))),
                    const SizedBox(width: 10),
                    Expanded(child: _KpiMini(title: t.distractions,     value: '$distractions')),
                    const SizedBox(width: 10),
                    Expanded(child: _KpiMini(title: t.completion7d,    value: '${(rate * 100).round()}%')),
                  ],
                ),
                const SizedBox(height: 12),
                // Совет от ИИ с иконкой
                FutureBuilder<String>(
                  future: AiCoach.instance.pomodoroAdvice(
                    t: t,
                    focusMinutesToday: minutes,
                    completionRate7d: rate,
                    distractionsToday: distractions,
                  ),
                  builder: (_, advice) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.tips_and_updates, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            advice.data ?? t.adviceLoading,
                            key: ValueKey(advice.data ?? 'loading'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Мягкий фон-панель для контента помодоро (placeholder)
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.outline.withOpacity(0.2)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    t.focusTodayCard,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Компактная KPI-плитка в 3 колонки
class _KpiMini extends StatelessWidget {
  const _KpiMini({required this.title, required this.value});
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.labelMedium),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: theme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MotivationTab extends StatefulWidget {
  const _MotivationTab();
  @override
  State<_MotivationTab> createState() => _MotivationTabState();
}

class _MotivationTabState extends State<_MotivationTab> {
  late List<String> _items;

  List<String> _pickRandom(BuildContext context, int n) {
    final r = Random(DateTime.now().millisecondsSinceEpoch);
    final pool = [...motivationPhrases(AppLocalizations.of(context)!)];
    pool.shuffle(r);
    return pool.take(n).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _items = _pickRandom(context, 8));
    });
    _items = const [];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final items = _items.isEmpty ? motivationPhrases(t).take(8).toList() : _items;

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items
              .map((s) => Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('“$s”'),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        Center(
          child: FilledButton.icon(
            onPressed: () => setState(() => _items = _pickRandom(context, 8)),
            icon: const Icon(Icons.refresh),
            label: Text(t.motivationRefresh),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// ---------------- UI: pill TabBar ----------------

class _PillTabBar extends StatelessWidget {
  final TabController controller;
  final List<Widget> tabs;
  const _PillTabBar({required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // компактные размеры как в StatsScreen
    const double tabVisualHeight = 34;
    const double outerPadding = 6;
    const double pillHeight    = 46;

    final ts = MediaQuery.of(context).textScaleFactor;
    final capTs = ts > 1.2 ? 1.2 : ts;
    final labelStyle =
        (textTheme.labelMedium ?? const TextStyle()).copyWith(fontSize: 12.5 / capTs, height: 1.05);

    final t = AppLocalizations.of(context)!;
    final tabWidgets = <Widget>[
      Tab(child: _TabLabel(icon: Icons.tips_and_updates, label: t.coachTips)),
      Tab(child: _TabLabel(icon: Icons.format_quote,    label: t.coachMotivation)),
    ];

    return Center(
      child: Container(
        height: pillHeight,
        padding: const EdgeInsets.all(outerPadding),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          labelStyle: labelStyle,
          unselectedLabelStyle: labelStyle,
          dividerColor: Colors.transparent,
          dividerHeight: 0,
          tabs: tabWidgets
              .map((w) => SizedBox(height: tabVisualHeight, child: Center(child: w)))
              .toList(),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF3E2C8A), Color(0xFF6C4DFF)],
            ),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(vertical: 1.5),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
        ),
      ),
    );
  }
}

/// Горизонтальная подпись вкладки: иконка + текст.
class _TabLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TabLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
      ],
    );
  }
}
