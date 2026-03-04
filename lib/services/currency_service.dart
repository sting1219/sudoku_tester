import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../models/achievement_model.dart';

class CurrencyService extends ChangeNotifier {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  UserData? _userData;

  void init(UserData userData) {
    _userData = userData;
  }

  int get gold => _userData?.gold ?? 0;
  int get gems => _userData?.gems ?? 0;
  int get level => _userData?.level ?? 1;

  void addGold(int amount) {
    _userData?.addGold(amount);
    _saveAndNotify();
  }

  void addGems(int amount) {
    _userData?.addGems(amount);
    _saveAndNotify();
  }

  bool canAfford(int goldAmount, int gemAmount) {
    if (_userData == null) return false;
    return _userData!.gold >= goldAmount && _userData!.gems >= gemAmount;
  }

  void spend(int goldAmount, int gemAmount) {
    if (canAfford(goldAmount, gemAmount)) {
      _userData!.gold -= goldAmount;
      _userData!.gems -= gemAmount;
      _saveAndNotify();
    }
  }

  // 업적 보상 수령
  void claimAchievementReward(Achievement achievement) {
    if (_userData == null) return;
    if (_userData!.stats.unlockedAchievementIds.contains(achievement.id) &&
        !_userData!.stats.claimedAchievementIds.contains(achievement.id)) {
      _userData!.addGold(achievement.rewardGold);
      _userData!.addGems(achievement.rewardGems);
      _userData!.stats.claimedAchievementIds.add(achievement.id);

      _saveAndNotify();
    }
  }

  // 도감 버프 계산 (공격력 보너스)
  // 몬스터 1종당 공격력 +2% 보너스 (예시)
  double get collectionAtkBonus {
    if (_userData == null) return 1.0;
    int count = _userData!.stats.discoveredMonsterNames.length;
    return 1.0 + (count * 0.02);
  }

  // 도감 버프 계산 (체력 보너스 또는 방어력)
  double get collectionHpBonus {
    if (_userData == null) return 1.0;
    int count = _userData!.stats.discoveredMonsterNames.length;
    return 1.0 + (count * 0.01);
  }

  void _saveAndNotify() {
    if (_userData != null) {
      LocalStorageService.saveUserData(_userData!);
    }
    notifyListeners();
  }
}
