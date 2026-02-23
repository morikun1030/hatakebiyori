import 'package:uuid/uuid.dart';

enum PlantStatus {
  sowed,      // 播種済み
  sprouted,   // 発芽
  growing,    // 生育中
  harvesting, // 収穫期
  finished,   // 終了
}

extension PlantStatusExt on PlantStatus {
  String get label {
    switch (this) {
      case PlantStatus.sowed:
        return '播種済み';
      case PlantStatus.sprouted:
        return '発芽';
      case PlantStatus.growing:
        return '生育中';
      case PlantStatus.harvesting:
        return '収穫期';
      case PlantStatus.finished:
        return '終了';
    }
  }

  PlantStatus? get next {
    switch (this) {
      case PlantStatus.sowed:
        return PlantStatus.sprouted;
      case PlantStatus.sprouted:
        return PlantStatus.growing;
      case PlantStatus.growing:
        return PlantStatus.harvesting;
      case PlantStatus.harvesting:
        return PlantStatus.finished;
      case PlantStatus.finished:
        return null;
    }
  }

  String get emoji {
    switch (this) {
      case PlantStatus.sowed:
        return '🌱';
      case PlantStatus.sprouted:
        return '🌿';
      case PlantStatus.growing:
        return '🌾';
      case PlantStatus.harvesting:
        return '🎉';
      case PlantStatus.finished:
        return '✅';
    }
  }
}

class MyPlant {
  final String id;
  final String vegetableId;
  final String vegetableName;
  final String vegetableEmoji;
  final DateTime startDate;
  final String plantType; // '種まき' | '定植' | '苗購入'
  final PlantStatus status;
  final String location;
  final int? quantity;
  final String? note;

  const MyPlant({
    required this.id,
    required this.vegetableId,
    required this.vegetableName,
    required this.vegetableEmoji,
    required this.startDate,
    required this.plantType,
    required this.status,
    required this.location,
    this.quantity,
    this.note,
  });

  MyPlant copyWith({
    String? id,
    String? vegetableId,
    String? vegetableName,
    String? vegetableEmoji,
    DateTime? startDate,
    String? plantType,
    PlantStatus? status,
    String? location,
    int? quantity,
    String? note,
  }) {
    return MyPlant(
      id: id ?? this.id,
      vegetableId: vegetableId ?? this.vegetableId,
      vegetableName: vegetableName ?? this.vegetableName,
      vegetableEmoji: vegetableEmoji ?? this.vegetableEmoji,
      startDate: startDate ?? this.startDate,
      plantType: plantType ?? this.plantType,
      status: status ?? this.status,
      location: location ?? this.location,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vegetableId': vegetableId,
        'vegetableName': vegetableName,
        'vegetableEmoji': vegetableEmoji,
        'startDate': startDate.toIso8601String(),
        'plantType': plantType,
        'status': status.name,
        'location': location,
        'quantity': quantity,
        'note': note,
      };

  factory MyPlant.fromJson(Map<String, dynamic> json) {
    return MyPlant(
      id: json['id'] as String,
      vegetableId: json['vegetableId'] as String,
      vegetableName: json['vegetableName'] as String,
      vegetableEmoji: json['vegetableEmoji'] as String? ?? '🌱',
      startDate: DateTime.parse(json['startDate'] as String),
      plantType: json['plantType'] as String,
      status: PlantStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PlantStatus.sowed,
      ),
      location: json['location'] as String? ?? '',
      quantity: json['quantity'] as int?,
      note: json['note'] as String?,
    );
  }

  static String generateId() => const Uuid().v4();
}
