// lib/models/ranking_model.dart

import 'dart:convert';
import 'package:web/web.dart' as web;

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

  static Future<void> saveRanking(RankingEntry entry) async {
    final String? jsonStr = web.window.localStorage.getItem(_rankingKey);
    final rankings = parseRankings(jsonStr);
    rankings.add(entry);
    // 상위 10개만 유지
    rankings.sort((a, b) => b.score.compareTo(a.score));
    if (rankings.length > 10) rankings.removeLast();

    web.window.localStorage.setItem(_rankingKey, encodeRankings(rankings));
  }
}
