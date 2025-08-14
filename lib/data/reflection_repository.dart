import 'package:hive_flutter/hive_flutter.dart';
import '../models/reflection.dart';
import 'hive_init.dart';

class ReflectionRepository {
  final Box _box = Hive.box(Boxes.reflections);

  Future<void> upsert(Reflection r) async => _box.put(_key(r.date), r.toMap());

  Reflection? getByDate(DateTime d) {
    final m = _box.get(_key(d));
    return m == null ? null : Reflection.fromMap(Map.of(m));
  }

  List<Reflection> lastN(int n) {
    final list = _box.values.cast<Map>().map(Reflection.fromMap).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list.take(n).toList();
  }

  String _key(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    return day.toIso8601String();
  }
}
