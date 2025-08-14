import 'dart:ui' show ImageFilter; // для BackdropFilter.blur

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import 'home_screen.dart'; // repoProvider
import '../ui/adaptive.dart';
import '../data/pomodoro_repository.dart';

import 'package:intl/intl.dart';
import 'package:motivego/l10n/app_localizations.dart';

// Локальный провайдер репозитория Помодоро
final _pomodoroRepoProvider = Provider((ref) => PomodoroRepository());

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});
  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
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
    final data = repo.weeklyStats();
    final entries = data.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    final plannedSum = entries.fold<int>(0, (p, e) => p + e.value.$1);
    final doneSum = entries.fold<int>(0, (p, e) => p + e.value.$2);
    final remaining = (plannedSum - doneSum).clamp(0, 1 << 30);

    return Scaffold(
      appBar: AppBar(
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
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(color: Colors.black.withOpacity(0.06)),
              ),
            ],
          ),
        ),
        title: Text(t.statsTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: t.coachTips,
            onPressed: () => context.push('/coach'),
            icon: const Icon(Icons.lightbulb),
          ),
        ],
        bottom: PreferredSize(
          // запас по высоте, чтобы исключить любые overflow при масштабах шрифта
          preferredSize: const Size.fromHeight(76),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 260,
                    maxWidth: 480,
                  ),
                  child: _PillTabBar(
                    controller: _tab,
                    tabs: [
                      Tab(child: _TabLabel(icon: Icons.pie_chart,    label: t.overviewTab)),
                      Tab(child: _TabLabel(icon: Icons.view_week,    label: t.weekTab)),
                      Tab(child: _TabLabel(icon: Icons.show_chart,   label: t.trendTab)),
                    ],
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
              _OverviewTab(plannedSum: plannedSum, doneSum: doneSum, remaining: remaining),
              _WeekBreakdownTab(entries: entries),
              _TrendTab(entries: entries),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- Overview ----------------

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({required this.plannedSum, required this.doneSum, required this.remaining});
  final int plannedSum;
  final int doneSum;
  final int remaining;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final progress = plannedSum == 0 ? 0.0 : doneSum / plannedSum;
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        Hero(
          tag: 'progressHero',
          child: Card(
            elevation: 0,
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            color: Theme.of(context).colorScheme.surface.withOpacity(0.92),
            child: SizedBox(
              height: 78, // компактнее
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => SizedBox(
                        width: 56, height: 56,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: value,
                              strokeWidth: 5,
                              backgroundColor: scheme.surfaceContainerHighest.withOpacity(0.35),
                              valueColor: const AlwaysStoppedAnimation(Color(0xFF6C4DFF)),
                            ),
                            Text('${(value * 100).round()}%'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.progress7d, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeOutCubic,
                            child: Text(
                              t.doneOfPlanned(doneSum, plannedSum),
                              key: ValueKey('$doneSum/$plannedSum'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        const PomodoroStatsCard(),

        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.distribution, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200, // было 220
                  child: PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      centerSpaceRadius: 56,
                      sectionsSpace: 2,
                      pieTouchData: PieTouchData(enabled: true),
                      sections: [
                        PieChartSectionData(
                          value: doneSum.toDouble(),
                          title: doneSum == 0 ? '' : '$doneSum',
                          radius: 70,
                          color: Theme.of(context).colorScheme.primary,
                          titleStyle: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                        ),
                        PieChartSectionData(
                          value: remaining.toDouble(),
                          title: remaining == 0 ? '' : '$remaining',
                          radius: 70,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                          titleStyle: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 650),
                    swapAnimationCurve: Curves.easeOutCubic,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _LegendDot(label: t.legendDone, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 16),
                    _LegendDot(label: t.legendRemaining, color: Theme.of(context).colorScheme.primary.withOpacity(0.25)),
                  ],
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // KPI всегда в один ряд — компактные
        Row(
          children: [
            Expanded(child: _KpiCard(title: t.kpiTotalTasks, value: '$plannedSum', minHeight: 64)),
            const SizedBox(width: 12),
            Expanded(child: _KpiCard(title: t.kpiDone, value: '$doneSum', minHeight: 64)),
            const SizedBox(width: 12),
            Expanded(child: _KpiCard(title: t.kpiRemaining, value: '$remaining', minHeight: 64)),
          ],
        ),
      ],
    );
  }
}

/// ---------------- Pomodoro card ----------------

class PomodoroStatsCard extends ConsumerWidget {
  const PomodoroStatsCard({super.key});

  Future<List<int>> _last7DaysMinutes(PomodoroRepository repo) async {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return DateTime(d.year, d.month, d.day);
    });
    final mins = <int>[];
    for (final d in days) {
      mins.add(await repo.totalFocusMinutesForDay(d));
    }
    return mins;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final repo = ref.read(_pomodoroRepoProvider);
    final scheme = Theme.of(context).colorScheme;
    final localeTag = Localizations.localeOf(context).toLanguageTag();

    return FutureBuilder(
      future: Future.wait([
        repo.totalFocusMinutesForDay(DateTime.now()), // 0
        repo.totalDistractionsForDay(DateTime.now()), // 1
        repo.completionRateLast7Days(),               // 2
        _last7DaysMinutes(repo),                      // 3
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
        final minutesToday = snap.data![0] as int;
        final distractions = snap.data![1] as int;
        final rate = snap.data![2] as double;
        final last7 = (snap.data![3] as List<int>);

        final groups = [
          for (var i = 0; i < last7.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: last7[i].toDouble(),
                  width: 10,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  color: scheme.primary,
                ),
              ],
            )
        ];

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.focusCardTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),

                // KPI — компактные
                Row(
                  children: [
                    Expanded(child: _KpiCard(title: t.focusToday, value: t.minutesLabel(minutesToday), minHeight: 64)),
                    const SizedBox(width: 12),
                    Expanded(child: _KpiCard(title: t.distractions, value: '$distractions', minHeight: 64)),
                    const SizedBox(width: 12),
                    Expanded(child: _KpiCard(title: t.completion7d, value: '${(rate * 100).round()}%', minHeight: 64)),
                  ],
                ),

                const SizedBox(height: 12),

                // Фон под график помодоро — компактный
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.outline.withOpacity(0.2)),
                  ),
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                  child: BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, meta) {
                              final i = v.toInt();
                              if (i < 0 || i >= last7.length) return const SizedBox.shrink();
                              final today = DateTime.now();
                              final d = DateTime(today.year, today.month, today.day)
                                  .subtract(Duration(days: (last7.length - 1 - i)));
                              final label = DateFormat.E(localeTag).format(d); // Пн / Mon
                              return Text(label, style: Theme.of(context).textTheme.labelSmall);
                            },
                          ),
                        ),
                      ),
                      barGroups: groups,
                      barTouchData: BarTouchData(enabled: true),
                    ),
                    swapAnimationDuration: const Duration(milliseconds: 600),
                    swapAnimationCurve: Curves.easeOutCubic,
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

