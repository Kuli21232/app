import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/pomodoro_repository.dart';
import '../models/pomodoro_session.dart';
import '../services/ai_coach.dart';
import 'package:motivego/l10n/app_localizations.dart';
import '../ui/home_button.dart';

// DI
final pomodoroRepoProvider = Provider((ref) => PomodoroRepository());

// настройки (можно менять на экране)
class PomodoroSettings {
  final int focusMin;
  final int breakMin;
  final int cycles;

  const PomodoroSettings({this.focusMin = 25, this.breakMin = 5, this.cycles = 4});

  PomodoroSettings copyWith({int? focusMin, int? breakMin, int? cycles}) =>
      PomodoroSettings(
        focusMin: focusMin ?? this.focusMin,
        breakMin: breakMin ?? this.breakMin,
        cycles: cycles ?? this.cycles,
      );
}

enum PomodoroPhase { focus, break_, idle }

class PomodoroState {
  final PomodoroSettings settings;
  final PomodoroPhase phase;
  final int secondsLeft;
  final int currentCycle; // 1..settings.cycles
  final bool running;
  final int distractions;

  int get totalSeconds =>
      (phase == PomodoroPhase.focus ? settings.focusMin : settings.breakMin) * 60;

  double get progress => totalSeconds == 0 ? 0 : 1 - (secondsLeft / totalSeconds);

  const PomodoroState({
    required this.settings,
    required this.phase,
    required this.secondsLeft,
    required this.currentCycle,
    required this.running,
    required this.distractions,
  });

  factory PomodoroState.initial() => const PomodoroState(
        settings: PomodoroSettings(),
        phase: PomodoroPhase.idle,
        secondsLeft: 25 * 60,
        currentCycle: 1,
        running: false,
        distractions: 0,
      );

  PomodoroState copyWith({
    PomodoroSettings? settings,
    PomodoroPhase? phase,
    int? secondsLeft,
    int? currentCycle,
    bool? running,
    int? distractions,
  }) =>
      PomodoroState(
        settings: settings ?? this.settings,
        phase: phase ?? this.phase,
        secondsLeft: secondsLeft ?? this.secondsLeft,
        currentCycle: currentCycle ?? this.currentCycle,
        running: running ?? this.running,
        distractions: distractions ?? this.distractions,
      );
}

class PomodoroController extends StateNotifier<PomodoroState> {
  PomodoroController(this._repo) : super(PomodoroState.initial());
  final PomodoroRepository _repo;
  Timer? _timer;
  DateTime? _startedAt;
  int _focusAccumSec = 0;
  int _breakAccumSec = 0;

  void setSettings(PomodoroSettings s) {
    final sec = s.focusMin * 60;
    state = state.copyWith(
      settings: s,
      secondsLeft: sec,
      phase: PomodoroPhase.idle,
      currentCycle: 1,
    );
  }

  void startFocus() {
    _startedAt = DateTime.now();
    state = state.copyWith(
      phase: PomodoroPhase.focus,
      secondsLeft: state.settings.focusMin * 60,
      running: true,
    );
    _tick();
  }

  void _tick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!state.running) return;
      final left = state.secondsLeft - 1;
      if (state.phase == PomodoroPhase.focus) _focusAccumSec++;
      if (state.phase == PomodoroPhase.break_) _breakAccumSec++;

      if (left <= 0) {
        if (state.phase == PomodoroPhase.focus) {
          state = state.copyWith(
            phase: PomodoroPhase.break_,
            secondsLeft: state.settings.breakMin * 60,
          );
        } else {
          final nextCycle = state.currentCycle + 1;
          if (nextCycle > state.settings.cycles) {
            _finishSession(completed: true);
            return;
          } else {
            state = state.copyWith(
              phase: PomodoroPhase.focus,
              currentCycle: nextCycle,
              secondsLeft: state.settings.focusMin * 60,
            );
          }
        }
      } else {
        state = state.copyWith(secondsLeft: left);
      }
    });
  }

  void pause() => state = state.copyWith(running: false);
  void resume() {
    state = state.copyWith(running: true);
    _tick();
  }

  void reset() {
    _timer?.cancel();
    _focusAccumSec = 0;
    _breakAccumSec = 0;
    _startedAt = null;
    state = PomodoroState.initial().copyWith(settings: state.settings);
  }

  void addDistraction() => state = state.copyWith(distractions: state.distractions + 1);

  Future<void> _finishSession({required bool completed}) async {
    _timer?.cancel();
    final sess = PomodoroSession(
      start: _startedAt ?? DateTime.now(),
      focusMinutes: (_focusAccumSec / 60).round(),
      breakMinutes: (_breakAccumSec / 60).round(),
      completed: completed,
      distractions: state.distractions,
    );
    await _repo.add(sess);
    _focusAccumSec = 0;
    _breakAccumSec = 0;
    _startedAt = null;
    state = state.copyWith(
      phase: PomodoroPhase.idle,
      running: false,
      secondsLeft: state.settings.focusMin * 60,
    );
  }
}

