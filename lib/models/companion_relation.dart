class CompanionInfo {
  final String partnerId;
  final String effect;

  const CompanionInfo({required this.partnerId, required this.effect});
}

class CompanionEntry {
  final String vegetableId;
  final List<CompanionInfo> goodPartners;
  final List<CompanionInfo> badPartners;

  const CompanionEntry({
    required this.vegetableId,
    this.goodPartners = const [],
    this.badPartners = const [],
  });
}
