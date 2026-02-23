class CultivationRecord {
  final String id;
  final String vegetableId;
  final String vegetableName;
  final DateTime date;
  final String workType;
  final String note;
  final String? harvestAmount; // 例: "500g", "3個"
  final int? cost;             // 費用（円）
  final String? imageBase64;   // Base64エンコード画像
  final String? myPlantId;    // マイ畑の植物ID（任意リンク）

  CultivationRecord({
    required this.id,
    required this.vegetableId,
    required this.vegetableName,
    required this.date,
    required this.workType,
    required this.note,
    this.harvestAmount,
    this.cost,
    this.imageBase64,
    this.myPlantId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'vegetableId': vegetableId,
        'vegetableName': vegetableName,
        'date': date.toIso8601String(),
        'workType': workType,
        'note': note,
        'harvestAmount': harvestAmount,
        'cost': cost,
        'imageBase64': imageBase64,
        'myPlantId': myPlantId,
      };

  factory CultivationRecord.fromJson(Map<String, dynamic> json) {
    return CultivationRecord(
      id: json['id'] as String,
      vegetableId: json['vegetableId'] as String,
      vegetableName: json['vegetableName'] as String,
      date: DateTime.parse(json['date'] as String),
      workType: json['workType'] as String,
      note: json['note'] as String,
      harvestAmount: json['harvestAmount'] as String?,
      cost: json['cost'] as int?,
      imageBase64: json['imageBase64'] as String?,
      myPlantId: json['myPlantId'] as String?,
    );
  }
}
