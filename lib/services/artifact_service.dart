import '../data/artifact_data.dart';
import '../models/user_data.dart';

class ArtifactService {
  static final ArtifactService _instance = ArtifactService._internal();
  factory ArtifactService() => _instance;
  ArtifactService._internal();

  /// 유저가 보유한 모든 유물의 효과를 합산하여 반환합니다.
  Map<String, double> calculateTotalBonuses(UserData userData) {
    double atkMultiplier = 1.0;
    double hpMultiplier = 1.0;
    double goldMultiplier = 1.0;
    int hpRegen = 0;

    final unlockedIds = userData.stats.unlockedArtifacts;
    
    for (var artifact in CollectionTemplates.artifacts) {
      if (unlockedIds.contains(artifact.id)) {
        atkMultiplier += (artifact.atkMultiplier - 1.0);
        hpMultiplier += (artifact.hpMultiplier - 1.0);
        goldMultiplier += (artifact.goldMultiplier - 1.0);
        hpRegen += artifact.hpRegen;
      }
    }

    return {
      'atkMultiplier': atkMultiplier,
      'hpMultiplier': hpMultiplier,
      'goldMultiplier': goldMultiplier,
      'hpRegen': hpRegen.toDouble(),
    };
  }

  /// 특정 유물 ID에 해당하는 객체를 반환합니다.
  Artifact? getArtifactById(String id) {
    try {
      return CollectionTemplates.artifacts.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
