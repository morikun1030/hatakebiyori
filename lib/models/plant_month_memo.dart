class PlantMonthMemo {
  final String myPlantId;
  final int month; // 1〜12
  final String memo;

  const PlantMonthMemo({
    required this.myPlantId,
    required this.month,
    required this.memo,
  });

  Map<String, dynamic> toJson() => {
        'myPlantId': myPlantId,
        'month': month,
        'memo': memo,
      };

  factory PlantMonthMemo.fromJson(Map<String, dynamic> json) {
    return PlantMonthMemo(
      myPlantId: json['myPlantId'] as String,
      month: json['month'] as int,
      memo: json['memo'] as String,
    );
  }
}