final pomodoroControllerProvider =
    StateNotifierProvider<PomodoroController, PomodoroState>((ref) {
  final repo = ref.watch(pomodoroRepoProvider);
  return PomodoroController(repo);
});

class PomodoroScreen extends ConsumerWidget {
  const PomodoroScreen({super.key});

  String _mmss(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final st = ref.watch(pomodoroControllerProvider);
    final ctrl = ref.read(pomodoroControllerProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(t.tabFocus),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          const HomeButton(), // домой
          IconButton(
            tooltip: t.pomo_distractions,
            onPressed: st.phase == PomodoroPhase.idle ? null : ctrl.addDistraction,
            icon: const Icon(Icons.earbuds_battery),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f172a), Color(0xFF1e293b)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              const _DecorAndSettingsBar(),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: _CircleTimer(
                    progress: st.progress,
                    label: st.phase == PomodoroPhase.break_
                        ? t.pomo_break
                        : (st.phase == PomodoroPhase.focus ? t.pomo_focus : t.pomo_ready),
                    time: _mmss(st.secondsLeft),
                    cycle: st.currentCycle,
                    totalCycles: st.settings.cycles,
                  ),
                ),
              ),
              const _ActionBar(),
              const SizedBox(height: 8),
              const _AdviceCard(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Декоративная панель + кнопка настроек.
/// Адаптация:
/// - <=360px: один компактный «сводный» чип (25/5 • ×4) + ⚙
/// - 361–420px: чипы автоматически переносятся (Wrap)
/// - >420px: три чипа в ряд.
class _DecorAndSettingsBar extends ConsumerWidget {
  const _DecorAndSettingsBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final st = ref.watch(pomodoroControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final isCompact = w <= 360;
          final needsWrap = w > 360 && w <= 420;

          Widget settingsBtn = const _SettingsButton();

          return Card(
            color: Colors.white.withOpacity(0.05),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: isCompact
                  ? Row(
                      children: [
                        _SummaryPill(
                          focus: st.settings.focusMin,
                          brk: st.settings.breakMin,
                          cycles: st.settings.cycles,
                        ),
                        const Spacer(),
                        settingsBtn,
                      ],
                    )
                  : needsWrap
                      ? Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _DecorChip(
                              icon: Icons.timer,
                              label: t.pomo_focus,
                              value: '${st.settings.focusMin} min',
                            ),
                            _DecorChip(
                              icon: Icons.coffee,
                              label: t.pomo_break,
                              value: '${st.settings.breakMin} min',
                            ),
                            _DecorChip(
                              icon: Icons.all_inclusive,
                              label: t.pomo_cycles,
                              value: '${st.settings.cycles}',
                            ),
                            settingsBtn,
                          ],
                        )
                      : Row(
                          children: [
                            _DecorChip(
                              icon: Icons.timer,
                              label: t.pomo_focus,
                              value: '${st.settings.focusMin} min',
                            ),
                            const SizedBox(width: 8),
                            _DecorChip(
                              icon: Icons.coffee,
                              label: t.pomo_break,
                              value: '${st.settings.breakMin} min',
                            ),
                            const SizedBox(width: 8),
                            _DecorChip(
                              icon: Icons.all_inclusive,
                              label: t.pomo_cycles,
                              value: '${st.settings.cycles}',
                            ),
                            const Spacer(),
                            settingsBtn,
                          ],
                        ),
            ),
          );
        },
      ),
    );
  }
}

/// Компактная сводка для узких экранов: 25/5 • ×4
class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.focus,
    required this.brk,
    required this.cycles,
  });

  final int focus;
  final int brk;
  final int cycles;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0x22FFFFFF), Color(0x11000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timelapse, size: 16, color: Colors.white70),
          const SizedBox(width: 6),
          Text('$focus/$brk • ×$cycles',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }
}

