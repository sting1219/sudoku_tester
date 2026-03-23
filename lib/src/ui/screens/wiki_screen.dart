import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../models/user_data.dart';
import '../../../../data/artifact_data.dart';
import '../../../../data/monster_data.dart';
import '../../../../data/lore_data.dart';
import '../../../../views/privacy_policy_view.dart';
import '../../../../views/terms_of_service_view.dart';

class WikiScreen extends StatelessWidget {
  final UserData userData;

  const WikiScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    // 신규 분리된 MonsterData를 가져옵니다.
    final List<MonsterEntry> monsters = MonsterData.monsters;

    return DefaultTabController(
      length: 4,
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
              Tab(icon: Icon(Icons.school), text: "스도쿠 마법 강의"),
              Tab(icon: Icon(Icons.menu_book), text: "고대 기록"),
              Tab(icon: Icon(Icons.museum), text: "정화가의 박물관"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMonsterTab(context, monsters),
            _buildStrategyTab(context),
            _buildLoreTab(context),
            _buildArtifactTab(context),
          ],
        ),
        bottomNavigationBar: _buildSeoFooter(context),
      ),
    );
  }

  // 구글 애드센스 승인을 위한 전문성이 돋보이는 전문 푸터
  Widget _buildSeoFooter(BuildContext context) {
    return Container(
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "© 2026 Sudoku Garden | 인피니티 가든의 질서를 수호하는 정화가들을 위한 전문 도감 시스템입니다.",
            style: TextStyle(color: Colors.white54, fontSize: 10),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyView()),
                ),
                child: const Text(
                  "Privacy Policy",
                  style: TextStyle(color: Colors.white38, fontSize: 10, decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsOfServiceView()),
                ),
                child: const Text(
                  "Terms of Service",
                  style: TextStyle(color: Colors.white38, fontSize: 10, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ],
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

  // ==========================================
  // 스도쿠 마법 강의 (전략 가이드) 탭
  // ==========================================
  Widget _buildStrategyTab(BuildContext context) {
    final List<Map<String, String>> strategies = [
      {
        "title": "1. 기본 규칙과 논리적 접근",
        "content": "스도쿠는 9x9 격자판에서 가로줄, 세로줄, 그리고 3x3 박스 내부에 1부터 9까지의 숫자가 중복 없이 단 한 번씩만 들어가야 하는 논리 게임입니다. 마법 강의의 첫 번째 단계는 '제거의 법칙'을 이해하는 것입니다. 특정 칸에 들어갈 숫자를 찾는 것이 아니라, 들어갈 수 없는 숫자들을 하나씩 지워나감으로써 유일하게 남는 후보를 찾아내는 과정이 핵심입니다. 조급하게 숫자를 채워 넣기보다는, 현재 확실히 증명된 정보만을 바탕으로 퍼즐을 풀어나가는 인내심이 정화가에게 요구되는 첫 번째 덕목입니다."
      },
      {
        "title": "2. 네이키드 싱글 (Naked Single)",
        "content": "가장 기본적이면서도 강력한 기술로, 특정 빈칸을 기준으로 해당 칸이 속한 가로줄, 세로줄, 3x3 박스를 모두 조사했을 때 8개의 숫자가 이미 배치되어 있어 오직 하나의 숫자만이 들어갈 수 있는 경우를 말합니다. 이 기술은 마치 어둠 속에서 오직 한 곳만이 밝게 빛나는 형상과 같습니다. 복잡한 문제를 만났을 때, 우리는 종종 가장 단순한 이 자리를 놓치곤 합니다. 모든 칸을 샅샅이 뒤져 정답이 '강제'되는 유일한 빈칸을 찾아내는 것은 정원의 혼돈을 잠재우는 가장 확실한 수단입니다."
      },
      {
        "title": "3. 히든 싱글 (Hidden Single)",
        "content": "네이키드 싱글보다 한 단계 더 나아간 기술입니다. 특정 칸에 들어갈 후보 숫자가 여러 개일지라도, 해당 가로줄이나 세로줄, 혹은 박스 전체에서 특정 숫자가 들어갈 수 있는 칸이 단 한 곳뿐이라면, 그 숫자는 반드시 그 자리에 위치해야 합니다. 남들의 눈에는 보이지 않는 정답의 궤적을 쫓는 고도의 통찰력이 필요하기 때문에 '히든(숨겨진)'이라는 이름이 붙었습니다. 복잡하게 얽힌 숫자들 사이에서 고고하게 자리를 지키고 있는 단 하나의 가능성을 발견하는 순간, 정원의 마력은 비로소 올바른 방향으로 흐르기 시작합니다."
      },
      {
        "title": "4. 네이키드 페어 (Naked Pair)",
        "content": "두 개의 빈칸에 들어갈 후보 숫자가 똑같이 두 개(예: 1, 2)로 압축되었을 때, 이 두 빈칸이 같은 줄이나 박스에 있다면 다른 어떤 칸에도 그 두 숫자가 들어갈 수 없음을 이용하는 전략입니다. 이는 두 숫자가 서로를 의지하며 자리를 약속한 상태와 같습니다. 비록 당장 그 두 칸의 정확한 숫자는 알 수 없지만, 주변의 오답 후보들을 획기적으로 제거해 줌으로써 전체적인 퍼즐의 난이도를 낮춰주는 자비로운 기술입니다. '확정되지 않은 확정'이라는 논리적 역설을 이해하는 것이 이 강의의 핵심입니다."
      },
      {
        "title": "5. 히든 페어 (Hidden Pair)",
        "content": "복잡한 세 상의 이면을 읽는 기술입니다. 어떤 줄이나 박스의 여러 빈칸 중에서 특정 두 숫자(예: 7, 8)가 들어갈 수 있는 칸이 딱 두 곳뿐이라면, 비록 그 두 칸에 다른 후보 숫자들이 잔뜩 적혀 있더라도 7과 8을 제외한 모든 후보를 과감히 지워야 합니다. 겉으로 드러난 화려한 거짓(오답 후보)들에 현혹되지 않고, 그 이면에 조용히 숨겨진 진실의 연대를 발견하는 정화가만이 이 고난도 강의를 수료할 수 있습니다. 지식의 안개를 걷어내고 정답의 핵심을 꿰뚫는 강력한 논리 마법입니다."
      },
      {
        "title": "6. 포인팅 페어/트리플 (Pointing Pairs/Triples)",
        "content": "박스 내부에서 특정 숫자가 들어갈 수 있는 칸들이 직선(가로 혹은 세로)을 이루고 있을 때, 해당 직선상의 다른 박스 영역에서는 그 숫자가 절대 나타날 수 없음을 간파하는 기술입니다. 이는 한 구역의 논리적 흐름이 화살표처럼 뻗어 나가 다른 구역의 질서를 바로잡는 것과 같습니다. 국지적인 정보가 어떻게 전체 시스템에 영향을 미칠 수 있는지 보여주는 아주 좋은 사례입니다. 작은 실마리가 거대한 정원의 질서를 회복시키는 강력한 도화선이 되는 과정을 경험해 보시기 바랍니다."
      },
      {
        "title": "7. 박스/라인 리덕션 (Box/Line Reduction)",
        "content": "포인팅 기술의 거울 쌍과 같은 전략입니다. 줄(Line) 관점에서 특정 숫자가 들어갈 수 있는 칸들이 특정 박스 내부에만 모여 있다면, 반대로 그 박스 내의 줄 이외의 칸들에서는 해당 숫자를 모두 제거할 수 있습니다. 줄의 권위가 박스의 무질서를 제압하는 형상입니다. 퍼즐을 바라보는 관점을 미시(박스)에서 거시(줄)로, 다시 거시에서 미시로 유연하게 전환하는 능력이 요구됩니다. 이 유연한 사고방식이야말로 복잡한 고대 마법 공식을 해독하는 가장 중요한 열쇠가 될 것입니다."
      },
      {
        "title": "8. 엑스-윙 (X-Wing)",
        "content": "중급 이상의 정화가들이 반드시 익혀야 할 고급 기하학적 정화 기술입니다. 두 개의 가로줄에서 특정 숫자가 들어갈 수 있는 칸이 동일한 세로 위치에 두 곳씩 존재하여 사각형(X자 모양의 대각선 구조)을 이룰 때, 그 세로줄들의 다른 모든 칸에서 해당 숫자를 제거하는 기술입니다. 사방에 배치된 논리적 거울들이 서로 빛을 반사하며 오답을 태워버리는 효과를 줍니다. 엑스-윙은 단순한 칸 채우기를 넘어, 정원의 격자 구조 자체를 이용해 광범위한 지역의 오염된 데이터를 한꺼번에 정화하는 쾌감을 선사합니다."
      },
      {
        "title": "9. 와이-윙 (Y-Wing / XY-Wing)",
        "content": "중심부(Pivot)와 두 개의 날개(Pincer)로 이루어진 삼각 편대 정화법입니다. 세 칸이 서로 연관되어 있으며 각각 두 개씩의 후보를 가지고 있을 때, 특정 연결 고리를 통해 날개 끝자락들이 공통적으로 바라보는 칸에서 특정 오답을 제거합니다. 마치 세 개의 별이 일직선으로 정렬되어 보이지 않는 힘의 작용점을 찾아내는 점성술과 같습니다. 고도로 추상화된 논리적 인과관계를 추적해야 하므로 매우 높은 집중력이 요구되지만, 이 기술을 자유자재로 구사한다면 현자 인피니티에 한 걸음 더 다가선 것입니다."
      },
      {
        "title": "10. 소드피시 (Swordfish)",
        "content": "엑스-윙의 확장판으로, 세 줄과 세 칸의 교차점을 이용하는 전설적인 기술입니다. 복잡하게 얽힌 세 줄에서 특정 숫자의 후보가 3x3 형태의 그물망 구조를 이룰 때, 그물 밖에 위치한 모든 오답 후보를 사냥하는 날카로운 황새치(Swordfish)와 같은 위력을 보여줍니다. 이 기술은 정원의 가장 깊은 혼돈조차 한순간에 정리할 수 있는 궁극의 논리 마법 중 하나입니다. 소드피시를 실전에서 발견하고 성공적으로 적용한다는 것은, 당신의 지혜가 이미 신의 영역에 닿아 정원의 마스터로서 손색이 없음을 의미합니다."
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amberAccent),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "정화가님, 이 강의는 숫자의 정원을 어지럽히는 혼돈을 물리치는 가장 강력한 '논리 마력'의 정수입니다. 각 기술을 숙지하여 완벽한 정화를 이루어내세요.",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: strategies.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final strategy = strategies[index];
              return ExpansionTile(
                collapsedBackgroundColor: const Color(0xFF1E293B),
                backgroundColor: const Color(0xFF334155),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: CircleAvatar(
                  backgroundColor: Colors.amberAccent,
                  child: Text("${index + 1}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                title: Text(
                  strategy["title"]!,
                  style: GoogleFonts.notoSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      strategy["content"]!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 40),
          Center(
            child: Opacity(
              opacity: 0.5,
              child: Text(
                "더 많은 비법이 도서관 깊은 곳에서 발견되기를 기다리고 있습니다.\n계속해서 정진하십시오.",
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSans(color: Colors.white, fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
