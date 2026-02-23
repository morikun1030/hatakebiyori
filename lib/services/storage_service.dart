import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cultivation_record.dart';
import '../models/my_plant.dart';
import '../models/plant_month_memo.dart';

class StorageService {
  static const _recordsKey = 'cultivation_records';
  static const _plantsKey = 'my_plants';
  static const _memosKey = 'plant_month_memos';

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // ─── CultivationRecord ───────────────────────────────────────────

  Future<List<CultivationRecord>> getRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_recordsKey);
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => CultivationRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveRecord(CultivationRecord record) async {
    final records = await getRecords();
    records.add(record);
    await _persistAllRecords(records);
  }

  Future<List<CultivationRecord>> getRecordsForPlant(String myPlantId) async {
    final all = await getRecords();
    return all.where((r) => r.myPlantId == myPlantId).toList();
  }

  Future<void> deleteRecord(String id) async {
    final records = await getRecords();
    records.removeWhere((r) => r.id == id);
    await _persistAllRecords(records);
  }

  Future<void> _persistAllRecords(List<CultivationRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(records.map((e) => e.toJson()).toList());
    await prefs.setString(_recordsKey, jsonStr);
  }

  // ─── MyPlant ─────────────────────────────────────────────────────

  Future<List<MyPlant>> getPlants() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_plantsKey);
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => MyPlant.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> savePlant(MyPlant plant) async {
    final plants = await getPlants();
    plants.add(plant);
    await _persistAllPlants(plants);
  }

  Future<void> updatePlant(MyPlant plant) async {
    final plants = await getPlants();
    final index = plants.indexWhere((p) => p.id == plant.id);
    if (index != -1) {
      plants[index] = plant;
      await _persistAllPlants(plants);
    }
  }

  Future<void> deletePlant(String id) async {
    final plants = await getPlants();
    plants.removeWhere((p) => p.id == id);
    await _persistAllPlants(plants);
  }

  Future<void> _persistAllPlants(List<MyPlant> plants) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(plants.map((e) => e.toJson()).toList());
    await prefs.setString(_plantsKey, jsonStr);
  }

  // ─── PlantMonthMemo ──────────────────────────────────────────────

  Future<List<PlantMonthMemo>> getMonthMemos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_memosKey);
    if (jsonStr == null) return [];
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => PlantMonthMemo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveMonthMemo(PlantMonthMemo memo) async {
    final memos = await getMonthMemos();
    final index = memos.indexWhere(
        (m) => m.myPlantId == memo.myPlantId && m.month == memo.month);
    if (index != -1) {
      memos[index] = memo;
    } else {
      memos.add(memo);
    }
    await _persistAllMemos(memos);
  }

  Future<void> deleteMonthMemos(String myPlantId) async {
    final memos = await getMonthMemos();
    memos.removeWhere((m) => m.myPlantId == myPlantId);
    await _persistAllMemos(memos);
  }

  Future<void> _persistAllMemos(List<PlantMonthMemo> memos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(memos.map((e) => e.toJson()).toList());
    await prefs.setString(_memosKey, jsonStr);
  }

  // ─── Streak ──────────────────────────────────────────────────────

  Future<int> getStreak() async {
    final records = await getRecords();
    if (records.isEmpty) return 0;
    final dates = records
        .map((r) => DateTime(r.date.year, r.date.month, r.date.day))
        .toSet();
    int streak = 0;
    var check = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    while (dates.contains(check)) {
      streak++;
      check = check.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
