import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/user_data.dart';
import '../../../../data/monster_data.dart';

class CollectionScreen extends StatelessWidget {
  final UserData userData;

  const CollectionScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final List<MonsterEntry> monsters = MonsterData.monsters;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          "도감",
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
          final killCount = userData.stats.monsterKillCounts[monster.name] ?? 0;
          return _buildMonsterCard(context, monster, killCount);
        },
      ),
    );
  }

  Widget _buildMonsterCard(BuildContext context, MonsterEntry monster, int killCount) {
    final bool isObtained = userData.stats.obtainedMonsterCards.contains(monster.name);
    Color themeColor = _getMonsterColor(monster.name);

    Widget content = Column(
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
          isObtained ? monster.name : "???",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isObtained ? "처치 횟수: $killCount" : "미획득 몬스터",
          style: TextStyle(
            color: isObtained ? themeColor.withValues(alpha: 0.8) : Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );

    if (!isObtained) {
      const ColorFilter greyscale = ColorFilter.matrix(<double>[
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0,      0,      0,      1, 0,
      ]);
      content = ColorFiltered(
        colorFilter: greyscale,
        child: content,
      );
    }

    return GestureDetector(
      onTap: () => _showMonsterDetails(context, monster, themeColor, isObtained),
      child: Card(
        color: const Color(0xFF1E293B),
        elevation: 4,
        child: content,
      ),
    );
  }

  void _showMonsterDetails(BuildContext context, MonsterEntry monster, Color color, bool isObtained) {
    // 애드센스 승인용 장문 스토리 노출
    String displayLore = isObtained 
        ? monster.deepLore 
        : "아직 이 몬스터를 마주친 적이 없습니다.\n\n정원의 깊은 곳을 더 탐험하여 미지의 존재를 조우하세요. 처치 시 이들의 신비로운 기원과 생태, 그리고 숨겨진 비화가 해금됩니다.";

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
                  color: isObtained ? color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.adb, color: isObtained ? color : Colors.grey, size: 50),
              ),
              const SizedBox(height: 20),
              Text(
                isObtained ? monster.name : "???",
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const Divider(color: Colors.white10, height: 32),
              if (isObtained) ...[
                _buildStatRow("생물군 속성", monster.element, color),
                _buildStatRow("최대 체력 기대값", "${monster.baseMaxHp}", color),
                _buildStatRow("기초 공격력", "${monster.attackPower}", color),
              ] else ...[
                _buildStatRow("생물군 속성", "???", Colors.grey),
                _buildStatRow("위험도", "측정 불가", Colors.grey),
              ],
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    displayLore,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isObtained ? Colors.white.withValues(alpha: 0.9) : Colors.white54,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isObtained ? color.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
                    foregroundColor: isObtained ? color : Colors.grey,
                    side: BorderSide(color: isObtained ? color.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.5)),
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
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Color _getMonsterColor(String name) {
    if (name.contains("보스") || name.contains("군주") || name.contains("염황") || name.contains("제왕") || name.contains("인피니티") || name.contains("제로스")) {
      return Colors.redAccent;
    }
    if (name.contains("불") || name.contains("화염") || name.contains("마그마")) {
      return Colors.deepOrange;
    }
    if (name.contains("물") || name.contains("얼음") || name.contains("서리")) {
      return Colors.lightBlueAccent;
    }
    if (name.contains("독") || name.contains("가시") || name.contains("산성")) {
      return Colors.greenAccent;
    }
    if (name.contains("번개") || name.contains("전기") || name.contains("알고리즘")) {
      return Colors.yellowAccent;
    }
    if (name.contains("어둠") || name.contains("망각") || name.contains("무정형체") || name.contains("그림자")) {
      return Colors.deepPurpleAccent;
    }
    if (name.contains("빛") || name.contains("천사") || name.contains("수호자")) {
      return Colors.amberAccent;
    }
    if (name.contains("기계") || name.contains("태엽") || name.contains("계산기")) {
      return Colors.blueGrey;
    }
    if (name.contains("대지") || name.contains("바위") || name.contains("기하학자")) {
      return Colors.brown;
    }
    return Colors.cyanAccent;
  }
}