/// ---------------- Shared small widgets ----------------

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 14, height: 14, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
      const SizedBox(width: 6),
      Text(label),
    ]);
  }
}

// KPI: компактная минимальная высота + защита от «столбиков»
class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.title, required this.value, this.minHeight = 64});
  final String title;
  final String value;
  final double minHeight;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.labelMedium,
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value, style: theme.headlineSmall),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------------- Week breakdown ----------------

class _WeekBreakdownTab extends StatelessWidget {
  const _WeekBreakdownTab({required this.entries});
  final List<MapEntry<DateTime, (int planned, int done)>> entries;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final localeTag = Localizations.localeOf(context).toLanguageTag();

    final maxPlanned = entries.isEmpty
        ? 1
        : entries.map((e) => e.value.$1).reduce((a, b) => a > b ? a : b);
    final maxY = (maxPlanned + 1).toDouble();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) => const FlLine(strokeWidth: .6),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 24,
                getTitlesWidget: (v, meta) {
                  if (v % 1 != 0) return const SizedBox.shrink();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4,
                    child: Text(
                      v.toInt().toString(),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                  final d = entries[i].key;
                  final label = DateFormat('dd.MM', localeTag).format(d);
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(label, style: Theme.of(context).textTheme.labelSmall),
                  );
                },
              ),
            ),
          ),
          maxY: maxY,
          barGroups: [
            for (var i = 0; i < entries.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: entries[i].value.$1.toDouble(),
                    rodStackItems: [
                      BarChartRodStackItem(
                        0,
                        entries[i].value.$2.toDouble(),
                        scheme.primary, // сделано
                      ),
                      BarChartRodStackItem(
                        entries[i].value.$2.toDouble(),
                        entries[i].value.$1.toDouble(),
                        scheme.primary.withOpacity(0.25), // осталось
                      ),
                    ],
                    width: 18,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              ),
          ],
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final e = entries[groupIndex];
                final d = DateFormat('dd.MM', localeTag).format(e.key);
                final plannedLabel = t.kpiTotalTasks;
                final doneLabel = t.kpiDone;
                return BarTooltipItem(
                  '$d\n',
                  DefaultTextStyle.of(context).style.copyWith(fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: '$plannedLabel: ${e.value.$1}\n'),
                    TextSpan(text: '$doneLabel: ${e.value.$2}'),
                  ],
                );
              },
            ),
          ),
        ),
        swapAnimationDuration: const Duration(milliseconds: 650),
        swapAnimationCurve: Curves.easeOutCubic,
      ),
    );
  }
}

