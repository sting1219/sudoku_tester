import 'dart:convert';
import 'package:web/web.dart' as web; // Use package:web

// UserStats 모델 정의
class UserStats {
  int totalCleared;
  int noMissCount;

  UserStats({
    this.totalCleared = 0,
    this.noMissCount = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalCleared: json['total_cleared'] ?? 0,
      noMissCount: json['no_miss_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_cleared': totalCleared,
      'no_miss_count': noMissCount,
    };
  }
}

// UserData 모델 정의
class UserData {
  int level;
  int currentXp;
  int totalXpNeeded;
  int gold;
  UserStats stats;

  UserData({
    this.level = 1,
    this.currentXp = 0,
    this.gold = 0,
    UserStats? stats,
  }) : stats = stats ?? UserStats(),
       totalXpNeeded = _calculateXpNeeded(level); // 초기 totalXpNeeded 계산

  // 다음 레벨에 필요한 경험치 계산 (현재 레벨 * 500)
  static int _calculateXpNeeded(int level) {
    return level * 500;
  }

  // 레벨업 처리
  void levelUp() {
    level++;
    currentXp -= totalXpNeeded; // 남은 경험치 처리
    totalXpNeeded = _calculateXpNeeded(level); // 다음 레벨 필요 경험치 갱신
  }

  // 경험치 추가
  void addXp(int xp) {
    currentXp += xp;
    while (currentXp >= totalXpNeeded) {
      levelUp();
    }
  }

  // 골드 추가
  void addGold(int amount) {
    gold += amount;
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      level: json['level'] ?? 1,
      currentXp: json['current_xp'] ?? 0,
      gold: json['gold'] ?? 0,
      stats: json['stats'] != null
          ? UserStats.fromJson(json['stats'])
          : UserStats(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'current_xp': currentXp,
      'total_xp_needed': totalXpNeeded,
      'gold': gold,
      'stats': stats.toJson(),
    };
  }

  // 초기 유저 데이터 생성을 위한 팩토리 (데이터 없을 경우)
  factory UserData.initial() {
    return UserData(
      level: 1,
      currentXp: 0,
      gold: 0,
      stats: UserStats(),
    );
  }
}

// LocalStorageService 구현
class LocalStorageService {
  static const String _userDataKey = 'sudokuUserData';

  static Future<UserData> loadUserData() async {
    final String? userDataJson = web.window.localStorage.getItem(_userDataKey);
    if (userDataJson != null) {
      return UserData.fromJson(jsonDecode(userDataJson));
    }
    return UserData.initial(); // 데이터가 없으면 초기값 반환
  }

  static Future<void> saveUserData(UserData userData) async {
    final String jsonString = jsonEncode(userData.toJson());
    web.window.localStorage.setItem(_userDataKey, jsonString);
  }
}