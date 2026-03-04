import 'dart:convert';
import 'package:web/web.dart' as web;
import 'dungeon.dart';
import 'item_model.dart';

class GameSettings {
  bool autoEraserEnabled;

  GameSettings({this.autoEraserEnabled = true});

  GameSettings clone() => GameSettings(autoEraserEnabled: autoEraserEnabled);

  factory GameSettings.fromJson(Map<String, dynamic> json) {
    return GameSettings(autoEraserEnabled: json['auto_eraser_enabled'] ?? true);
  }

  Map<String, dynamic> toJson() => {'auto_eraser_enabled': autoEraserEnabled};
}

class UserStats {
  final int totalGamesPlayed;
  final int totalGamesWon;
  final Duration? bestTime;
  final int totalMistakes;
  final List<ClearedRoom> archive;
  final int totalCleared;
  final int noMissCount;
  final String activeTitle;
  final List<String> unlockedTitles;
  final Set<String> discoveredMonsterNames;
  final Set<String> unlockedAchievementIds;
  final Set<String> claimedAchievementIds; // 보상 수령한 업적 목록

  UserStats({
    this.totalGamesPlayed = 0,
    this.totalGamesWon = 0,
    this.bestTime,
    this.totalMistakes = 0,
    this.archive = const [],
    this.totalCleared = 0,
    this.noMissCount = 0,
    this.activeTitle = "",
    this.unlockedTitles = const [],
    Set<String>? discoveredMonsterNames,
    Set<String>? unlockedAchievementIds,
    Set<String>? claimedAchievementIds,
  }) : discoveredMonsterNames = discoveredMonsterNames ?? {},
       unlockedAchievementIds = unlockedAchievementIds ?? {},
       claimedAchievementIds = claimedAchievementIds ?? {};

