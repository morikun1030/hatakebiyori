class Region {
  final String id;
  final String name;
  final String description;
  final int offset; // 関東基準からの月ズレ（+で遅め、-で早め）
  final String emoji;

  const Region({
    required this.id,
    required this.name,
    required this.description,
    required this.offset,
    required this.emoji,
  });
}
