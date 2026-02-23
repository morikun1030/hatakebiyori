enum PestDiseaseType { pest, disease }

class PestDiseaseInfo {
  final String id;
  final String name;
  final PestDiseaseType type;
  final String symptom;    // 症状・特徴
  final String prevention; // 予防法
  final String treatment;  // 対処法
  final String emoji;

  const PestDiseaseInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.symptom,
    required this.prevention,
    required this.treatment,
    required this.emoji,
  });
}
