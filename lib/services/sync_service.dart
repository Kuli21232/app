import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/hive_init.dart';
import '../models/goal.dart';
import '../models/reflection.dart';
import '../models/pomodoro_session.dart';

// ===== Firestore коллекции / документы =====
const _colGoals       = 'goals';
const _colReflections = 'reflections';
const _colPomodoro    = 'pomodoro_sessions';

// Life Goals: храним единый snapshot json
const _colLifeGoals        = 'life_goals';
const _docLifeGoalsState   = 'state';

// ===== Провайдеры =====
final authStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService();
  service.onAuthChanged(ref.read(authStateProvider).valueOrNull);
  ref.listen<AsyncValue<User?>>(authStateProvider, (prev, next) {
    service.onAuthChanged(next.valueOrNull);
  });
  return service;
});

class SyncService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Hive боксы
  Box? _goalsBox;
  Box? _reflBox;
  Box? _pomodoroBox;
  Box? _lifeGoalsBox; // <— life_goals_v1 (строка items)
  Box? _metaBox;      // служебные ключи: per-uid

  // подписки
  StreamSubscription? _goalsLocalSub, _goalsRemoteSub;
  StreamSubscription? _reflLocalSub, _reflRemoteSub;
  StreamSubscription? _pomoLocalSub, _pomoRemoteSub;
  StreamSubscription? _lgLocalSub, _lgRemoteSub; // <— Life Goals

  // флаги
  bool _applyingRemoteGoals = false;
  bool _applyingRemoteReflections = false;
  bool _applyingRemotePomodoro = false;
  bool _applyingRemoteLifeGoals = false; // <— Life Goals

  // debounce для snapshot life_goals
  Timer? _lgDebounce;

  // текущий UID
  String? _currentUid;
  String? get _uid => _auth.currentUser?.uid;

  // ---------------- lifecycle ----------------

  Future<void> onAuthChanged(User? user) async {
    await stop();

    if (user == null) {
      _currentUid = null;
      // ignore: avoid_print
      print('[SYNC] Пользователь вышел, синхронизация остановлена.');
      return;
    }

    if (_currentUid != user.uid) {
      await _prepareForUser(user.uid);
    }

    // ignore: avoid_print
    print('[SYNC] Пользователь вошёл: ${user.uid}');
    await start();
  }

  Future<void> _prepareForUser(String newUid) async {
    _metaBox ??= await Hive.openBox('_sync_meta');
    final prev = _metaBox!.get('last_uid');
    if (prev != newUid) {
      await _ensureBoxesOpened();
      // ignore: avoid_print
      print('[SYNC] Переключение пользователя $prev → $newUid. Очищаю локальные боксы.');
      await _goalsBox!.clear();
      await _reflBox!.clear();
      await _pomodoroBox!.clear();
      await _lifeGoalsBox!.clear();
      _applyingRemoteGoals =
          _applyingRemoteReflections =
          _applyingRemotePomodoro =
          _applyingRemoteLifeGoals = false;
      await _metaBox!.put('last_uid', newUid);
    }
    _currentUid = newUid;
  }

  Future<void> _ensureBoxesOpened() async {
    _goalsBox ??= Hive.box(Boxes.goals);
    _reflBox ??= Hive.box(Boxes.reflections);
    _pomodoroBox ??= Hive.box(Boxes.pomodoroSessions);
    _lifeGoalsBox ??= await Hive.openBox('life_goals_v1'); // key: 'items'
    _metaBox ??= await Hive.openBox('_sync_meta');
  }

  Future<void> start() async {
    if (_uid == null) return;

    // ignore: avoid_print
    print('[SYNC] Запуск синхронизации для $_uid');

    await _ensureBoxesOpened();

    // одноразовые backfill’ы (персонально для UID)
    await _initialBackfillGoals();
    await _initialBackfillReflections();
    await _initialBackfillPomodoro();
    await _initialBackfillLifeGoals(); // <— новый backfill

    // ===== Goals =====
    _goalsLocalSub = _goalsBox!.watch().listen((event) async {
      if (_applyingRemoteGoals) return;
      final id = event.key as String;
      if (event.deleted) {
        // ignore: avoid_print
        print('[SYNC] [Goals] локальное удаление $id → Firestore');
        await _pushGoalDeleted(id);
      } else {
        final map = Map<String, dynamic>.from(event.value as Map);
        // ignore: avoid_print
        print('[SYNC] [Goals] локальное обновление $id → Firestore');
        await _pushGoalUpsert(Goal.fromMap(map), map: map);
      }
    });

    final goalsCol = _firestore.collection('users').doc(_uid).collection(_colGoals);
    _goalsRemoteSub = goalsCol.snapshots().listen(_applyGoalsRemoteSnapshot);

    // ===== Reflections =====
    _reflLocalSub = _reflBox!.watch().listen((event) async {
      if (_applyingRemoteReflections) return;
      final id = event.key as String;
      if (event.deleted) {
        // ignore: avoid_print
        print('[SYNC] [Reflections] локальное удаление $id → Firestore');
        await _pushReflectionDeleted(id);
      } else {
        final map = Map<String, dynamic>.from(event.value as Map);
        // ignore: avoid_print
        print('[SYNC] [Reflections] локальное обновление $id → Firestore');
        await _pushReflectionUpsert(Reflection.fromMap(map), id: id, map: map);
      }
    });

    final reflCol = _firestore.collection('users').doc(_uid).collection(_colReflections);
    _reflRemoteSub = reflCol.snapshots().listen(_applyReflectionsRemoteSnapshot);

    // ===== Pomodoro =====
    _pomoLocalSub = _pomodoroBox!.watch().listen((event) async {
      if (_applyingRemotePomodoro) return;
      final id = event.key as String;
      if (event.deleted) {
        // ignore: avoid_print
        print('[SYNC] [Pomodoro] локальное удаление $id → Firestore');
        await _pushPomodoroDeleted(id);
      } else {
        final map = Map<String, dynamic>.from(event.value as Map);
        // ignore: avoid_print
        print('[SYNC] [Pomodoro] локальное обновление $id → Firestore');
        await _pushPomodoroUpsert(PomodoroSession.fromMap(map), id: id, map: map);
      }
    });

    final pomoCol = _firestore.collection('users').doc(_uid).collection(_colPomodoro);
    _pomoRemoteSub = pomoCol.snapshots().listen(_applyPomodoroRemoteSnapshot);

    // ===== Life Goals (единый snapshot) =====
    // ЛОКАЛЬНАЯ подписка: изменился key "items" → пушим документ state
    _lgLocalSub = _lifeGoalsBox!.watch(key: 'items').listen((event) async {
      if (_applyingRemoteLifeGoals) return;
      final json = (event.value as String?) ?? '[]';

      // debounce, чтобы не слать десятки запросов при кликах по чекбоксам
      _lgDebounce?.cancel();
      _lgDebounce = Timer(const Duration(milliseconds: 400), () async {
        // ignore: avoid_print
        print('[SYNC] [LifeGoals] локальное изменение → Firestore (snapshot ${json.length} байт)');
        await _pushLifeGoalsState(json);
      });
    });

    // ОБЛАЧНАЯ подписка: документ state → обновляем локальный key "items"
    final lgDoc = _firestore
        .collection('users')
        .doc(_uid)
        .collection(_colLifeGoals)
        .doc(_docLifeGoalsState);
    _lgRemoteSub = lgDoc.snapshots().listen(_applyLifeGoalsRemoteDocument);
  }

  Future<void> stop() async {
    await _goalsLocalSub?.cancel();
    await _goalsRemoteSub?.cancel();
    await _reflLocalSub?.cancel();
    await _reflRemoteSub?.cancel();
    await _pomoLocalSub?.cancel();
    await _pomoRemoteSub?.cancel();
    await _lgLocalSub?.cancel();
    await _lgRemoteSub?.cancel();
    _lgDebounce?.cancel();
    _lgDebounce = null;

    _goalsLocalSub = _goalsRemoteSub = null;
    _reflLocalSub = _reflRemoteSub = null;
    _pomoLocalSub = _pomoRemoteSub = null;
    _lgLocalSub = _lgRemoteSub = null;
  }

  // ---------- helpers для ключей meta (персонифицированы на UID) ----------

  String get _u => _uid ?? 'unknown';
  String _flag(String name) => '$_u:$name';
  String _mk(String kind, String id) => '$_u:$kind:$id'; // meta key

  // --------------- PUBLIC: ручной аплоад всех локальных данных ---------------

  Future<void> forceUploadAll() async {
    if (_uid == null) return;
    // ignore: avoid_print
    print('[SYNC] Ручной аплоад всех локальных данных (uid=$_uid) → Firestore');

    await _uploadAllGoals();
    await _uploadAllReflections();
    await _uploadAllPomodoro();
    await _uploadLifeGoalsState(); // <— Life Goals

    await _metaBox?.put(_flag('backfill_goals_done'), true);
    await _metaBox?.put(_flag('backfill_reflections_done'), true);
    await _metaBox?.put(_flag('backfill_pomodoro_done'), true);
    await _metaBox?.put(_flag('backfill_life_goals_done'), true);
  }

  // ------------------------- BACKFILL: Goals -------------------------

  Future<void> _initialBackfillGoals() async {
    if (_uid == null) return;
    final done = _metaBox!.get(_flag('backfill_goals_done')) == true;
    if (done) {
      // ignore: avoid_print
      print('[SYNC] Backfill целей уже выполнен (uid=$_uid) — пропускаю.');
      return;
    }
    // ignore: avoid_print
    print('[SYNC] Начинаю backfill целей (uid=$_uid)…');
    await _uploadAllGoals();
    await _metaBox!.put(_flag('backfill_goals_done'), true);
    // ignore: avoid_print
    print('[SYNC] Backfill целей завершён.');
  }

  Future<void> _uploadAllGoals() async {
    if (_goalsBox == null) return;
    final nowIso = DateTime.now().toIso8601String();
    for (final e in _goalsBox!.toMap().entries) {
      final id = e.key.toString();
      if (e.value == null) continue;
      final map = Map<String, dynamic>.from(e.value as Map);
      map['id'] ??= id;
      final data = <String, dynamic>{
        ...map,
        'deleted': false,
        'lastModified': nowIso,
      };
      await _firestore.collection('users').doc(_uid).collection(_colGoals).doc(id)
          .set(data, SetOptions(merge: true));
      await _metaBox!.put(_mk('goal', id), {'lastModified': nowIso});
      // ignore: avoid_print
      print('[SYNC] Backfill → цель $id отправлена.');
    }
  }

  // --------------------- BACKFILL: Reflections ----------------------

  Future<void> _initialBackfillReflections() async {
    if (_uid == null) return;
    final done = _metaBox!.get(_flag('backfill_reflections_done')) == true;
    if (done) {
      // ignore: avoid_print
      print('[SYNC] Backfill рефлексий уже выполнен (uid=$_uid) — пропускаю.');
      return;
    }
    // ignore: avoid_print
    print('[SYNC] Начинаю backfill рефлексий…');
    await _uploadAllReflections();
    await _metaBox!.put(_flag('backfill_reflections_done'), true);
    // ignore: avoid_print
    print('[SYNC] Backfill рефлексий завершён.');
  }

  Future<void> _uploadAllReflections() async {
    if (_reflBox == null) return;
    final nowIso = DateTime.now().toIso8601String();
    for (final e in _reflBox!.toMap().entries) {
      final id = e.key.toString();
      if (e.value == null) continue;
      final map = Map<String, dynamic>.from(e.value as Map);
      map['id'] ??= id;
      final data = <String, dynamic>{
        ...map,
        'deleted': false,
        'lastModified': nowIso,
      };
      await _firestore.collection('users').doc(_uid).collection(_colReflections).doc(id)
          .set(data, SetOptions(merge: true));
      await _metaBox!.put(_mk('refl', id), {'lastModified': nowIso});
      // ignore: avoid_print
      print('[SYNC] Backfill → рефлексия $id отправлена.');
    }
  }

  // -------------------- BACKFILL: Pomodoro Sessions -----------------

  Future<void> _initialBackfillPomodoro() async {
    if (_uid == null) return;
    final done = _metaBox!.get(_flag('backfill_pomodoro_done')) == true;
    if (done) {
      // ignore: avoid_print
      print('[SYNC] Backfill помодоро уже выполнен (uid=$_uid) — пропускаю.');
      return;
    }
    // ignore: avoid_print
    print('[SYNC] Начинаю backfill помодоро-сессий…');
    await _uploadAllPomodoro();
    await _metaBox!.put(_flag('backfill_pomodoro_done'), true);
    // ignore: avoid_print
    print('[SYNC] Backfill помодоро завершён.');
  }

  Future<void> _uploadAllPomodoro() async {
    if (_pomodoroBox == null) return;
    final nowIso = DateTime.now().toIso8601String();
    for (final e in _pomodoroBox!.toMap().entries) {
      final id = e.key.toString();
      if (e.value == null) continue;
      final map = Map<String, dynamic>.from(e.value as Map);
      map['id'] ??= id;
      final data = <String, dynamic>{
        ...map,
        'deleted': false,
        'lastModified': nowIso,
      };
      await _firestore.collection('users').doc(_uid).collection(_colPomodoro).doc(id)
          .set(data, SetOptions(merge: true));
      await _metaBox!.put(_mk('pomo', id), {'lastModified': nowIso});
      // ignore: avoid_print
      print('[SYNC] Backfill → помодоро $id отправлена.');
    }
  }

  // -------------------- BACKFILL: Life Goals (snapshot) -------------

  Future<void> _initialBackfillLifeGoals() async {
    if (_uid == null) return;
    final done = _metaBox!.get(_flag('backfill_life_goals_done')) == true;
    if (done) {
      // ignore: avoid_print
      print('[SYNC] Backfill life_goals уже выполнен — пропускаю.');
      return;
    }
    // ignore: avoid_print
    print('[SYNC] Начинаю backfill life_goals…');
    await _uploadLifeGoalsState();
    await _metaBox!.put(_flag('backfill_life_goals_done'), true);
    // ignore: avoid_print
    print('[SYNC] Backfill life_goals завершён.');
  }

  Future<void> _uploadLifeGoalsState() async {
    final json = (_lifeGoalsBox?.get('items') as String?) ?? '[]';
    await _pushLifeGoalsState(json);
  }

  // ---------------- PUSH (local -> cloud): Goals --------------------

  Future<void> _pushGoalUpsert(Goal g, {Map<String, dynamic>? map}) async {
    if (_uid == null) return;
    final now = DateTime.now().toIso8601String();
    final data = <String, dynamic>{
      ...(map ?? g.toMap()),
      'lastModified': now,
      'deleted': false,
    };
    await _firestore.collection('users').doc(_uid).collection(_colGoals).doc(g.id)
        .set(data, SetOptions(merge: true));
    await _metaBox!.put(_mk('goal', g.id), {'lastModified': now});
    // ignore: avoid_print
    print('[SYNC] [Goals] отправлено: ${g.id}');
  }

  Future<void> _pushGoalDeleted(String id) async {
    if (_uid == null) return;
    final now = DateTime.now().toIso8601String();
    await _firestore.collection('users').doc(_uid).collection(_colGoals).doc(id)
        .set({'deleted': true, 'lastModified': now}, SetOptions(merge: true));
    await _metaBox!.put(_mk('goal', id), {'lastModified': now});
    // ignore: avoid_print
    print('[SYNC] [Goals] удаление: $id');
  }

  // ---------------- PUSH: Reflections -------------------------------

  Future<void> _pushReflectionUpsert(Reflection r, {required String id, Map<String, dynamic>? map}) async {
    if (_uid == null) return;
    final now = DateTime.now().toIso8601String();
    final data = <String, dynamic>{
      ...(map ?? r.toMap()),
      'lastModified': now,
      'deleted': false,
    };
    await _firestore.collection('users').doc(_uid).collection(_colReflections).doc(id)
        .set(data, SetOptions(merge: true));
    await _metaBox!.put(_mk('refl', id), {'lastModified': now});
    // ignore: avoid_print
    print('[SYNC] [Reflections] отправлено: $id');
  }

  Future<void> _pushReflectionDeleted(String id) async {
    if (_uid == null) return;
    final now = DateTime.now().toIso8601String();
    await _firestore.collection('users').doc(_uid).collection(_colReflections).doc(id)
        .set({'deleted': true, 'lastModified': now}, SetOptions(merge: true));
    await _metaBox!.put(_mk('refl', id), {'lastModified': now});
    // ignore: avoid_print
    print('[SYNC] [Reflections] удаление: $id');
  }

  // ---------------- PUSH: Pomodoro -------------------------------

  Future<void> _pushPomodoroUpsert(PomodoroSession s, {required String id, Map<String, dynamic>? map}) async {
    if (_uid == null) return;
    final now = DateTime.now().toIso8601String();
    final data = <String, dynamic>{
      ...(map ?? s.toMap()),
      'lastModified': now,
      'deleted': false,
    };
    await _firestore.collection('users').doc(_uid).collection(_colPomodoro).doc(id)
        .set(data, SetOptions(merge: true));
    await _metaBox!.put(_mk('pomo', id), {'lastModified': now});
    // ignore: avoid_print
    print('[SYNC] [Pomodoro] отправлено: $id');
  }

  Future<void> _pushPomodoroDeleted(String id) async {
    if (_uid == null) return;
    final now = DateTime.now().toIso8601String();
    await _firestore.collection('users').doc(_uid).collection(_colPomodoro).doc(id)
        .set({'deleted': true, 'lastModified': now}, SetOptions(merge: true));
    await _metaBox!.put(_mk('pomo', id), {'lastModified': now});
    // ignore: avoid_print
    print('[SYNC] [Pomodoro] удаление: $id');
  }

  // ---------------- PUSH: Life Goals snapshot ----------------------

  Future<void> _pushLifeGoalsState(String itemsJson) async {
    if (_uid == null) return;
    final now = DateTime.now().toIso8601String();
    final docRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection(_colLifeGoals)
        .doc(_docLifeGoalsState);

    await docRef.set({
      'items': itemsJson,
      'lastModified': now,
      'deleted': false,
    }, SetOptions(merge: true));

    await _metaBox!.put(_mk('lgs', 'state'), {'lastModified': now});
    // ignore: avoid_print
    print('[SYNC] [LifeGoals] snapshot отправлен (${itemsJson.length} байт).');
  }

  // ---------------- PULL (cloud -> local): Goals --------------------

  Future<void> _applyGoalsRemoteSnapshot(
      QuerySnapshot<Map<String, dynamic>> snap) async {
    if (_uid == null) return;
    for (final doc in snap.docs) {
      final data = Map<String, dynamic>.from(doc.data());
      final remoteTs = DateTime.tryParse(data['lastModified'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);

      final metaRaw = _metaBox!.get(_mk('goal', doc.id), defaultValue: const {});
      final meta = metaRaw is Map ? Map<String, dynamic>.from(metaRaw) : <String, dynamic>{};
      final localTs = DateTime.tryParse(meta['lastModified'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);

      if (remoteTs.isBefore(localTs)) {
        // ignore: avoid_print
        print('[SYNC] [Goals] пропущено ${doc.id} (локальная версия новее)');
        continue;
      }

      _applyingRemoteGoals = true;
      try {
        if (data['deleted'] == true) {
          // ignore: avoid_print
          print('[SYNC] [Goals] удаление из Firestore → локально: ${doc.id}');
          await _goalsBox!.delete(doc.id);
        } else {
          final toStore = Map<String, dynamic>.from(data)
            ..remove('deleted')
            ..remove('lastModified')
            ..['id'] = doc.id;
          // ignore: avoid_print
          print('[SYNC] [Goals] обновление из Firestore → локально: ${doc.id}');
          await _goalsBox!.put(doc.id, toStore);
        }
        await _metaBox!.put(_mk('goal', doc.id), {'lastModified': data['lastModified'] ?? ''});
      } finally {
        _applyingRemoteGoals = false;
      }
    }
  }

  // ---------------- PULL: Reflections ------------------------------

  Future<void> _applyReflectionsRemoteSnapshot(
      QuerySnapshot<Map<String, dynamic>> snap) async {
    if (_uid == null) return;
    for (final doc in snap.docs) {
      final data = Map<String, dynamic>.from(doc.data());
      final remoteTs = DateTime.tryParse(data['lastModified'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);

      final metaRaw = _metaBox!.get(_mk('refl', doc.id), defaultValue: const {});
      final meta = metaRaw is Map ? Map<String, dynamic>.from(metaRaw) : <String, dynamic>{};
      final localTs = DateTime.tryParse(meta['lastModified'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);

      if (remoteTs.isBefore(localTs)) {
        // ignore: avoid_print
        print('[SYNC] [Reflections] пропущено ${doc.id} (локальная версия новее)');
        continue;
      }

      _applyingRemoteReflections = true;
      try {
        if (data['deleted'] == true) {
          // ignore: avoid_print
          print('[SYNC] [Reflections] удаление из Firestore → локально: ${doc.id}');
          await _reflBox!.delete(doc.id);
        } else {
          final toStore = Map<String, dynamic>.from(data)
            ..remove('deleted')
            ..remove('lastModified')
            ..['id'] = doc.id;
          // ignore: avoid_print
          print('[SYNC] [Reflections] обновление из Firestore → локально: ${doc.id}');
          await _reflBox!.put(doc.id, toStore);
        }
        await _metaBox!.put(_mk('refl', doc.id), {'lastModified': data['lastModified'] ?? ''});
      } finally {
        _applyingRemoteReflections = false;
      }
    }
  }

  // ---------------- PULL: Pomodoro -------------------------------

  Future<void> _applyPomodoroRemoteSnapshot(
      QuerySnapshot<Map<String, dynamic>> snap) async {
    if (_uid == null) return;
    for (final doc in snap.docs) {
      final data = Map<String, dynamic>.from(doc.data());
      final remoteTs = DateTime.tryParse(data['lastModified'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);

      final metaRaw = _metaBox!.get(_mk('pomo', doc.id), defaultValue: const {});
      final meta = metaRaw is Map ? Map<String, dynamic>.from(metaRaw) : <String, dynamic>{};
      final localTs = DateTime.tryParse(meta['lastModified'] ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);

      if (remoteTs.isBefore(localTs)) {
        // ignore: avoid_print
        print('[SYNC] [Pomodoro] пропущено ${doc.id} (локальная версия новее)');
        continue;
      }

      _applyingRemotePomodoro = true;
      try {
        if (data['deleted'] == true) {
          // ignore: avoid_print
          print('[SYNC] [Pomodoro] удаление из Firestore → локально: ${doc.id}');
          await _pomodoroBox!.delete(doc.id);
        } else {
          final toStore = Map<String, dynamic>.from(data)
            ..remove('deleted')
            ..remove('lastModified')
            ..['id'] = doc.id;
          // ignore: avoid_print
          print('[SYNC] [Pomodoro] обновление из Firestore → локально: ${doc.id}');
          await _pomodoroBox!.put(doc.id, toStore);
        }
        await _metaBox!.put(_mk('pomo', doc.id), {'lastModified': data['lastModified'] ?? ''});
      } finally {
        _applyingRemotePomodoro = false;
      }
    }
  }

  // ---------------- PULL: Life Goals (doc state) -------------------

  Future<void> _applyLifeGoalsRemoteDocument(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    if (_uid == null) return;
    if (!doc.exists) return;

    final data = doc.data();
    if (data == null) return;

    final remoteTs = DateTime.tryParse(data['lastModified'] ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);

    final metaRaw = _metaBox!.get(_mk('lgs', 'state'), defaultValue: const {});
    final meta = metaRaw is Map ? Map<String, dynamic>.from(metaRaw) : <String, dynamic>{};
    final localTs = DateTime.tryParse(meta['lastModified'] ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);

    if (remoteTs.isBefore(localTs)) {
      // ignore: avoid_print
      print('[SYNC] [LifeGoals] пропущен snapshot (локальная версия новее)');
      return;
    }

    _applyingRemoteLifeGoals = true;
    try {
      final json = (data['items'] as String?) ?? '[]';
      // ignore: avoid_print
      print('[SYNC] [LifeGoals] обновление из Firestore → локально (${json.length} байт)');
      if (data['deleted'] == true) {
        await _lifeGoalsBox!.delete('items');
      } else {
        await _lifeGoalsBox!.put('items', json);
      }
      await _metaBox!.put(_mk('lgs', 'state'), {'lastModified': data['lastModified'] ?? ''});
    } finally {
      _applyingRemoteLifeGoals = false;
    }
  }
}
