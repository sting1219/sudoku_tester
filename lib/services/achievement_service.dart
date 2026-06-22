import 'package:flutter/material.dart';
import 'dart:async';
import '../models/user_data.dart';
import '../models/achievement_model.dart';
import '../services/sync_manager.dart';

class AchievementService extends ChangeNotifier {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final _achievementController = StreamController<Achievement>.broadcast();
  Stream<Achievement> get onAchievementUnlocked =>
      _achievementController.stream;

  void checkAchievements(UserData userData) {
    final stats = userData.stats;
    final unlocked = stats.unlockedAchievementIds;

    // --- 전투 관련 체크 ---
    _check(unlocked, 'first_purification', stats.totalGamesWon >= 1, userData);
    _check(unlocked, 'slayer_10', stats.totalGamesWon >= 10, userData);
    _check(unlocked, 'slayer_100', stats.totalGamesWon >= 100, userData);
    _check(unlocked, 'slayer_500', stats.totalGamesWon >= 500, userData);
    _check(unlocked, 'slayer_1000', stats.totalGamesWon >= 1000, userData);
    _check(unlocked, 'kill_50', stats.totalGamesWon >= 50, userData);
    _check(unlocked, 'kill_250', stats.totalGamesWon >= 250, userData);

    // --- 퍼즐 실력 관련 ---
    _check(unlocked, 'perfectionist', stats.noMissCount >= 1, userData);
    _check(
      unlocked,
      'total_correct_1000',
      stats.totalCleared >= 1000,
      userData,
    );

    // --- 성장 관련 ---
    _check(unlocked, 'rich_10000', userData.gold >= 10000, userData);
    _check(unlocked, 'gold_5000', userData.gold >= 5000, userData);
    _check(unlocked, 'gold_50000', userData.gold >= 50000, userData);
    _check(unlocked, 'millionaire', userData.gold >= 100000, userData);
    _check(unlocked, 'purifier_lv_50', userData.level >= 50, userData);
    _check(unlocked, 'lv_5', userData.level >= 5, userData);
    _check(unlocked, 'lv_20', userData.level >= 20, userData);
    _check(unlocked, 'lv_30', userData.level >= 30, userData);
    _check(unlocked, 'lev_100', userData.level >= 100, userData);
    _check(unlocked, 'atk_100', userData.baseAttackPower >= 100, userData);
    _check(unlocked, 'hp_10000', userData.baseMaxHp >= 10000, userData);
    _check(unlocked, 'gem_100', userData.gems >= 100, userData);

    // --- 수집 관련 ---
    _check(
      unlocked,
      'collector_10',
      stats.discoveredMonsterNames.length >= 10,
      userData,
    );
    _check(
      unlocked,
      'coll_5',
      stats.discoveredMonsterNames.length >= 5,
      userData,
    );
    _check(
      unlocked,
      'coll_15',
      stats.discoveredMonsterNames.length >= 15,
      userData,
    );
    _check(
      unlocked,
      'coll_20',
      stats.discoveredMonsterNames.length >= 20,
      userData,
    );
    _check(
      unlocked,
      'collector_full',
      stats.discoveredMonsterNames.length >= 25,
      userData,
    );

    // --- 진행 단계 (데일리 등) ---
    // 데일리 3회, 7회 등은 별도 카운트 필드가 필요할 수 있으나 일단 totalGamesWon 등으로 대체 체크하거나
    // 추후 전용 필드 추가 시 정확해짐. 여기서는 단순화하여 승리로 체크.
  }

  // 게임 종료 시(승리 시) 상세 데이터 기반 체크
  void checkGameEndAchievements(
    UserData userData, {
    required int seconds,
    required int mistakes,
    required int combo,
  }) {
    // 시간 관련
    if (seconds <= 180) _unlock('fast_hand_3', userData);
    if (seconds <= 120) _unlock('fast_hand_2', userData);
    if (seconds <= 60) _unlock('fast_hand_1', userData);
    if (seconds <= 30) _unlock('early_bird', userData);

    // 실수 및 콤보 관련
    if (mistakes == 0) _unlock('perfectionist', userData);
    if (combo >= 20) _unlock('combo_20', userData);
    if (combo >= 50) _unlock('combo_50', userData);
    if (combo >= 100) _unlock('combo_100', userData);
  }

  // 특정 이벤트 기반 체크 (예: 콤보)
  void checkComboAchievement(UserData userData, int comboCount) {
    if (comboCount >= 10) _unlock('combo_20', userData); // 기존 flow 유지하며 새 ID 연결
    if (comboCount >= 50) _unlock('combo_50', userData);
    if (comboCount >= 100) _unlock('combo_100', userData);
  }

  // 데일리 챌린지 체크
  void checkDailyAchievement(UserData userData) {
    // 일단 기존 ID 호환을 위해 'daily_3' 등으로 연결하거나 범용 처리
    _unlock('daily_3', userData);
  }

  void _check(
    Set<String> unlocked,
    String id,
    bool condition,
    UserData userData,
  ) {
    if (!unlocked.contains(id) && condition) {
      _unlock(id, userData);
    }
  }

  void _unlock(String id, UserData userData) {
    if (userData.stats.unlockedAchievementIds.contains(id)) return;

    final achievement = AchievementTemplates.getById(id);
    if (achievement != null) {
      userData.stats.unlockedAchievementIds.add(id);
      _achievementController.add(achievement);
      LocalStorageService.saveUserData(userData);
      // 클라우드 동기화 트리거
      SyncManager().syncOnSave(userData);
    }
  }

  void init(UserData userData) {
    // 초기 데이터 로드 시 필요한 로직이 있다면 추가
  }

  @override
  void dispose() {
    _achievementController.close();
    super.dispose();
  }
}
