import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/user_data.dart';
import '../../../../data/artifact_data.dart';
import '../../../../data/monster_data.dart';
import '../../../../data/lore_data.dart';

class WikiScreen extends StatelessWidget {
  final UserData userData;

  const WikiScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    // 신규 분리된 MonsterData를 가져옵니다.
    final List<MonsterEntry> monsters = MonsterData.monsters;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          title: Text(
            "대수집 도감",
            style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF1E293B),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.amberAccent,
            labelColor: Colors.amberAccent,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.pest_control), text: "몬스터 분석"),
              Tab(icon: Icon(Icons.menu_book), text: "고대 기록"),
              Tab(icon: Icon(Icons.museum), text: "정화가의 박물관"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMonsterTab(context, monsters),
            _buildLoreTab(context),
            _buildArtifactTab(context),
          ],
        ),
        bottomNavigationBar: _buildSeoFooter(),
      ),
    );
  }

  // 구글 애드센스 승인을 위한 전문성이 돋보이는 전문 푸터
  Widget _buildSeoFooter() {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: const Text(
        "© 2026 Sudoku Garden Collection | 이 정보가 도움이 되셨나요? 최상의 던전 탐험을 위해 도감을 꾸준히 수집하세요.",
        style: TextStyle(color: Colors.white54, fontSize: 10),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ==========================================
  // 1. 몬스터 도감 탭
  // ==========================================
  Widget _buildMonsterTab(BuildContext context, List<MonsterEntry> monsters) {
    return SingleChildScrollView(
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
              final killCount =
                  userData.stats.monsterKillCounts[monster.name] ?? 0;
              return _buildMonsterEntryCard(context, monster, killCount);
            },
          ),
          _buildWorldLoreSection(),
        ],
      ),
    );
  }

  // ==========================================
  // 고대 기록 탭 (금지된 서 + 조각난 일지 + 차원의 비전 통합)
  // ==========================================
  Widget _buildLoreTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("금지된 숫자의 서"),
          _buildForbiddenBookGrid(context),
          const Divider(color: Colors.white24, height: 32),
          _buildSectionTitle("조각난 일지 (던전 무작위 획득)"),
          _buildLostJournalsGrid(context),
          const Divider(color: Colors.white24, height: 32),
          _buildSectionTitle("차원의 낱장 (완성 시 개방)"),
          _buildDimensionRecordView(context),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.cinzel(
          color: Colors.amberAccent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildForbiddenBookGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        int number = index + 1;
        bool isUnlocked = userData.stats.unlockedForbiddenBooks[number] == true;
        int currentCount = userData.stats.killCountsByNumber[number] ?? 0;
        int maxCount = 20;

        if (!isUnlocked) {
          return _buildLockedCard(
            "미해독 페이지 $number",
            "해독률: $currentCount / $maxCount",
            progress: currentCount / maxCount,
          );
        }

        return GestureDetector(
          onTap: () => _showTextPopup(
            context,
            "숫자 $number 의 서",
            LoreData.numberLore[number] ?? "",
          ),
          child: Card(
            color: const Color(0xFF2D1B2E),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.purpleAccent, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_stories,
                  color: Colors.purpleAccent,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  "페이지 $number",
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "클릭하여 읽기",
                  style: TextStyle(color: Colors.purpleAccent, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLostJournalsGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: CollectionTemplates.lostJournals.length,
      itemBuilder: (context, index) {
        final journal = CollectionTemplates.lostJournals[index];
        bool isUnlocked = userData.stats.unlockedLostJournals.contains(
          journal.id,
        );

        if (!isUnlocked) {
          return _buildLockedCard("찢어진 페이지", "미발견 조각", progress: 0.0);
        }

        return GestureDetector(
          onTap: () => _showTextPopup(context, journal.title, journal.content),
          child: Card(
            color: const Color(0xFF2A2A2A),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.grey, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.article, color: Colors.grey, size: 48),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    journal.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDimensionRecordView(BuildContext context) {
    final pieces = userData.stats.collectedIllustrationPieces;
    bool isComplete = pieces.length >= 9;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Text(
            "단서 수집 진척도: ${pieces.length} / 9",
            style: const TextStyle(
              color: Colors.amberAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: List.generate(9, (index) {
              int pieceNum = index + 1;
              bool hasPiece = pieces.contains(pieceNum);
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: hasPiece
                      ? Colors.blue.withValues(alpha: 0.3)
                      : Colors.black45,
                  border: Border.all(
                    color: hasPiece ? Colors.blueAccent : Colors.white12,
                  ),
                ),
                child: Center(
                  child: hasPiece
                      ? const Icon(
                          Icons.visibility,
                          color: Colors.blueAccent,
                          size: 16,
                        )
                      : Text(
                          "$pieceNum",
                          style: const TextStyle(
                            color: Colors.white24,
                            fontSize: 12,
                          ),
                        ),
                ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.history_edu),
              label: Text(isComplete ? "최후의 역사적 비전 열람" : "불완전한 비전 엿보기"),
              style: ElevatedButton.styleFrom(
                backgroundColor: isComplete
                    ? Colors.amber.withValues(alpha: 0.2)
                    : Colors.white10,
                foregroundColor: isComplete ? Colors.amberAccent : Colors.grey,
                side: BorderSide(
                  color: isComplete ? Colors.amberAccent : Colors.white24,
                ),
              ),
              onPressed: () => _showTextPopup(
                context,
                CollectionTemplates.dimensionRecord.title,
                CollectionTemplates.dimensionRecord.fullLore,
                progress: isComplete ? null : pieces.length / 9.0,
              ),
            ),
          ),
          if (!isComplete)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                "모든 낱장을 모으면 숨겨진 진실이 개방됩니다...",
                style: TextStyle(
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // 유물 탭
  // ==========================================
  Widget _buildArtifactTab(BuildContext context) {
    final artifacts = CollectionTemplates.artifacts;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: artifacts.length,
      itemBuilder: (context, index) {
        final artifact = artifacts[index];
        bool isUnlocked = userData.stats.unlockedArtifacts.contains(
          artifact.id,
        );

        if (!isUnlocked) {
          return _buildLockedCard("미발견 골동품", "???", progress: 0.0);
        }

        return GestureDetector(
          onTap: () =>
              _showTextPopup(context, artifact.name, artifact.description),
          child: Card(
            color: const Color(0xFF1A2619),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.greenAccent, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(artifact.icon, color: Colors.greenAccent, size: 36),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    artifact.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // 유틸리티 및 기존 도감 위젯들
  // ==========================================
  Widget _buildLockedCard(String title, String subtitle, {double? progress}) {
    return Card(
      color: const Color(0xFF1E293B).withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, color: Colors.white24, size: 36),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (progress != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.white30,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white24, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  void _showTextPopup(
    BuildContext context,
    String title,
    String content, {
    double? progress,
  }) {
    String displayContent = content;
    String? blurredContent;

    if (progress != null && progress < 1.0) {
      int revealLength = (content.length * progress).toInt();
      displayContent = content.substring(0, revealLength);
      blurredContent = content
          .substring(revealLength)
          .replaceAll(RegExp(r'[^\s\n]'), '▒');
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.amber.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              if (progress != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.amberAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${(progress * 100).toInt()}% 해독됨",
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontSize: 11,
                  ),
                ),
              ],
              const Divider(color: Colors.white24, height: 32),
              Flexible(
                child: SingleChildScrollView(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.6,
                      ),
                      children: [
                        TextSpan(text: displayContent),
                        if (blurredContent != null)
                          TextSpan(
                            text: blurredContent,
                            style: const TextStyle(
                              color: Colors.white24,
                              letterSpacing: 2,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.withValues(alpha: 0.2),
                  foregroundColor: Colors.amberAccent,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("덮기"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 기존 Monster 탭 용 코드 재사용
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

  Widget _buildMonsterEntryCard(
    BuildContext context,
    MonsterEntry monster,
    int killCount,
  ) {
    if (killCount == 0) {
      return _buildLockedCard("미발견 몬스터", "처치 기록 없음");
    }

    Color themeColor = _getMonsterColor(monster.name);
    return GestureDetector(
      onTap: () =>
          _showMonsterEntryDetails(context, monster, themeColor, killCount),
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
              "처치 횟수: $killCount",
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

  void _showMonsterEntryDetails(
    BuildContext context,
    MonsterEntry monster,
    Color color,
    int killCount,
  ) {
    // 1~9: 설명 일부 / 10~49: 설명 일부 확장 / 50+: 완전 해금
    String displayLore =
        "처치 기록이 부족하여 생태 비화가 해독되지 않았습니다.\n(10회 처치 시 일부 해금, 50회 처치 시 완전 해금)";
    if (killCount >= 50) {
      displayLore = monster.deepLore;
    } else if (killCount >= 10) {
      displayLore =
          "[부분 해독됨]\n\n" +
          (monster.deepLore.length > 150
              ? monster.deepLore.substring(0, 150) + "..."
              : monster.deepLore) +
          "\n\n(완전한 해독을 위해 50회 처치가 필요합니다.)";
    }

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
              _buildStatRow("생물군 속성", monster.element, color),
              _buildStatRow("최대 체력 기대값", "${monster.baseMaxHp}", color),
              _buildStatRow("기초 공격력", "${monster.attackPower}", color),
              _buildStatRow(
                "처치 보상",
                "${monster.rewardGold} GOLD / ${monster.rewardXp} XP",
                color,
              ),
              const SizedBox(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    displayLore,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(
                        alpha: killCount >= 50 ? 0.9 : 0.5,
                      ),
                      fontSize: 13,
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
                    backgroundColor: color.withValues(alpha: 0.2),
                    foregroundColor: color,
                    side: BorderSide(color: color.withValues(alpha: 0.5)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("보고서 닫기"),
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
    if (name.contains("보스") ||
        name.contains("군주") ||
        name.contains("염황") ||
        name.contains("여왕") ||
        name.contains("신")) {
      return Colors.redAccent;
    } else if (name.contains("불") ||
        name.contains("용암") ||
        name.contains("염")) {
      return Colors.orangeAccent;
    } else if (name.contains("얼음") ||
        name.contains("서리") ||
        name.contains("냉")) {
      return Colors.lightBlueAccent;
    } else if (name.contains("서적") ||
        name.contains("잉크") ||
        name.contains("사서")) {
      return Colors.purpleAccent;
    } else if (name.contains("황금") ||
        name.contains("빛") ||
        name.contains("태양")) {
      return Colors.amberAccent;
    }
    return Colors.greenAccent;
  }
}
