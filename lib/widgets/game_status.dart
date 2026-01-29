import 'package:flutter/material.dart';

class GameStatus extends StatelessWidget {
  final String difficulty;
  final int mistakes;
  final int maxMistakes;
  // Removed score, as it's replaced by gold/xp in new design
  final String time;
  final VoidCallback onPauseTap;

  // New parameters for player stats
  final int playerLevel;
  final int playerCurrentXp;
  final int playerTotalXpNeeded;
  final int playerGold;


  const GameStatus({
    super.key,
    required this.difficulty,
    required this.mistakes,
    required this.maxMistakes,
    // this.score, // Removed
    required this.time,
    required this.onPauseTap,
    required this.playerLevel,
    required this.playerCurrentXp,
    required this.playerTotalXpNeeded,
    required this.playerGold,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPlayerStatItem("Lv.", playerLevel.toString()),
              _buildPlayerStatItem("Gold", "${playerGold}G"),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("XP", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      LinearProgressIndicator(
                        value: xpPercentage,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      Text(
                        "${playerCurrentXp}/${playerTotalXpNeeded}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // Separator
          // Game Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem("난이도", difficulty),
              _buildInfoItem("실수", "$mistakes/$maxMistakes"),
              // Removed score, now show time and pause
              Row(
                children: [
                  _buildInfoItem("시간", time),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.pause_circle_filled, color: Colors.blue),
                    onPressed: onPauseTap,
                  ),
                ],
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
}