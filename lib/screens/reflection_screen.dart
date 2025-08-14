// lib/screens/reflection_screen.dart
import 'dart:convert';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/reflection_repository.dart';
import '../models/reflection.dart';
import '../ui/adaptive.dart';
import 'package:motivego/l10n/app_localizations.dart';

final reflectionRepoProvider = Provider((ref) => ReflectionRepository());

/// Маркеры для безопасного встраивания метаданных в текст заметки.
/// Вид в хранилище:  "<видимый_текст>\n\n⟦refl_meta⟧{...json...}⟦/refl_meta⟧"
const _kMetaStart = '\n\n⟦refl_meta⟧';
const _kMetaEnd = '⟦/refl_meta⟧';

Map<String, dynamic> _decodeMeta(String note) {
  final i = note.indexOf(_kMetaStart);
  final j = note.indexOf(_kMetaEnd);
  if (i == -1 || j == -1 || j <= i) return {};
  final raw = note.substring(i + _kMetaStart.length, j).trim();
  try {
    return json.decode(raw) as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
}

String _stripMeta(String note) {
  final i = note.indexOf(_kMetaStart);
  if (i == -1) return note;
  return note.substring(0, i).trimRight();
}

String _encodeNoteWithMeta(String visible, Map<String, dynamic> meta) {
  if (meta.isEmpty) return visible.trimRight();
  return visible.trimRight() + _kMetaStart + json.encode(meta) + _kMetaEnd;
}

class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key});
  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  // базовые
  int _mood = 3;
  int _happiness = 50;
  final _noteCtrl = TextEditingController();

  // доп. метрики (в meta)
  int _energy = 50; // 0..100
  int _stress = 40; // 0..100
  double _sleep = 7; // часы 0..12
  final _gratitude = <TextEditingController>[];
  final _highlightCtrl = TextEditingController();
  final _blockersCtrl = TextEditingController();

  static const _primary = Color(0xFF6C4DFF);

  @override
  void initState() {
    super.initState();
    final today = ref.read(reflectionRepoProvider).getByDate(DateTime.now());
    if (today != null) {
      _mood = today.mood;
      _happiness = today.happiness;
      final meta = _decodeMeta(today.note);
      _applyMeta(meta);
      _noteCtrl.text = _stripMeta(today.note);
    } else {
      _addGratitudeField();
    }
  }

  void _applyMeta(Map<String, dynamic> m) {
    _energy = (m['energy'] ?? _energy) is int ? m['energy'] : _energy;
    _stress = (m['stress'] ?? _stress) is int ? m['stress'] : _stress;
    _sleep = (m['sleep'] ?? _sleep) is num ? (m['sleep'] as num).toDouble() : _sleep;

    final g = (m['gratitude'] ?? []) as List? ?? [];
    if (g.isEmpty) {
      _addGratitudeField();
    } else {
      for (final s in g) {
        final c = TextEditingController(text: '$s');
        _gratitude.add(c);
      }
    }
    _highlightCtrl.text = (m['highlight'] ?? '') as String;
    _blockersCtrl.text = (m['blockers'] ?? '') as String;
  }

  Map<String, dynamic> _collectMeta() => {
        'energy': _energy,
        'stress': _stress,
        'sleep': _sleep,
        'gratitude':
            _gratitude.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList(),
        'highlight': _highlightCtrl.text.trim(),
        'blockers': _blockersCtrl.text.trim(),
      };

  void _addGratitudeField() => _gratitude.add(TextEditingController());

  String _tipFor(AppLocalizations t, int v) {
    if (v <= 20) return t.reflTip0_20;
    if (v <= 40) return t.reflTip21_40;
    if (v <= 60) return t.reflTip41_60;
    if (v <= 80) return t.reflTip61_80;
    return t.reflTip81_100;
  }

  Future<void> _save(AppLocalizations t) async {
    final repo = ref.read(reflectionRepoProvider);
    final noteWithMeta = _encodeNoteWithMeta(_noteCtrl.text, _collectMeta());
    final r = Reflection(
      date: DateTime.now(),
      mood: _mood,
      note: noteWithMeta,
      happiness: _happiness,
    );
    await repo.upsert(r);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t.saved)));
    setState(() {});
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _highlightCtrl.dispose();
    _blockersCtrl.dispose();
    for (final c in _gratitude) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final repo = ref.watch(reflectionRepoProvider);
    final recent = repo.lastN(14);
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final dateFmt = DateFormat('dd.MM.yyyy', localeTag);

    final scheme = Theme.of(context).colorScheme;

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
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.black.withOpacity(0.06)),
              ),
            ],
          ),
        ),
        title: Text(
          t.reflectionTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: t.save,
            onPressed: () => _save(t),
            icon: const Icon(Icons.check_circle_outline),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0E1A), Color(0xFF16142A)],
          ),
        ),
        child: CenteredContent(
          child: LayoutBuilder(
            builder: (context, c) {
              final twoCols = c.maxWidth >= 640;
              return Scrollbar(
                thumbVisibility: true,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // ---------- Today header ----------
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat.yMMMMEEEEd(localeTag)
                                .format(DateTime.now()),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => _save(t),
                          icon: const Icon(Icons.check_rounded),
                          label: Text(t.save),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ---------- Mood & Happiness ----------
                    _SectionCard(
                      title: t.howWasDay,
                      accent: _primary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SegmentedButton<int>(
                            segments: const [
                              ButtonSegment(value: 1, label: Text('😕')),
                              ButtonSegment(value: 2, label: Text('🙁')),
                              ButtonSegment(value: 3, label: Text('😐')),
                              ButtonSegment(value: 4, label: Text('🙂')),
                              ButtonSegment(value: 5, label: Text('😄')),
                            ],
                            selected: {_mood},
                            onSelectionChanged: (s) =>
                                setState(() => _mood = s.first),
                          ),
                          const SizedBox(height: 12),
                          Text(t.happinessIndex(_happiness)),
                          _PurpleSlider(
                            value: _happiness.toDouble(),
                            min: 0,
                            max: 100,
                            divisions: 20,
                            label: '$_happiness',
                            onChanged: (v) =>
                                setState(() => _happiness = v.round()),
                          ),
                          const SizedBox(height: 6),
                          _TipBubble(text: _tipFor(t, _happiness)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ---------- Quick metrics grid ----------
                    _SectionCard(
                      title: t.reflDailyMetrics,
                      accent: _primary,
                      trailing: IconButton(
                        tooltip: t.reflReset,
                        icon: const Icon(Icons.refresh),
                        onPressed: () =>
                            setState(() {_energy = 50; _stress = 40; _sleep = 7;}),
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _MetricTile(
                            label: t.reflEnergy,
                            valueLabel: '$_energy',
                            child: _PurpleSlider(
                              value: _energy.toDouble(),
                              min: 0,
                              max: 100,
                              divisions: 20,
                              onChanged: (v) =>
                                  setState(() => _energy = v.round()),
                            ),
                          ),
                          _MetricTile(
                            label: t.reflStress,
                            valueLabel: '$_stress',
                            child: _PurpleSlider(
                              value: _stress.toDouble(),
                              min: 0,
                              max: 100,
                              divisions: 20,
                              onChanged: (v) =>
                                  setState(() => _stress = v.round()),
                            ),
                          ),
                          _MetricTile(
                            label: t.reflSleepHours,
                            valueLabel: _sleep.toStringAsFixed(1),
                            child: _PurpleSlider(
                              value: _sleep,
                              min: 0,
                              max: 12,
                              divisions: 24,
                              onChanged: (v) => setState(() => _sleep =
                                  double.parse(v.toStringAsFixed(1))),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ---------- Gratitude / Notes ----------
                    twoCols
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _gratitudeCard(t)),
                              const SizedBox(width: 12),
                              Expanded(child: _notesCard(t)),
                            ],
                          )
                        : Column(
                            children: [
                              _gratitudeCard(t),
                              const SizedBox(height: 12),
                              _notesCard(t),
                            ],
                          ),

                    const SizedBox(height: 16),

                    // ---------- Quick templates ----------
                    _SectionCard(
                      title: t.reflQuickTemplates,
                      accent: _primary,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          t.reflTplSmooth,
                          t.reflTplLearned,
                          t.reflTplHelped,
                          t.reflTplWalk,
                          t.reflTplWorkout,
                        ]
                            .map(
                              (s) => ActionChip(
                                label: Text(s),
                                backgroundColor:
                                    scheme.secondaryContainer.withOpacity(0.25),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                onPressed: () {
                                  final cur = _noteCtrl.text;
                                  setState(() =>
                                      _noteCtrl.text = cur.isEmpty ? s : '$cur\n• $s');
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text(t.lastEntries,
                        style:
                            const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),

                    if (recent.isEmpty)
                      Text(t.emptyList)
                    else
                      ...recent.map((r) {
                        final meta = _decodeMeta(r.note);
                        final visible = _stripMeta(r.note);
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          child: ListTile(
                            title: Text(
                                '${dateFmt.format(r.date)} • ${t.moodLabel}: ${r.mood} • ${t.happinessShort}: ${r.happiness}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (visible.isNotEmpty) Text(visible),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: [
                                    if (meta['energy'] != null)
                                      _ChipStat(
                                          icon: Icons.bolt,
                                          label:
                                              '${t.reflEnergyShort}: ${meta['energy']}'),
                                    if (meta['stress'] != null)
                                      _ChipStat(
                                          icon: Icons.speed,
                                          label:
                                              '${t.reflStressShort}: ${meta['stress']}'),
                                    if (meta['sleep'] != null)
                                      _ChipStat(
                                          icon: Icons.nightlight_round,
                                          label:
                                              '${t.reflSleepShort}: ${meta['sleep']}h'),
                                    if ((meta['highlight'] ?? '')
                                        .toString()
                                        .isNotEmpty)
                                      _ChipStat(
                                          icon: Icons.star,
                                          label: meta['highlight']),
                                    if ((meta['blockers'] ?? '')
                                        .toString()
                                        .isNotEmpty)
                                      _ChipStat(
                                          icon: Icons.block,
                                          label: meta['blockers']),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                _mood = r.mood;
                                _happiness = r.happiness;
                                _noteCtrl.text = visible;
                                _applyMeta(meta);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(t.reflCopiedFromPast)),
                              );
                            },
                          ),
                        );
                      }),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ---- sub cards ----
  Widget _gratitudeCard(AppLocalizations t) {
    return _SectionCard(
      title: t.reflGratitudeTitle,
      subtitle: t.reflGratitudeHint,
      accent: _primary,
      trailing: IconButton(
        tooltip: t.reflAddItem,
        icon: const Icon(Icons.add),
        onPressed: () => setState(_addGratitudeField),
      ),
      child: Column(
        children: [
          for (var i = 0; i < _gratitude.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _gratitude[i],
                      decoration: InputDecoration(
                        hintText: t.reflGratitudePlaceholder,
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.22),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: t.delete,
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() {
                      final c = _gratitude.removeAt(i);
                      c.dispose();
                    }),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _notesCard(AppLocalizations t) {
    return _SectionCard(
      title: t.reflNotesTitle,
      accent: _primary,
      child: Column(
        children: [
          TextField(
            controller: _highlightCtrl,
            decoration: InputDecoration(
              labelText: t.reflHighlight,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _blockersCtrl,
            decoration: InputDecoration(
              labelText: t.reflBlockers,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteCtrl,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: t.noteLabel,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Фиолетовый слайдер (безопасно для Material 3)
class _PurpleSlider extends StatelessWidget {
  const _PurpleSlider({
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.label,
  });

  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: const Color(0xFF6C4DFF),
        inactiveTrackColor:
            const Color(0xFF6C4DFF).withOpacity(0.25),
        thumbColor: const Color(0xFF6C4DFF),
        overlayColor: const Color(0xFF6C4DFF).withOpacity(0.1),
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        onChanged: onChanged,
      ),
    );
  }
}

/// Обёртка-карточка секции
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.accent,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.hardEdge,
      color: scheme.surface.withOpacity(0.92),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: (accent ?? scheme.primary).withOpacity(0.15)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(subtitle!,
                                style: Theme.of(context).textTheme.bodySmall),
                          ),
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Маленькая «плитка» метрики (под слайдер)
class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.valueLabel,
    required this.child,
  });

  final String label;
  final String valueLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220),
      child: Container(
        width: 360,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.surfaceContainerHighest.withOpacity(0.22),
              const Color(0xFF6C4DFF).withOpacity(0.08),
            ],
          ),
          border: Border.all(color: scheme.outline.withOpacity(0.25)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label,
                      style: Theme.of(context).textTheme.labelLarge),
                ),
                Text(valueLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _TipBubble extends StatelessWidget {
  const _TipBubble({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(text),
      ),
    );
  }
}

class _ChipStat extends StatelessWidget {
  const _ChipStat({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      labelPadding: const EdgeInsets.only(right: 6),
      avatar: Icon(icon, size: 16),
      label: Text(label),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      backgroundColor:
          Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.25),
    );
  }
}
