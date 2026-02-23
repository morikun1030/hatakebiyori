class Vegetable {
  final String id;
  final String name;
  final String category;
  final List<int> sowingMonths;
  final List<int> plantingMonths;
  final List<int> harvestMonths;
  final String difficulty;
  final String description;
  final String emoji;

  const Vegetable({
    required this.id,
    required this.name,
    required this.category,
    required this.sowingMonths,
    required this.plantingMonths,
    required this.harvestMonths,
    required this.difficulty,
    required this.description,
    required this.emoji,
  });
}
