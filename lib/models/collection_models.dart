// No imports needed for this model file (unless using Color or similar, but here it's unused)

class ForbiddenBookPage {
  final int number;
  final String title;
  final String story;
  final int requiredKills;

  const ForbiddenBookPage({
    required this.number,
    required this.title,
    required this.story,
    required this.requiredKills,
  });
}

class DimensionRecord {
  final String id;
  final String title;
  final String fullLore;
  final int totalPieces;

  const DimensionRecord({
    required this.id,
    required this.title,
    required this.fullLore,
    this.totalPieces = 9,
  });
}

// 기존 CollectionTemplates가 있던 곳은 삭제 (artifact_data.dart로 통합됨)
