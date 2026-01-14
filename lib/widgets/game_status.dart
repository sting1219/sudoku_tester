import 'package:flutter/material.dart';

class GameStatus extends StatelessWidget {
  final String difficulty;
  final int mistakes;
  final int maxMistakes;
  final int score;
  final String time;
  final VoidCallback onPauseTap;

  const GameStatus({
    super.key,
    required this.difficulty,
    required this.mistakes,
    required this.maxMistakes,
    required this.score,
    required this.time,
    required this.onPauseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoItem("난이도", difficulty),
          _buildInfoItem("실수", "$mistakes/$maxMistakes"),
          _buildInfoItem("점수", score.toString()),
          Row( // 시간과 일시정지 버튼을 묶음
            children: [
              _buildInfoItem("시간", time),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.pause_circle_filled, color: Colors.blue),
                onPressed: onPauseTap, // ⭐️ 일시정지 실행
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}