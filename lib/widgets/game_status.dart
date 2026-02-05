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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column( // Use Column to stack player stats and game stats
        children: [
          // Player Stats Row
          Row(
            children: [ // mainAxisAlignment removed for Expanded widgets to work
              _buildPlayerStatItem("Lv.", playerLevel.toString()),
              _buildPlayerStatItem("Gold", "$playerGold G"),
              const SizedBox(width: 10), // Separator
              _buildPlayerHpItem(playerCurrentHp, playerMaxHp), // New Player HP item
              const SizedBox(width: 10), // Separator
              _buildPlayerXpItem(xpPercentage, playerCurrentXp, playerTotalXpNeeded), // Existing XP bar as a helper
            ],
          ),
          const SizedBox(height: 10), // Separator
          // Game Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem("난이도", difficulty),
              _buildInfoItem("실수", "$mistakes/$maxMistakes"),
              _buildInfoItem("시간", time),
              _buildInfoItem("힌트", "$hintsRemaining"), // 힌트 횟수
              _buildInfoItem("실행취소", "$undoCount/$maxUndoCount"), // 실행 취소 횟수
              IconButton(
                icon: const Icon(Icons.pause_circle_filled, color: Colors.blue),
                onPressed: onPauseTap,
              ),
            ],
          ),
        ],
      ),
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