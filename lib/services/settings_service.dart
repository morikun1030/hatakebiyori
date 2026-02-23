import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/regions_data.dart';
import '../models/region.dart';

class SettingsService {
  static const _regionKey = 'region_id';

  /// アプリ全体で地域変更を購読できる ValueNotifier
  static final regionNotifier =
      ValueNotifier<Region>(RegionsData.defaultRegion);

  /// 起動時に保存済み設定を読み込む
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_regionKey) ?? RegionsData.defaultRegion.id;
    regionNotifier.value = RegionsData.findById(id);
  }

  /// 地域を保存して即時反映
  static Future<void> setRegion(Region region) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_regionKey, region.id);
    regionNotifier.value = region;
  }

  /// 月リストを地域オフセットで補正する（1〜12の範囲を保つ）
  static List<int> adjustMonths(List<int> months, int offset) {
    if (offset == 0 || months.isEmpty) return months;
    return months.map((m) {
      var a = m + offset;
      while (a < 1) a += 12;
      while (a > 12) a -= 12;
      return a;
    }).toSet().toList()
      ..sort();
  }
}
