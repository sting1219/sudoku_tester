// lib/views/world_map_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_data.dart';
import '../models/dungeon_theme.dart';

class WorldMapScreen extends StatelessWidget {
  final UserData userData;
  final Function(int stageIndex) onStageSelect;

  final VoidCallback onDailyChallenge; // 데일리 도전 콜백 추가

  const WorldMapScreen({
    super.key,
    required this.userData,
    required this.onStageSelect,
    required this.onDailyChallenge,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          "월드 맵",
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: Stack(
        children: [
          // 배경 지도 느낌의 디자인 (간단하게 구현)
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Icon(Icons.map, size: 400, color: Colors.indigo),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildDailyChallengeButton(),
                  const SizedBox(height: 40),
                  ...DungeonTheme.allThemes.asMap().entries.map((entry) {
                    int idx = entry.key;
                    DungeonTheme theme = entry.value;
                    bool isUnlocked = userData.level >= theme.minLevel;
                    return Column(
                      children: [
                        _buildStageNode(context, idx, theme, isUnlocked),
                        if (idx < DungeonTheme.allThemes.length - 1)
                          _buildConnector(),
                      ],
                    );
                  }),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageNode(
    BuildContext context,
    int index,
    DungeonTheme theme,
    bool isUnlocked,
  ) {
    return GestureDetector(
      onTap: isUnlocked ? () => onStageSelect(index) : null,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isUnlocked ? theme.primaryColor : Colors.grey[800],
              shape: BoxShape.circle,
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              isUnlocked ? theme.icon : Icons.lock,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            theme.name,
            style: TextStyle(
              color: isUnlocked ? Colors.white : Colors.white24,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (!isUnlocked)
            Text(
              "Lv.${theme.minLevel} 필요",
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildDailyChallengeButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 10,
      ),
      onPressed: onDailyChallenge,
      icon: const Icon(Icons.calendar_today),
      label: Text(
        "데일리 챌린지",
        style: GoogleFonts.cinzel(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildConnector() {
    return Container(width: 4, height: 40, color: Colors.white10);
  }
}
