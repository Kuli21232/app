import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../data/hive_init.dart';
import '../services/backup_service.dart';
import 'package:motivego/l10n/app_localizations.dart';

// ===== ТЕМА =====
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final box = Hive.box(Boxes.settings);
  final v = box.get('themeMode', defaultValue: 'system') as String;
  switch (v) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
});

// ===== ЯЗЫК =====
// null => использовать системный язык
final localeProvider = StateProvider<Locale?>((ref) {
  final box = Hive.box(Boxes.settings);
  final code = box.get('localeCode') as String?;
  if (code == null || code == 'system') return null;
  return Locale(code);
});

// ===== АККАУНТ (FirebaseAuth) =====
final authUserProvider =
    StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final mode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);
    final selectedLang = currentLocale?.languageCode ?? 'system';
    const backup = BackupService();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.settingsTitle),
        centerTitle: false,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary.withOpacity(.25),
                scheme.secondaryContainer.withOpacity(.10),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // ===== АККАУНТ =====
          const _AccountBlock(),
          const SizedBox(height: 16),

          // ===== ЯЗЫК =====
          _SectionCard(
            icon: Icons.translate,
            title: t.languageTitle,
            subtitle: t.languageSubtitle,
            child: _OptionGroup<String>(
              value: selectedLang,
              onChanged: (v) {
                if (v == 'system') {
                  _setLocale(ref, null);
                } else {
                  _setLocale(ref, Locale(v));
                }
              },
              options: [
                _Option(label: t.languageSystem, value: 'system'),
                _Option(label: t.languageRussian, value: 'ru'),
                _Option(label: t.languageEnglish, value: 'en'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ===== ОФОРМЛЕНИЕ =====
          _SectionCard(
            icon: Icons.palette_outlined,
            title: t.appearanceTitle,
            subtitle: t.appearanceSubtitle,
            child: _OptionGroup<ThemeMode>(
              value: mode,
              onChanged: (m) => _setMode(ref, m),
              options: [
                _Option(label: t.themeSystem, value: ThemeMode.system),
                _Option(label: t.themeLight, value: ThemeMode.light),
                _Option(label: t.themeDark, value: ThemeMode.dark),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ===== РЕЗЕРВНАЯ КОПИЯ =====
          _SectionCard(
            icon: Icons.cloud_sync_outlined,
            title: t.backupTitle,
            subtitle: t.backupSubtitle,
            child: _ResponsiveButtonBar(children: [
              FilledButton.icon(
                icon: const Icon(Icons.save_alt),
                label: Text(t.backupCreate),
                onPressed: () async {
                  try {
                    final file = await backup.exportToFile();
                    final fileName =
                        file.path.split(Platform.pathSeparator).last;
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t.backupSaved(fileName))),
                      );
                    }
                    await backup.shareFile(file);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t.backupCreateError('$e'))),
                      );
                    }
                  }
                },
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.history),
                label: Text(t.backupRestore),
                onPressed: () async {
                  try {
                    final res = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['json'],
                    );
                    if (res == null || res.files.isEmpty) return;
                    final path = res.files.single.path;
                    if (path == null) return;
                    await backup.importFromFile(File(path));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t.backupImportOk)),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t.backupImportError('$e'))),
                      );
                    }
                  }
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: Text(t.backupClear),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      title: Text(t.clearDataConfirmTitle),
                      content: Text(t.clearDataConfirmBody),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx, false),
                          child: Text(t.cancel),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogCtx, true),
                          child: Text(t.clear),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await backup.clearAll();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t.dataCleared)),
                      );
                    }
                  }
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }

  void _setMode(WidgetRef ref, ThemeMode? m) {
    if (m == null) return;
    final box = Hive.box(Boxes.settings);
    final str = switch (m) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    box.put('themeMode', str);
    ref.read(themeModeProvider.notifier).state = m;
  }

  void _setLocale(WidgetRef ref, Locale? loc) {
    final box = Hive.box(Boxes.settings);
    if (loc == null) {
      box.put('localeCode', 'system');
    } else {
      box.put('localeCode', loc.languageCode);
    }
    ref.read(localeProvider.notifier).state = loc;
  }
}

/// Блок с информацией об аккаунте и кнопкой входа/выхода.
class _AccountBlock extends ConsumerWidget {
  const _AccountBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final userAsync = ref.watch(authUserProvider);

    return _SectionCard(
      icon: Icons.person_outline,
      title: t.accountTitle,
      child: userAsync.when(
        loading: () => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t.accountTitle),
          subtitle: Text(t.accountLoading),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (user) {
          if (user == null) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(t.accountTitle),
              subtitle: Text(t.accountNotSignedIn),
              trailing: FilledButton.icon(
                onPressed: () => context.go('/sign-in'),
                icon: const Icon(Icons.login),
                label: Text(t.signIn),
              ),
            );
          }

          final name = user.displayName ?? t.userNoName;
          final email = user.email ?? t.userNoEmail;
          final photo = user.photoURL;

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundImage: photo != null ? NetworkImage(photo) : null,
              child: photo == null ? const Icon(Icons.person) : null,
            ),
            title: Text(name),
            subtitle: Text(email),
            trailing: FilledButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) context.go('/sign-in');
              },
              icon: const Icon(Icons.logout),
              label: Text(t.signOut),
            ),
          );
        },
      ),
    );
  }
}

/// Карточка-секция с заголовком/описанием и контентом.
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    this.subtitle,
    this.icon,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withOpacity(.3)),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            spreadRadius: -8,
            offset: const Offset(0, 16),
            color: scheme.primary.withOpacity(.08),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        scheme.primary.withOpacity(.25),
                        scheme.primaryContainer.withOpacity(.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: scheme.primary),
                ),
              if (icon != null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Группа вариантов на ChoiceChip (радио-группа, но компактная и переносимая).
class _OptionGroup<T> extends StatelessWidget {
  const _OptionGroup({
    required this.value,
    required this.onChanged,
    required this.options,
  });

  final T value;
  final ValueChanged<T> onChanged;
  final List<_Option<T>> options;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 360;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final selected = o.value == value;
        return ChoiceChip(
          label: Text(
            o.label,
            overflow: TextOverflow.ellipsis,
          ),
          selected: selected,
          onSelected: (_) => onChanged(o.value),
          labelPadding:
              EdgeInsets.symmetric(horizontal: isCompact ? 8 : 12, vertical: 2),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }
}

class _Option<T> {
  const _Option({required this.label, required this.value});
  final String label;
  final T value;
}

/// Обёртка над Wrap для кнопок, чтобы они красиво переносились на узких экранах.
class _ResponsiveButtonBar extends StatelessWidget {
  const _ResponsiveButtonBar({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: children,
    );
  }
}
