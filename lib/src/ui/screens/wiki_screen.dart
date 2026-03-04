import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/combat_data.dart';
import '../../../../models/user_data.dart';

class WikiScreen extends StatelessWidget {
  final UserData userData;

  const WikiScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    // 도감에 표시할 전체 몬스터 목록 (Templates에서 가져옴)
    final monsters = [
      MonsterTemplates.numberSlime(),
      MonsterTemplates.numberGolem(),
      MonsterTemplates.sudokuDragon(),
      // 여기에 추가 몬스터 템플릿들을 정의하거나 직접 리스트업 가능
    ];

    final discovered = userData.stats.discoveredMonsterNames;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          "몬스터 도감",
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E293B),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: monsters.length,
        itemBuilder: (context, index) {
          final monster = monsters[index];
          final isDiscovered = discovered.contains(monster.name);
          return _buildMonsterCard(context, monster, isDiscovered);
        },
      ),
    );
  }

  Widget _buildMonsterCard(
    BuildContext context,
    Monster monster,
    bool isDiscovered,
  ) {
    if (!isDiscovered) {
      return Card(
        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.help_outline, color: Colors.white24, size: 48),
              SizedBox(height: 8),
              Text(
                "미발견",
                style: TextStyle(
                  color: Colors.white24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 발견된 몬스터 카드
    Color themeColor = _getMonsterColor(monster.name);

    return GestureDetector(
      onTap: () => _showMonsterDetails(context, monster, themeColor),
      child: Card(
        color: const Color(0xFF1E293B),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: themeColor.withValues(alpha: 0.3)),
              ),
              child: Icon(Icons.adb, color: themeColor, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              monster.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "HP: ${monster.maxHp}",
              style: TextStyle(
                color: themeColor.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMonsterDetails(BuildContext context, Monster monster, Color color) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.adb, color: color, size: 50),
              ),
              const SizedBox(height: 20),
              Text(
                monster.name,
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const Divider(color: Colors.white10, height: 32),
              _buildStatRow("최대 HP", "${monster.maxHp}", color),
              _buildStatRow("공격력", "${monster.attackPower}", color),
              _buildStatRow(
                "처치 보상",
                "${monster.rewardGold} GOLD / ${monster.rewardXp} XP",
                color,
              ),
              const SizedBox(height: 24),
              Text(
                _getMonsterDescription(monster.name),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.withValues(alpha: 0.2),
                    foregroundColor: color,
                    side: BorderSide(color: color.withValues(alpha: 0.5)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("닫기"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMonsterColor(String name) {
    if (name.contains("슬라임")) return Colors.greenAccent;
    if (name.contains("골렘")) return Colors.blueGrey;
    if (name.contains("드래곤")) return Colors.redAccent;
    return Colors.cyanAccent;
  }

  String _getMonsterDescription(String name) {
    if (name.contains("슬라임")) return "초보 용사를 위한 연습용 몬스터입니다. 가끔 숫자 1을 떨어트립니다.";
    if (name.contains("골렘"))
      return "단단한 몸체를 가진 골렘입니다. 3x3 박스 완성 시 큰 데미지를 입힐 수 있습니다.";
    if (name.contains("드래곤"))
      return "퍼즐의 제왕입니다. 드래곤의 브레스는 여러분의 스도쿠 판 일부를 가려버릴 수도 있습니다.";
    return "베일에 싸인 신비한 존재입니다.";
  }
}
