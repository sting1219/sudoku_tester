import 'dart:async';
import '../models/user_data.dart';
import '../models/achievement_model.dart';

class AchievementService {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final _achievementController = StreamController<Achievement>.broadcast();
  Stream<Achievement> get onAchievementUnlocked =>
      _achievementController.stream;

  void checkAchievements(UserData userData) {
    final stats = userData.stats;
    final unlocked = stats.unlockedAchievementIds;

    // 1. 첫 번째 승리
    if (!unlocked.contains('first_victory') && stats.totalGamesWon > 0) {
      _unlock('first_victory', userData);
    }

    // 2. 몬스터 사냥꾼 (10회 정화)
    if (!unlocked.contains('monster_hunter') && stats.totalGamesWon >= 10) {
      _unlock('monster_hunter', userData);
    }

    // 3. 수집의 시작 (도감 3종)
    if (!unlocked.contains('collector_start') &&
        stats.discoveredMonsterNames.length >= 3) {
      _unlock('collector_start', userData);
    }
  }

  // 특정 이벤트 기반 체크 (예: 콤보)
  void checkComboAchievement(UserData userData, int comboCount) {
    if (!userData.stats.unlockedAchievementIds.contains('combo_master') &&
        comboCount >= 10) {
      _unlock('combo_master', userData);
    }
  }

  // 데일리 챌린지 체크
  void checkDailyAchievement(UserData userData) {
    if (!userData.stats.unlockedAchievementIds.contains('daily_hero')) {
      _unlock('daily_hero', userData);
    }
  }

  void _unlock(String id, UserData userData) {
    final achievement = AchievementTemplates.getById(id);
    if (achievement != null) {
      userData.stats.unlockedAchievementIds.add(id);
      _achievementController.add(achievement);
      // 데이터 저장은 호출부(UserData 관리하는 곳)에서 수행하거나
      // 여기서 직접 저장하도록 구현할 수도 있음.
      LocalStorageService.saveUserData(userData);
    }
  }

  void dispose() {
    _achievementController.close();
  }
}