class _DecorChip extends StatelessWidget {
  const _DecorChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0x22FFFFFF), Color(0x11000000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Кнопка «шестерёнка», открывающая шторку с настройками.
class _SettingsButton extends ConsumerWidget {
  const _SettingsButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    return Tooltip(
      message: t.settingsTitle,
      child: IconButton.filledTonal(
        onPressed: () => _openFocusSettingsSheet(context, ref, t),
        icon: const Icon(Icons.settings),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  void _openFocusSettingsSheet(
      BuildContext context, WidgetRef ref, AppLocalizations t) {
    final st = ref.read(pomodoroControllerProvider);
    final ctrl = ref.read(pomodoroControllerProvider.notifier);

    int focus = st.settings.focusMin;
    int brk = st.settings.breakMin;
    int cyc = st.settings.cycles;

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: const Color(0xFF0b1223),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            Widget row({
              required IconData icon,
              required String label,
              required int value,
              required void Function() onMinus,
              required void Function() onPlus,
            }) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.white70, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(label,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                    _MiniIconBtn(icon: Icons.remove, onTap: onMinus),
                    const SizedBox(width: 8),
                    Text('$value',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    _MiniIconBtn(icon: Icons.add, onTap: onPlus),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.settingsTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  row(
                    icon: Icons.timer,
                    label: t.pomo_focus,
                    value: focus,
                    onMinus: () => setState(() => focus = (focus - 1).clamp(5, 60)),
                    onPlus: () => setState(() => focus = (focus + 1).clamp(5, 60)),
                  ),
                  row(
                    icon: Icons.coffee,
                    label: t.pomo_break,
                    value: brk,
                    onMinus: () => setState(() => brk = (brk - 1).clamp(3, 20)),
                    onPlus: () => setState(() => brk = (brk + 1).clamp(3, 20)),
                  ),
                  row(
                    icon: Icons.all_inclusive,
                    label: t.pomo_cycles,
                    value: cyc,
                    onMinus: () => setState(() => cyc = (cyc - 1).clamp(1, 8)),
                    onPlus: () => setState(() => cyc = (cyc + 1).clamp(1, 8)),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(t.cancel),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            ctrl.setSettings(
                              st.settings.copyWith(
                                focusMin: focus,
                                breakMin: brk,
                                cycles: cyc,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: Text(t.save),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MiniIconBtn extends StatelessWidget {
  const _MiniIconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: const SizedBox(
          width: 34,
          height: 34,
          child: Icon(Icons.add, size: 18, color: Colors.white),
        ),
      ),
    ).copyWithIcon(icon);
  }
}

// маленький хелпер, чтобы заменить иконку в Ink с SizedBox
extension on Ink {
  Widget copyWithIcon(IconData iconData) {
    final box = (child as InkWell).child as SizedBox;
    return Ink(
      decoration: decoration,
      child: InkWell(
        borderRadius: (child as InkWell).borderRadius,
        onTap: (child as InkWell).onTap,
        child: SizedBox(
          width: box.width,
          height: box.height,
          child: Icon(iconData, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _CircleTimer extends StatelessWidget {
  final double progress; // 0..1
  final String label;
  final String time;
  final int cycle;
  final int totalCycles;

  const _CircleTimer({
    required this.progress,
    required this.label,
    required this.time,
    required this.cycle,
    required this.totalCycles,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final w = MediaQuery.of(context).size.width;
    final size = w < 360 ? 220.0 : 260.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, _) {
        return CustomPaint(
          painter: _RingPainter(value),
          child: SizedBox(
            width: size,
            height: size,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70)),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: w < 360 ? 44 : 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text('${t.pomo_cycles} $cycle / $totalCycles',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = min(size.width, size.height) / 2 - 10;

    final bg = Paint()
      ..color = const Color(0x22FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final fg = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF22d3ee), Color(0xFFa78bfa)],
      ).createShader(Rect.fromCircle(center: c, radius: r))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(c, r, bg);
    final sweep = 2 * pi * progress;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -pi / 2, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

class _ActionBar extends ConsumerWidget {
  const _ActionBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(pomodoroControllerProvider);
    final ctrl = ref.read(pomodoroControllerProvider.notifier);
    final isNarrow = MediaQuery.of(context).size.width < 360;

    final startLabel =
        st.phase == PomodoroPhase.idle ? 'Старт' : (st.running ? 'Пауза' : 'Продолжить');

    final startBtn = ElevatedButton.icon(
      icon: Icon(
        st.phase == PomodoroPhase.idle
            ? Icons.play_arrow
            : (st.running ? Icons.pause : Icons.play_arrow),
        size: 20,
      ),
      label: Text(startLabel, style: const TextStyle(fontSize: 14)),
      onPressed: () {
        if (st.phase == PomodoroPhase.idle) {
          ctrl.startFocus();
        } else if (st.running) {
          ctrl.pause();
        } else {
          ctrl.resume();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF22c55e),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: EdgeInsets.symmetric(vertical: isNarrow ? 8 : 10, horizontal: 10),
        minimumSize: const Size(0, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );

    final resetBtn = IconButton.filledTonal(
      onPressed: ctrl.reset,
      icon: const Icon(Icons.refresh),
      iconSize: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      visualDensity: VisualDensity.compact,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: isNarrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                startBtn,
                const SizedBox(height: 6),
                Align(alignment: Alignment.centerRight, child: resetBtn),
              ],
            )
          : Row(
              children: [
                Expanded(child: startBtn),
                const SizedBox(width: 8),
                resetBtn,
              ],
            ),
    );
  }
}

class _AdviceCard extends ConsumerWidget {
  const _AdviceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    return FutureBuilder<String>(
      future: _pomodoroAdvice(ref, t),
      builder: (c, snap) {
        final text = snap.data ?? '${t.coachTips}…';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            color: Colors.white.withOpacity(0.06),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.tips_and_updates, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(child: Text(text, style: const TextStyle(color: Colors.white))),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String> _pomodoroAdvice(WidgetRef ref, AppLocalizations t) async {
    final repo = ref.read(pomodoroRepoProvider);
    final minutesToday = await repo.totalFocusMinutesForDay(DateTime.now());
    final complRate = await repo.completionRateLast7Days();
    final distractions = await repo.totalDistractionsForDay(DateTime.now());
    return AiCoach.instance.pomodoroAdvice(
      t: t,
      focusMinutesToday: minutesToday,
      completionRate7d: complRate,
      distractionsToday: distractions,
    );
  }
}
