import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/combat_data.dart';
import '../../../../models/user_data.dart';
import '../../../../models/dungeon_theme.dart';

class WikiScreen extends StatelessWidget {
  final UserData userData;

  const WikiScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    // 모든 테마의 몬스터 목록을 가져와서 평탄화
    final themeTemplates = MonsterTemplates.getThemeMonsterTemplates();
    final List<Monster> monsters = [];
    themeTemplates.forEach((theme, monsterList) {
      monsters.addAll(monsterList);
    });

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
            _buildDungeonThemesSection(),
            _buildWorldLoreSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorldLoreSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "숫자 정원의 기원 (World Lore)",
            style: TextStyle(
              color: Colors.amberAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "먼 옛날, 세상의 모든 것은 숫자의 질서 위에 세워졌습니다. 대지의 흐름, 바람의 방향, 심지어 생명의 고동조차 정교한 수식으로 이루어져 있었다고 전해집니다. 이 질서를 수호하기 위해 고안된 '스도쿠의 정원'은 숫자의 완벽한 조화를 유지하며 세상을 밝혀 왔습니다.\n\n"
            "하지만 어느 날, 원인을 알 수 없는 '오답의 혼돈(The Chaos of Error)'이 정원을 덮쳤습니다. 이 혼돈은 정교했던 숫자의 배열을 뒤섞고, 본래 선한 기운을 가졌던 수호자들을 난폭한 몬스터로 변질시켰습니다. 정원의 조화가 깨지자 세상 곳곳에서는 논리적인 인과관계가 무너지는 기이한 현상들이 발생하기 시작했습니다.\n\n"
            "이제 수많은 용사들이 이 정원을 정화하기 위해 발을 들여놓습니다. 그들은 단순히 무력으로 싸우는 것이 아니라, 깨져버린 숫자의 빈칸을 올바른 논리로 채워 넣음으로써 어둠에 물든 존재들을 정화합니다. 당신의 손끝에서 완성되는 숫자의 행과 열은, 곧 이 세상을 다시 지탱할 강력한 질서의 근간이 될 것입니다.\n\n"
            "이 도감은 당신이 만난 존재들의 기록이자, 잃어버린 질서를 되찾아가는 여정의 발자취입니다. 모든 숫자가 제자리를 찾고 마지막 빈칸이 채워지는 날, 정원은 다시금 태초의 빛을 발하며 평화를 되찾을 것입니다.",
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
          ),
        ],
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
                monster.description,
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

  Widget _buildDungeonThemesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            "던전 테마 가이드",
            style: GoogleFonts.cinzel(
              color: Colors.amberAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: DungeonTheme.allThemes.length,
          itemBuilder: (context, index) {
            final theme = DungeonTheme.allThemes[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(theme.icon, color: theme.primaryColor, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        theme.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "Lv. ${theme.minLevel} ~ ${theme.maxLevel}",
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    theme.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
