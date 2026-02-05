import 'package:flutter/material.dart';

class GameStatus extends StatelessWidget {
  final String difficulty;
  final int mistakes;
  final int maxMistakes;
  final String time;
  final VoidCallback onPauseTap;

  // New parameters for player stats
  final int playerLevel;
  final int playerCurrentXp;
  final int playerTotalXpNeeded;
  final int playerGold;
  final int playerCurrentHp;
  final int playerMaxHp;
  final int hintsRemaining; // 힌트 횟수
  final int undoCount; // 실행 취소 횟수
  final int maxUndoCount; // 최대 실행 취소 횟수


  const GameStatus({
    super.key,
    required this.difficulty,
    required this.mistakes,
    required this.maxMistakes,
    required this.time,
    required this.onPauseTap,
    required this.playerLevel,
    required this.playerCurrentXp,
    required this.playerTotalXpNeeded,
    required this.playerGold,
    required this.playerCurrentHp,
    required this.playerMaxHp,
    required this.hintsRemaining,
    required this.undoCount,
    required this.maxUndoCount,
  });

  @override
  Widget build(BuildContext context) {
    double xpPercentage = (playerTotalXpNeeded == 0) ? 0 : playerCurrentXp / playerTotalXpNeeded;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Column(
        children: [
          Row(
            children: [
              Text("Lv.$playerLevel", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 8),
              Text("$playerGold G", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 10),
              Expanded(child: _buildCompactBar("HP", playerCurrentHp, playerMaxHp, Colors.red)),
              const SizedBox(width: 10),
              Expanded(child: _buildCompactBar("XP", playerCurrentXp, playerTotalXpNeeded, Colors.green)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSmallInfo("난이도", difficulty),
              _buildSmallInfo("실수", "$mistakes/$maxMistakes"),
              _buildSmallInfo("시간", time),
              _buildSmallInfo("힌트", "$hintsRemaining"),
              _buildSmallInfo("실행취소", "$undoCount/$maxUndoCount"),
              GestureDetector(
                onTap: onPauseTap,
                child: const Icon(Icons.pause_circle_filled, color: Colors.blue, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBar(String label, int current, int total, Color color) {
    double percentage = (total == 0) ? 0 : current / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text("$current/$total", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            minHeight: 4,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  // Helper for game info
  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  // Helper for player stats
  Widget _buildPlayerStatItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  // New helper for Player HP
  Widget _buildPlayerHpItem(int currentHp, int maxHp) {
    double hpPercentage = (maxHp == 0) ? 0 : currentHp / maxHp;
    if (hpPercentage < 0) hpPercentage = 0;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("HP", style: TextStyle(color: Colors.grey, fontSize: 12)),
          LinearProgressIndicator(
            value: hpPercentage,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
          ),
          Text(
            "$currentHp/$maxHp",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // New helper for Player XP
  Widget _buildPlayerXpItem(double xpPercentage, int currentXp, int totalXpNeeded) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("XP", style: TextStyle(color: Colors.grey, fontSize: 12)),
          LinearProgressIndicator(
            value: xpPercentage,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          Text(
            "$currentXp/$totalXpNeeded",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}