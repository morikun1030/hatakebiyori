import '../models/region.dart';

class RegionsData {
  static const List<Region> all = [
    Region(
      id: 'hokkaido',
      name: '北海道',
      description: '春が遅く夏が短い。種まきは本州より約2ヶ月遅め。',
      offset: 2,
      emoji: '🏔️',
    ),
    Region(
      id: 'tohoku',
      name: '東北',
      description: '春の訪れが遅め。種まきは関東より約1ヶ月遅れ。',
      offset: 1,
      emoji: '🌲',
    ),
    Region(
      id: 'kanto',
      name: '関東・甲信越',
      description: '標準的な気候。このアプリのデータの基準地域。',
      offset: 0,
      emoji: '🗼',
    ),
    Region(
      id: 'tokai',
      name: '東海・北陸',
      description: '関東とほぼ同じ時期。沿岸部では少し早めのこともある。',
      offset: 0,
      emoji: '🏯',
    ),
    Region(
      id: 'kinki',
      name: '近畿',
      description: '比較的温暖。春先の作業が関東より少し早くできる。',
      offset: -1,
      emoji: '⛩️',
    ),
    Region(
      id: 'chugoku_shikoku',
      name: '中国・四国',
      description: '温暖な気候。沿岸部は特に早め。',
      offset: -1,
      emoji: '🌊',
    ),
    Region(
      id: 'kyushu',
      name: '九州',
      description: '温暖で作物が育ちやすい。春の作業が早い。',
      offset: -1,
      emoji: '🌋',
    ),
    Region(
      id: 'okinawa',
      name: '沖縄・南西諸島',
      description: '亜熱帯気候。年中栽培可能で時期が大きく異なる。',
      offset: -2,
      emoji: '🌴',
    ),
  ];

  static Region get defaultRegion => all[2]; // 関東基準

  static Region findById(String id) =>
      all.firstWhere((r) => r.id == id, orElse: () => defaultRegion);
}