/// ---------------- Trend ----------------

class _TrendTab extends StatelessWidget {
  const _TrendTab({required this.entries});
  final List<MapEntry<DateTime, (int planned, int done)>> entries;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final localeTag = Localizations.localeOf(context).toLanguageTag();

    final maxY = (entries.isEmpty
            ? 1
            : entries
                .map((e) => e.value.$1 > e.value.$2 ? e.value.$1 : e.value.$2)
                .reduce((a, b) => a > b ? a : b))
        .toDouble();

    Widget leftTitle(double v, TitleMeta meta) {
      if (v % 1 != 0) return const SizedBox.shrink();
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 4,
        child: Text(v.toInt().toString(),
            style: Theme.of(context).textTheme.labelSmall),
      );
    }

    Widget bottomTitle(double v, TitleMeta meta) {
      final i = v.toInt();
      if (i < 0 || i >= entries.length) return const SizedBox.shrink();
      final d = entries[i].key;
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 6,
        child: Text(DateFormat('dd.MM', localeTag).format(d),
            style: Theme.of(context).textTheme.labelSmall),
      );
    }

    final plannedSpots = <FlSpot>[
      for (var i = 0; i < entries.length; i++)
        FlSpot(i.toDouble(), entries[i].value.$1.toDouble()),
    ];
    final doneSpots = <FlSpot>[
      for (var i = 0; i < entries.length; i++)
        FlSpot(i.toDouble(), entries[i].value.$2.toDouble()),
    ];

    // ключ для мягкой смены данных
    final switchKey = ValueKey('${entries.length}-${entries.isEmpty ? 0 : entries.last.value}');

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, .03), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
        child: SizedBox(
          key: switchKey,
          child: LineChart(
            LineChartData(
              clipData: const FlClipData.all(),
              minX: 0,
              maxX: (entries.isEmpty ? 0 : entries.length - 1).toDouble(),
              minY: 0,
              maxY: maxY + 1,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                verticalInterval: 1,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (_) => const FlLine(strokeWidth: 0.5),
                getDrawingVerticalLine:   (_) => const FlLine(strokeWidth: 0.5),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true, reservedSize: 28, interval: 1,
                    getTitlesWidget: leftTitle,
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true, interval: 1, getTitlesWidget: bottomTitle,
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchSpotThreshold: 18,
                touchTooltipData: LineTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  tooltipRoundedRadius: 10,
                  tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  // один тултип с «Выполнено / Всего»
                  getTooltipItems: (spots) {
                    if (entries.isEmpty) return [];
                    final i = spots.first.x.round().clamp(0, entries.length - 1);
                    final d = entries[i].key;
                    final plannedVal = entries[i].value.$1;
                    final doneVal = entries[i].value.$2;
                    final t = AppLocalizations.of(context)!;
                    final style = DefaultTextStyle.of(context).style;
                    final text =
                        '${DateFormat('dd.MM', localeTag).format(d)}\n'
                        '${t.kpiDone}: $doneVal\n${t.kpiTotalTasks}: $plannedVal';
                    return [
                      LineTooltipItem(text, style),
                      for (var k = 1; k < spots.length; k++) LineTooltipItem('', style),
                    ];
                  },
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  curveSmoothness: 0.18,
                  barWidth: 3,
                  color: scheme.primary.withOpacity(0.35),
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(radius: 3, color: scheme.primary.withOpacity(0.35)),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [scheme.primary.withOpacity(0.18), Colors.transparent],
                    ),
                  ),
                  spots: plannedSpots,
                ),
                LineChartBarData(
                  isCurved: true,
                  curveSmoothness: 0.18,
                  barWidth: 3,
                  color: scheme.primary,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(radius: 3, color: scheme.primary),
                  ),
                  spots: doneSpots,
                ),
              ],
            ),
          ),
        ),
      ),
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

    // компактные размеры
    const double tabVisualHeight = 34; // высота вкладки
    const double outerPadding = 6;     // внутренний отступ «пилюли»
    const double pillHeight    = 46;   // общая высота «пилюли»

    // ограничиваем влияние огромных системных шрифтов на высоту
    final ts = MediaQuery.of(context).textScaleFactor;
    final capTs = ts > 1.2 ? 1.2 : ts;
    final labelStyle = (textTheme.labelMedium ?? const TextStyle())
        .copyWith(fontSize: 12.5 / capTs, height: 1.05);

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

          // --- убираем тонкую полоску под вкладками ---
          dividerColor: Colors.transparent,
          dividerHeight: 0,
          // -------------------------------------------

          tabs: tabs
              .map((t) => SizedBox(height: tabVisualHeight, child: Center(child: t)))
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


/// Горизонтальная «таб-чипка»: иконка + текст в один ряд (без вертикальной колонки).
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
