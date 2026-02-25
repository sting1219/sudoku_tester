import 'dart:convert';
import 'package:web/web.dart' as web;
import 'dungeon.dart';

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
  });

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
  UserStats stats;
  GameSettings settings;

  UserData({
    this.level = 1,
    this.currentXp = 0,
    this.gold = 0,
    UserStats? stats,
    GameSettings? settings,
  }) : stats = stats ?? UserStats(),
       settings = settings ?? GameSettings(),
       totalXpNeeded = _calculateXpNeeded(level);

  UserData clone() {
    return UserData(
      level: level,
      currentXp: currentXp,
      gold: gold,
      stats: stats.clone(),
      settings: settings.clone(),
    )..totalXpNeeded = totalXpNeeded;
  }

  static int _calculateXpNeeded(int level) => level * 500;

  void levelUp() {
    level++;
    currentXp -= totalXpNeeded;
    totalXpNeeded = _calculateXpNeeded(level);
  }

  void addXp(int xp) {
    currentXp += xp;
    while (currentXp >= totalXpNeeded) {
      levelUp();
    }
  }

  void addGold(int amount) => gold += amount;

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      level: json['level'] ?? 1,
      currentXp: json['current_xp'] ?? 0,
      gold: json['gold'] ?? 0,
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
