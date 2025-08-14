import 'package:hive_flutter/hive_flutter.dart';
class Boxes {
  static const goals = 'goals_box';
  static const reflections = 'reflections_box';
  static const settings = 'settings_box';
  static const pomodoroSessions = 'pomodoro_sessions';
}

Future<void> initHive() async {
  await Hive.initFlutter();
  await Hive.openBox(Boxes.goals);
  await Hive.openBox(Boxes.reflections);
  await Hive.openBox(Boxes.settings);
  await Hive.openBox(Boxes.pomodoroSessions);
}