  UserStats clone() {
    return UserStats(
      totalGamesPlayed: totalGamesPlayed,
      totalGamesWon: totalGamesWon,
      bestTime: bestTime,
      totalMistakes: totalMistakes,
      archive: archive.map((e) => e.clone()).toList(),
      totalCleared: totalCleared,
      noMissCount: noMissCount,
      activeTitle: activeTitle,
      unlockedTitles: List<String>.from(unlockedTitles),
      discoveredMonsterNames: Set<String>.from(discoveredMonsterNames),
      unlockedAchievementIds: Set<String>.from(unlockedAchievementIds),
      claimedAchievementIds: Set<String>.from(claimedAchievementIds),
    );
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalGamesPlayed: json['total_games_played'] ?? 0,
      totalGamesWon: json['total_games_won'] ?? 0,
      bestTime: json['best_time'] != null
          ? Duration(microseconds: json['best_time'])
          : null,
      totalMistakes: json['total_mistakes'] ?? 0,
      archive:
          (json['archive'] as List<dynamic>?)
              ?.map((e) => ClearedRoom.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalCleared: json['total_cleared'] ?? 0,
      noMissCount: json['no_miss_count'] ?? 0,
      activeTitle: json['active_title'] ?? "",
      unlockedTitles:
          (json['unlocked_titles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      discoveredMonsterNames:
          (json['discovered_monster_names'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      unlockedAchievementIds:
          (json['unlocked_achievement_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      claimedAchievementIds:
          (json['claimed_achievement_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_games_played': totalGamesPlayed,
      'total_games_won': totalGamesWon,
      'best_time': bestTime?.inMicroseconds,
      'total_mistakes': totalMistakes,
      'archive': archive.map((e) => e.toJson()).toList(),
      'total_cleared': totalCleared,
      'no_miss_count': noMissCount,
      'active_title': activeTitle,
      'unlocked_titles': unlockedTitles,
      'discovered_monster_names': discoveredMonsterNames.toList(),
      'unlocked_achievement_ids': unlockedAchievementIds.toList(),
      'claimed_achievement_ids': claimedAchievementIds.toList(),
    };
  }

  UserStats copyWith({
    int? totalGamesPlayed,
    int? totalGamesWon,
    Duration? bestTime,
    int? totalMistakes,
    List<ClearedRoom>? archive,
    int? totalCleared,
    int? noMissCount,
    String? activeTitle,
    List<String>? unlockedTitles,
    Set<String>? discoveredMonsterNames,
    Set<String>? unlockedAchievementIds,
    Set<String>? claimedAchievementIds,
  }) {
    return UserStats(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalGamesWon: totalGamesWon ?? this.totalGamesWon,
      bestTime: bestTime ?? this.bestTime,
      totalMistakes: totalMistakes ?? this.totalMistakes,
      archive: archive ?? this.archive,
      totalCleared: totalCleared ?? this.totalCleared,
      noMissCount: noMissCount ?? this.noMissCount,
      activeTitle: activeTitle ?? this.activeTitle,
      unlockedTitles: unlockedTitles ?? this.unlockedTitles,
      discoveredMonsterNames:
          discoveredMonsterNames ??
          Set<String>.from(this.discoveredMonsterNames),
      unlockedAchievementIds:
          unlockedAchievementIds ??
          Set<String>.from(this.unlockedAchievementIds),
      claimedAchievementIds:
          claimedAchievementIds ?? Set<String>.from(this.claimedAchievementIds),
    );
  }
}

class ClearedRoom {
  final String artifactName;
  final String artifactLore;
  final int artifactNumber;
  final RoomType type;
  final String clearedDate;
  final List<int> boardSnapshot; // Flattened 9x9 board

  ClearedRoom({
    required this.artifactName,
    required this.artifactLore,
    required this.artifactNumber,
    required this.type,
    required this.clearedDate,
    this.boardSnapshot = const [],
  });

  ClearedRoom clone() {
    return ClearedRoom(
      artifactName: artifactName,
      artifactLore: artifactLore,
      artifactNumber: artifactNumber,
      type: type,
      clearedDate: clearedDate,
      boardSnapshot: List<int>.from(boardSnapshot),
    );
  }

  factory ClearedRoom.fromJson(Map<String, dynamic> json) {
    return ClearedRoom(
      artifactName: json['artifact_name'] ?? "",
      artifactLore: json['artifact_lore'] ?? "",
      artifactNumber: json['artifact_number'] ?? 0,
      type: RoomType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RoomType.normal,
      ),
      clearedDate: json['cleared_date'] ?? "",
      boardSnapshot:
          (json['board_snapshot'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'artifact_name': artifactName,
      'artifact_lore': artifactLore,
      'artifact_number': artifactNumber,
      'type': type.name,
      'cleared_date': clearedDate,
      'board_snapshot': boardSnapshot,
    };
  }
}

class UserData {
  int level;
  int currentXp;
  int totalXpNeeded;
  int gold;
  int gems; // 보석 추가

  // 성장용 스탯
  int baseMaxHp;
  int baseAttackPower;

  // 소지품 및 스킬
  List<Item> inventory;
  List<String> unlockedSkillIds;

  UserStats stats;
  GameSettings settings;

  UserData({
    this.level = 1,
    this.currentXp = 0,
    this.gold = 0,
    this.gems = 0,
    this.baseMaxHp = 100,
    this.baseAttackPower = 100,
    List<Item>? inventory,
    List<String>? unlockedSkillIds,
    UserStats? stats,
    GameSettings? settings,
  }) : inventory = inventory ?? [],
       unlockedSkillIds = unlockedSkillIds ?? [],
       stats = stats ?? UserStats(),
       settings = settings ?? GameSettings(),
       totalXpNeeded = _calculateXpNeeded(level);

  UserData clone() {
    return UserData(
      level: level,
      currentXp: currentXp,
      gold: gold,
      gems: gems,
      baseMaxHp: baseMaxHp,
      baseAttackPower: baseAttackPower,
      inventory: inventory.map((e) => e.clone()).toList(),
      unlockedSkillIds: List<String>.from(unlockedSkillIds),
      stats: stats.clone(),
      settings: settings.clone(),
    )..totalXpNeeded = totalXpNeeded;
  }

  static int _calculateXpNeeded(int level) => level * 500;

  void levelUp() {
    level++;
    // XP 이월 처리는 addXp에서 수행
    totalXpNeeded = _calculateXpNeeded(level);
  }

  // 레벨업이 필요한지 확인
  bool get canLevelUp => currentXp >= totalXpNeeded;

  void addXp(int xp) {
    currentXp += xp;
  }

  void consumeXpForLevelUp() {
    if (canLevelUp) {
      currentXp -= totalXpNeeded;
      levelUp();
    }
  }

  void addGold(int amount) => gold += amount;
  void addGems(int amount) => gems += amount;

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      level: json['level'] ?? 1,
      currentXp: json['current_xp'] ?? 0,
      gold: json['gold'] ?? 0,
      gems: json['gems'] ?? 0,
      baseMaxHp: json['base_max_hp'] ?? 100,
      baseAttackPower: json['base_attack_power'] ?? 100,
      inventory: (json['inventory'] as List<dynamic>?)
          ?.map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList(),
      unlockedSkillIds: (json['unlocked_skill_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      stats: json['stats'] != null
          ? UserStats.fromJson(json['stats'])
          : UserStats(),
      settings: json['settings'] != null
          ? GameSettings.fromJson(json['settings'])
          : GameSettings(),
    );
  }

  Map<String, dynamic> toJson() => {
    'level': level,
    'current_xp': currentXp,
    'total_xp_needed': totalXpNeeded,
    'gold': gold,
    'gems': gems,
    'base_max_hp': baseMaxHp,
    'base_attack_power': baseAttackPower,
    'inventory': inventory.map((e) => e.toJson()).toList(),
    'unlocked_skill_ids': unlockedSkillIds,
    'stats': stats.toJson(),
    'settings': settings.toJson(),
  };

  factory UserData.initial() => UserData();
}

class LocalStorageService {
  static const String _userDataKey = 'sudokuUserData';

  static Future<UserData> loadUserData() async {
    final String? userDataJson = web.window.localStorage.getItem(_userDataKey);
    if (userDataJson != null) {
      try {
        return UserData.fromJson(jsonDecode(userDataJson));
      } catch (e) {
        return UserData.initial();
      }
    }
    return UserData.initial();
  }

  static Future<void> saveUserData(UserData userData) async {
    final String jsonString = jsonEncode(userData.toJson());
    web.window.localStorage.setItem(_userDataKey, jsonString);
  }
}
