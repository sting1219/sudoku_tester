import 'dart:convert';
import 'package:web/web.dart' as web;
import 'dungeon.dart';
import 'item_model.dart';
import '../data/lore_data.dart';

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

  // 신규 수집형 도감 시스템 관련 필드
  final Map<int, bool> unlockedForbiddenBooks; // 숫자 1~9에 대한 서적 해금 상태
  final Set<String> unlockedArtifacts; // 획득한 골동품(유물) ID 목록
  final Set<String> unlockedLostJournals; // 획득한 조각난 일지 ID 목록
  final Set<int> collectedIllustrationPieces; // 획득한 차원의 낱장(조각) 인덱스(1~9)
  final Map<int, int> killCountsByNumber; // 각 숫자별로 공격하여 몬스터를 처치한 횟수
  final Map<String, int> monsterKillCounts; // 몬스터 ID/이름 단위 처치 횟수
  final Map<String, dynamic>? lastDungeonMap; // 마지막 플레이한 던전 맵 상태

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
    Map<int, bool>? unlockedForbiddenBooks,
    Set<String>? unlockedArtifacts,
    Set<String>? unlockedLostJournals,
    Set<int>? collectedIllustrationPieces,
    Map<int, int>? killCountsByNumber,
    Map<String, int>? monsterKillCounts,
    this.lastDungeonMap,
  }) : discoveredMonsterNames = discoveredMonsterNames ?? {},
       unlockedAchievementIds = unlockedAchievementIds ?? {},
       claimedAchievementIds = claimedAchievementIds ?? {},
       unlockedForbiddenBooks = unlockedForbiddenBooks ?? {},
       unlockedArtifacts = unlockedArtifacts ?? {},
       unlockedLostJournals = unlockedLostJournals ?? {},
       collectedIllustrationPieces = collectedIllustrationPieces ?? {},
       killCountsByNumber = killCountsByNumber ?? {},
       monsterKillCounts = monsterKillCounts ?? {};

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
      unlockedForbiddenBooks: Map<int, bool>.from(unlockedForbiddenBooks),
      unlockedArtifacts: Set<String>.from(unlockedArtifacts),
      unlockedLostJournals: Set<String>.from(unlockedLostJournals),
      collectedIllustrationPieces: Set<int>.from(collectedIllustrationPieces),
      killCountsByNumber: Map<int, int>.from(killCountsByNumber),
      monsterKillCounts: Map<String, int>.from(monsterKillCounts),
      lastDungeonMap: lastDungeonMap != null ? Map<String, dynamic>.from(lastDungeonMap!) : null,
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
      unlockedForbiddenBooks:
          (json['unlocked_forbidden_books'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(int.tryParse(k) ?? 0, v as bool),
          ) ??
          {},
      unlockedArtifacts:
          (json['unlocked_artifacts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      collectedIllustrationPieces:
          (json['collected_illustration_pieces'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toSet() ??
          {},
      killCountsByNumber:
          (json['kill_counts_by_number'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(int.tryParse(k) ?? 0, v as int),
          ) ??
          {},
      unlockedLostJournals:
          (json['unlocked_lost_journals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      monsterKillCounts:
          (json['monster_kill_counts'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as int),
          ) ??
           {},
      lastDungeonMap: json['last_dungeon_map'],
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
      'unlocked_forbidden_books': unlockedForbiddenBooks.map(
        (k, v) => MapEntry(k.toString(), v),
      ),
      'unlocked_artifacts': unlockedArtifacts.toList(),
       'collected_illustration_pieces': collectedIllustrationPieces.toList(),
      'kill_counts_by_number': killCountsByNumber.map((k, v) => MapEntry(k.toString(), v)),
      'unlocked_lost_journals': unlockedLostJournals.toList(),
      'monster_kill_counts': monsterKillCounts,
      'last_dungeon_map': lastDungeonMap,
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
    Map<int, bool>? unlockedForbiddenBooks,
    Set<String>? unlockedArtifacts,
    Set<String>? unlockedLostJournals,
    Set<int>? collectedIllustrationPieces,
    Map<int, int>? killCountsByNumber,
    Map<String, int>? monsterKillCounts,
    Map<String, dynamic>? lastDungeonMap,
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
      discoveredMonsterNames: discoveredMonsterNames ?? this.discoveredMonsterNames,
      unlockedAchievementIds: unlockedAchievementIds ?? this.unlockedAchievementIds,
      claimedAchievementIds: claimedAchievementIds ?? this.claimedAchievementIds,
      unlockedForbiddenBooks: unlockedForbiddenBooks ?? this.unlockedForbiddenBooks,
      unlockedArtifacts: unlockedArtifacts ?? this.unlockedArtifacts,
      unlockedLostJournals: unlockedLostJournals ?? this.unlockedLostJournals,
      collectedIllustrationPieces:
          collectedIllustrationPieces ?? this.collectedIllustrationPieces,
      killCountsByNumber: killCountsByNumber ?? this.killCountsByNumber,
      monsterKillCounts: monsterKillCounts ?? this.monsterKillCounts,
      lastDungeonMap: lastDungeonMap ?? this.lastDungeonMap,
    );
  }
}

class ClearedRoom {
  final String artifactName;
  final int artifactNumber;
  final RoomType type;
  final String clearedDate;
  final List<int> boardSnapshot; // Flattened 9x9 board

  ClearedRoom({
    required this.artifactName,
    required this.artifactNumber,
    required this.type,
    required this.clearedDate,
    this.boardSnapshot = const [],
  });
  // 텍스트는 저장하지 않고 상수를 참조하여 용량 최적화
  String get artifactLore => _getLoreFromStatic(artifactNumber);

  static String _getLoreFromStatic(int number) {
    return LoreData.getLore(number);
  }

  ClearedRoom clone() {
    return ClearedRoom(
      artifactName: artifactName,
      artifactNumber: artifactNumber,
      type: type,
      clearedDate: clearedDate,
      boardSnapshot: List<int>.from(boardSnapshot),
    );
  }

  factory ClearedRoom.fromJson(Map<String, dynamic> json) {
    return ClearedRoom(
      artifactName: json['artifact_name'] ?? "",
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
