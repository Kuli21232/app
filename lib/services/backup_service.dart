import 'dart:convert';
import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/hive_init.dart';

class BackupService {
  const BackupService();

  // --- helpers --------------------------------------------------------------

  /// Открыть бокс по имени, если ещё не открыт.
  Future<Box> _ensureBox(String name) async {
    if (Hive.isBoxOpen(name)) return Hive.box(name);
    return Hive.openBox(name);
  }

  /// Преобразовать Map с любыми ключами в JSON-совместимый Map<String, dynamic>.
  Map<String, dynamic> _stringifyKeys(Map<dynamic, dynamic> src) {
    return src.map((k, v) => MapEntry(k.toString(), v));
  }

  /// Слить данные в бокс. Пытаемся восстановить тип ключа: int или String.
  Future<void> _mergeIntoBox(Box box, Map data) async {
    for (final e in data.entries) {
      final keyStr = e.key.toString();
      final intKey = int.tryParse(keyStr);
      if (intKey != null) {
        await box.put(intKey, e.value); // восстановим по числовому ключу
      } else {
        await box.put(keyStr, e.value);
      }
    }
  }

  // --- public API -----------------------------------------------------------

  /// Создать JSON-резервную копию всех данных и сохранить в файл.
  /// Возвращает путь к созданному файлу.
  Future<File> exportToFile() async {
    // Боксы (открываем на всякий случай)
    final goalsBox       = await _ensureBox(Boxes.goals);
    final reflectionsBox = await _ensureBox(Boxes.reflections);
    final settingsBox    = await _ensureBox(Boxes.settings);
    final pomodoroBox    = await _ensureBox(Boxes.pomodoroSessions); // ⬅️ новый

    final payload = <String, dynamic>{
      'version': 2, // ⬅️ повысили версию
      'exportedAt': DateTime.now().toIso8601String(),

      // stringify ключи, чтобы гарантированно уложиться в JSON
      'goals':       _stringifyKeys(goalsBox.toMap()),
      'reflections': _stringifyKeys(reflectionsBox.toMap()),
      'settings':    _stringifyKeys(settingsBox.toMap()),
      'pomodoro':    _stringifyKeys(pomodoroBox.toMap()), // ⬅️ новый раздел
    };

    final bytes = const Utf8Encoder().convert(jsonEncode(payload));

    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'motivego_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    return file;
  }

  /// Поделиться уже созданным файлом (системное меню «Поделиться»).
  Future<void> shareFile(File file) async {
    await Share.shareXFiles([XFile(file.path)], text: 'Резервная копия MotiveGo');
  }

  /// Импорт из JSON-файла. Данные сливаются (merge) по ключам.
  /// Поддерживается файл версии 1 (без помодоро) и версии 2 (с помодоро).
  Future<void> importFromFile(File file) async {
    final content = await file.readAsString();
    final jsonMap = jsonDecode(content);

    if (jsonMap is! Map<String, dynamic>) {
      throw const FormatException('Некорректный формат файла');
    }

    // Секции могут отличаться по версиям: v1 — без 'pomodoro'
    if (!jsonMap.containsKey('goals') ||
        !jsonMap.containsKey('reflections') ||
        !jsonMap.containsKey('settings')) {
      throw const FormatException('В файле отсутствуют необходимые секции');
    }

    final goalsMap       = Map<String, dynamic>.from(jsonMap['goals'] as Map);
    final reflectionsMap = Map<String, dynamic>.from(jsonMap['reflections'] as Map);
    final settingsMap    = Map<String, dynamic>.from(jsonMap['settings'] as Map);
    final pomodoroMap    = jsonMap.containsKey('pomodoro')
        ? Map<String, dynamic>.from(jsonMap['pomodoro'] as Map)
        : const <String, dynamic>{}; // для старых бэкапов

    final goalsBox       = await _ensureBox(Boxes.goals);
    final reflectionsBox = await _ensureBox(Boxes.reflections);
    final settingsBox    = await _ensureBox(Boxes.settings);
    final pomodoroBox    = await _ensureBox(Boxes.pomodoroSessions);

    // merge
    await _mergeIntoBox(goalsBox, goalsMap);
    await _mergeIntoBox(reflectionsBox, reflectionsMap);
    await _mergeIntoBox(settingsBox, settingsMap);
    if (pomodoroMap.isNotEmpty) {
      await _mergeIntoBox(pomodoroBox, pomodoroMap);
    }
  }

  /// Полная очистка всех боксов (на случай «чистого» восстановления).
  Future<void> clearAll() async {
    await (await _ensureBox(Boxes.goals)).clear();
    await (await _ensureBox(Boxes.reflections)).clear();
    await (await _ensureBox(Boxes.settings)).clear();
    await (await _ensureBox(Boxes.pomodoroSessions)).clear(); // ⬅️ новый
  }
}
