// lib/models/ranking_model.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RankingEntry {
  final String playerName;
  final int score;
  final int level;
  final int timeInSeconds;
  final DateTime date;
  final String stageName;

  RankingEntry({
    required this.playerName,
    required this.score,
    required this.level,
    required this.timeInSeconds,
    required this.date,
    required this.stageName,
  });

  factory RankingEntry.fromJson(Map<String, dynamic> json) {
    return RankingEntry(
      playerName: json['playerName'] ?? "Unknown",
      score: json['score'] ?? 0,
      level: json['level'] ?? 1,
      timeInSeconds: json['timeInSeconds'] ?? 0,
      date: DateTime.parse(json['date']),
      stageName: json['stageName'] ?? "Unknown",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'score': score,
      'level': level,
      'timeInSeconds': timeInSeconds,
      'date': date.toIso8601String(),
      'stageName': stageName,
    };
  }
}

class RankingManager {
  static const String _rankingKey = 'local_rankings';

  static List<RankingEntry> parseRankings(String? jsonStr) {
    if (jsonStr == null) return [];
    try {
      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((e) => RankingEntry.fromJson(e)).toList()
        ..sort((a, b) => b.score.compareTo(a.score));
    } catch (e) {
      return [];
    }
  }

  static String encodeRankings(List<RankingEntry> rankings) {
    return jsonEncode(rankings.map((e) => e.toJson()).toList());
  }

  static Future<List<RankingEntry>> loadRankings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_rankingKey);
      return parseRankings(jsonStr);
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveRanking(RankingEntry entry) async {
    final rankings = await loadRankings();
    rankings.add(entry);
    // 상위 10개만 유지
    rankings.sort((a, b) => b.score.compareTo(a.score));
    if (rankings.length > 10) rankings.removeLast();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_rankingKey, encodeRankings(rankings));
    } catch (e) {
      // SharedPreferences save error handling
    }
  }
}
