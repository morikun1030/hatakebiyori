import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cultivation_record.dart';
import '../models/my_plant.dart';
import '../models/plant_month_memo.dart';

class StorageService {
  // SharedPreferences keys（移行用）
  static const _recordsKey = 'cultivation_records';
  static const _plantsKey = 'my_plants';
  static const _memosKey = 'plant_month_memos';

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

  static CollectionReference<Map<String, dynamic>> get _plantsCol =>
      FirebaseFirestore.instance.collection('users/$_uid/plants');

  static CollectionReference<Map<String, dynamic>> get _recordsCol =>
      FirebaseFirestore.instance.collection('users/$_uid/records');

  static CollectionReference<Map<String, dynamic>> get _memosCol =>
      FirebaseFirestore.instance.collection('users/$_uid/memos');

  // ─── ローカルデータ移行（初回ログイン時のみ実行）──────────────────────

  static Future<void> migrateFromLocalStorage(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('_migrated_$uid') == true) return;

    final plantsJson = prefs.getString(_plantsKey);
    final recordsJson = prefs.getString(_recordsKey);
    final memosJson = prefs.getString(_memosKey);

    if (plantsJson != null) {
      final list = jsonDecode(plantsJson) as List<dynamic>;
      for (final item in list) {
        final plant = MyPlant.fromJson(item as Map<String, dynamic>);
        await FirebaseFirestore.instance
            .collection('users/$uid/plants')
            .doc(plant.id)
            .set(plant.toJson());
      }
    }

    if (recordsJson != null) {
      final list = jsonDecode(recordsJson) as List<dynamic>;
      for (final item in list) {
        final record =
            CultivationRecord.fromJson(item as Map<String, dynamic>);
        await FirebaseFirestore.instance
            .collection('users/$uid/records')
            .doc(record.id)
            .set(record.toJson());
      }
    }

    if (memosJson != null) {
      final list = jsonDecode(memosJson) as List<dynamic>;
      for (final item in list) {
        final memo = PlantMonthMemo.fromJson(item as Map<String, dynamic>);
        final docId = '${memo.myPlantId}_${memo.month}';
        await FirebaseFirestore.instance
            .collection('users/$uid/memos')
            .doc(docId)
            .set(memo.toJson());
      }
    }

    // 移行済みフラグを立ててローカルデータを削除
    await prefs.setBool('_migrated_$uid', true);
    await prefs.remove(_plantsKey);
    await prefs.remove(_recordsKey);
    await prefs.remove(_memosKey);
  }

  // ─── CultivationRecord ───────────────────────────────────────────

  Future<List<CultivationRecord>> getRecords() async {
    final snapshot = await _recordsCol.get();
    return snapshot.docs
        .map((doc) => CultivationRecord.fromJson(doc.data()))
        .toList();
  }

  Future<void> saveRecord(CultivationRecord record) async {
    await _recordsCol.doc(record.id).set(record.toJson());
  }

  Future<List<CultivationRecord>> getRecordsForPlant(String myPlantId) async {
    final snapshot = await _recordsCol
        .where('myPlantId', isEqualTo: myPlantId)
        .get();
    return snapshot.docs
        .map((doc) => CultivationRecord.fromJson(doc.data()))
        .toList();
  }

  Future<void> deleteRecord(String id) async {
    await _recordsCol.doc(id).delete();
  }

  // ─── MyPlant ─────────────────────────────────────────────────────

  Future<List<MyPlant>> getPlants() async {
    final snapshot = await _plantsCol.get();
    return snapshot.docs
        .map((doc) => MyPlant.fromJson(doc.data()))
        .toList();
  }

  Future<void> savePlant(MyPlant plant) async {
    await _plantsCol.doc(plant.id).set(plant.toJson());
  }

  Future<void> updatePlant(MyPlant plant) async {
    await _plantsCol.doc(plant.id).set(plant.toJson());
  }

  Future<void> deletePlant(String id) async {
    await _plantsCol.doc(id).delete();
  }

  // ─── PlantMonthMemo ──────────────────────────────────────────────

  Future<List<PlantMonthMemo>> getMonthMemos() async {
    final snapshot = await _memosCol.get();
    return snapshot.docs
        .map((doc) => PlantMonthMemo.fromJson(doc.data()))
        .toList();
  }

  Future<void> saveMonthMemo(PlantMonthMemo memo) async {
    final docId = '${memo.myPlantId}_${memo.month}';
    await _memosCol.doc(docId).set(memo.toJson());
  }

  Future<void> deleteMonthMemos(String myPlantId) async {
    final snapshot = await _memosCol
        .where('myPlantId', isEqualTo: myPlantId)
        .get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // ─── Streak ──────────────────────────────────────────────────────

  Future<int> getStreak() async {
    final records = await getRecords();
    if (records.isEmpty) return 0;
    final dates = records
        .map((r) => DateTime(r.date.year, r.date.month, r.date.day))
        .toSet();
    int streak = 0;
    var check = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    while (dates.contains(check)) {
      streak++;
      check = check.subtract(const Duration(days: 1));
    }
    return streak;
  }

  // ─── エクスポート / インポート ────────────────────────────────────

  Future<Map<String, dynamic>> exportData() async {
    final plants = await getPlants();
    final records = await getRecords();
    final memos = await getMonthMemos();
    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'version': 1,
      'plants': plants.map((p) => p.toJson()).toList(),
      'records': records.map((r) => r.toJson()).toList(),
      'memos': memos.map((m) => m.toJson()).toList(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    await _clearAll();

    final plantsList = data['plants'] as List<dynamic>? ?? [];
    for (final item in plantsList) {
      final plant = MyPlant.fromJson(item as Map<String, dynamic>);
      await _plantsCol.doc(plant.id).set(plant.toJson());
    }

    final recordsList = data['records'] as List<dynamic>? ?? [];
    for (final item in recordsList) {
      final record = CultivationRecord.fromJson(item as Map<String, dynamic>);
      await _recordsCol.doc(record.id).set(record.toJson());
    }

    final memosList = data['memos'] as List<dynamic>? ?? [];
    for (final item in memosList) {
      final memo = PlantMonthMemo.fromJson(item as Map<String, dynamic>);
      final docId = '${memo.myPlantId}_${memo.month}';
      await _memosCol.doc(docId).set(memo.toJson());
    }
  }

  Future<void> _clearAll() async {
    final plantDocs = await _plantsCol.get();
    for (final doc in plantDocs.docs) {
      await doc.reference.delete();
    }
    final recordDocs = await _recordsCol.get();
    for (final doc in recordDocs.docs) {
      await doc.reference.delete();
    }
    final memoDocs = await _memosCol.get();
    for (final doc in memoDocs.docs) {
      await doc.reference.delete();
    }
  }
}
