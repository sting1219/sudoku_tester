import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/sudoku_board.dart';
import 'models/user_data.dart';
import 'models/combat_data.dart';
import 'models/dungeon.dart'; // DungeonMap 임포트
import 'widgets/minimap.dart'; // MiniMap 위젯 임포트

import 'widgets/number_keypad.dart';
import 'widgets/game_status.dart';
import 'widgets/action_buttons.dart';
import 'widgets/ad_element.dart';
import 'widgets/monster_status.dart';
import 'widgets/combat_log.dart';
import 'widgets/sudoku_grid.dart';
import 'widgets/projectile_animation.dart';
import 'widgets/floating_damage.dart';

// GameState class to hold a snapshot of the entire game state for the undo feature.
class GameState {
  final DungeonMap dungeonMap; // SudokuBoard 대신 DungeonMap 저장
  final Monster currentMonster;
  final PlayerCombatStats playerCombatStats;
  final List<String> combatLogMessages;
  final int comboCount;
  final DateTime? lastCorrectEntryTime;
  final int hintsRemaining;
  final int undoUses;

  GameState({
    required this.dungeonMap, // DungeonMap으로 변경
    required this.currentMonster,
    required this.playerCombatStats,
    required this.combatLogMessages,
    required this.comboCount,
    required this.lastCorrectEntryTime,
    required this.hintsRemaining,
    required this.undoUses,
  });
}

void main() {
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku RPG',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  bool _isGameStarted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeView(
            isStarted: _isGameStarted,
            onStart: () => setState(() => _isGameStarted = true),
          ),
          const SudokuGuideView(),
          const RPGWikiView(),
          const DevLogView(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Guide'),
          NavigationDestination(icon: Icon(Icons.auto_stories), label: 'Wiki'),
          NavigationDestination(icon: Icon(Icons.code), label: 'Dev Log'),
        ],
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  final bool isStarted;
  final VoidCallback onStart;

  const HomeView({super.key, required this.isStarted, required this.onStart});

  final String _longDescription =
      "이 게임은 논리적인 스도쿠와 RPG가 결합된 독창적인 하이브리드 퍼즐 게임입니다. "
      "플레이어는 숫자의 전사가 되어 그리드에 올바른 숫자를 채워 넣음으로써 강력한 몬스터들에게 치명적인 타격을 입힐 수 있습니다. "
      "단순한 퍼즐 풀이를 넘어, 실시간으로 변화하는 전투 상황에 맞춰 전략을 세우고, 콤보 시스템을 활용해 공격력을 극대화하는 재미를 선사합니다. "
      "던전을 탐험하며 만나는 다양한 몬스터들은 저마다의 특수한 패턴과 방어력을 가지고 있어, 정확도뿐만 아니라 속도 또한 승리의 핵심 요소가 됩니다. "
      "수집한 골드와 경험치로 캐릭터를 성장시키고, 전설적인 스도쿠 마스터의 길을 걸으며 세상을 수호하세요. "
      "고전적인 퍼즐의 지적 유희와 현대적인 RPG의 성장의 즐거움이 완벽하게 어우러진 이 세계에서 당신의 논리력을 시험해보세요. "
      "지금 바로 숫자의 전설적인 여정을 시작하세요!";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단 섹션 슬림화
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Sudoku RPG: The Number Warrior",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "숫자로 싸우는 퍼즐 기반의 장대한 여정",
                  style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
        ),

        // 게임 영역 + 오버레이
        Expanded(
          child: Stack(
            children: [
              SudokuScreen(isGameStarted: isStarted),
              if (!isStarted)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: onStart,
                              icon: const Icon(Icons.play_arrow, size: 32),
                              label: const Text(
                                "게임 시작하기",
                                style: TextStyle(fontSize: 20),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigoAccent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                  vertical: 20,
                                ),
                                elevation: 10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Text(
                                _longDescription,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class SudokuGuideView extends StatelessWidget {
  const SudokuGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sudoku Guide")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "스도쿠 정복을 위한 전략 지침서",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "스도쿠는 9x9 격자판에서 가로, 세로, 그리고 3x3 박스 안에 1부터 9까지의 숫자를 겹치지 않게 채워넣는 퍼즐입니다.",
            style: TextStyle(fontSize: 16),
          ),
          const Divider(height: 40),
          _buildGuideSection(
            "1. 기초: 단일 후보수 (Naked Single)",
            "특정 셀에 들어갈 수 있는 숫자가 단 하나뿐일 때, 해당 숫자를 채워 넣는 가장 기본적인 방법입니다.",
          ),
          _buildGuideSection(
            "2. 중급: 숨겨진 후보수 (Hidden Single)",
            "행, 열 또는 박스 전체를 보았을 때 특정 숫자가 들어갈 수 있는 칸이 단 하나뿐이라면, 그 칸의 후보수가 여러 개라도 해당 숫자를 확정할 수 있습니다.",
          ),
          _buildGuideSection(
            "4. 고급: X-Wing",
            "가로 방향의 두 행에서 특정 숫자가 들어갈 수 있는 열이 단 두 곳뿐이고, 그 두 곳이 서로 일치할 때(사각형 형태), 해당 숫자는 그 열의 다른 어느 행에도 위치할 수 없습니다. 이 규칙을 통해 세로 방향의 후보수를 제거할 수 있습니다.",
          ),
          _buildGuideSection(
            "5. 전문가: Swordfish",
            "X-Wing의 확장판으로, 세 개의 행에서 특정 숫자가 위치할 수 있는 열이 동일한 세 곳 내에 한정될 때 작동합니다. 이 복잡한 패턴을 찾아내면 수십 개의 후보수를 한 번에 제거하는 쾌감을 느낄 수 있습니다.",
          ),
          _buildGuideSection(
            "6. 전략: XY-Wing",
            "세 개의 셀이 'L'자 형태로 연결되어 서로의 후보수를 제한하는 기술입니다. 피벗(Pivot) 셀과 두 개의 집게(Pincer) 셀 사이의 논리적 연결을 통해 멀리 떨어진 셀의 후보수를 제거할 수 있습니다.",
          ),
          const SizedBox(height: 40),
          Card(
            color: Colors.indigo.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.indigoAccent, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lightbulb, color: Colors.amber, size: 32),
                      SizedBox(width: 12),
                      Text(
                        "프로 마스터의 전투 팁",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "1. 콤보가 끊기지 않게 속도를 유지하세요.\n"
                    "2. 어려운 칸은 메모(Notes) 기능을 적극적으로 활용하세요.\n"
                    "3. 3x3 박스를 먼저 완성하면 몬스터에게 강력한 범위 데미지를 입힙니다!",
                    style: TextStyle(color: Colors.white70, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 60),
          const Text(
            "등급별 던전 공략 지침",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: 16),
          _buildGuideSection(
            "안전 등급 (Easy)",
            "스도쿠의 기초를 다지는 시기입니다. 숫자가 이미 많이 채워져 있으므로, '단일 후보수' 기술만으로도 충분히 클리어 가능합니다. 콤보를 유지하며 골드를 수급하는 데 집중하세요.",
          ),
          _buildGuideSection(
            "위험 등급 (Medium)",
            "숨겨진 후보수를 찾지 못하면 진행이 막힐 수 있습니다. 메모 기능을 활성화하여 후보수를 기입하고, Naked Pair 패턴이 나타나는지 유심히 관찰하세요.",
          ),
          _buildGuideSection(
            "치명적 등급 (Hard)",
            "진정한 전사를 위한 전장입니다. X-Wing이나 Swordfish 같은 고급 기술 없이는 돌파가 불가능에 가깝습니다. 몬스터의 공격력이 매우 높으므로, 확신이 서지 않는 칸은 함부로 채우지 마십시오.",
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGuideSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.indigoAccent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 15, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class RPGWikiView extends StatelessWidget {
  const RPGWikiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RPG Wiki")),
      body: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
        padding: const EdgeInsets.all(16),
        childAspectRatio: 0.8,
        children: [
          _buildMonsterCard(
            "숫자 슬라임",
            "HP: 2000 | ATK: 10",
            "초보 용사를 위한 연습용 몬스터입니다. 가끔 숫자 1을 떨어트립니다.",
            Colors.green,
          ),
          _buildMonsterCard(
            "숫자 골렘",
            "HP: 5000 | ATK: 25",
            "단단한 몸체를 가진 골렘입니다. 3x3 박스 완성 시 큰 데미지를 입힐 수 있습니다.",
            Colors.blueGrey,
          ),
          _buildMonsterCard(
            "스도쿠 드래곤",
            "HP: 10000 | ATK: 50",
            "퍼즐의 제왕입니다. 드래곤의 브레스는 여러분의 스도쿠 판 일부를 가려버릴 수도 있습니다. 전설에 따르면 드래곤은 숫자의 질서를 수호하는 존재였으나, 알 수 없는 '오답의 혼돈'에 오염되었다고 합니다.",
            Colors.redAccent,
          ),
          _buildMonsterCard(
            "그림자 숫자술사",
            "HP: 3500 | ATK: 20",
            "보이지 않는 곳에서 숫자를 조작합니다. 그가 소환하는 그림자는 당신이 입력한 숫자의 정체를 잠시 동안 숨겨버릴 수 있습니다.",
            Colors.purpleAccent,
          ),
          _buildMonsterCard(
            "고대의 계산기 골렘",
            "HP: 15000 | ATK: 40",
            "잊혀진 문명의 유산입니다. 매우 단단하지만, 소수(Prime Number)가 정답인 칸을 맞히면 시스템 과부하를 일으켜 큰 피해를 입습니다.",
            Colors.orangeAccent,
          ),
          _buildMonsterCard(
            "디지털 위스피",
            "HP: 1500 | ATK: 15",
            "데이터 조각들이 모여 만들어진 기이한 생명체입니다. 매우 빠르며, 당신의 집중력을 흐트러뜨리기 위해 화면에 노이즈를 발생시킵니다.",
            Colors.cyanAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildMonsterCard(
    String name,
    String stats,
    String desc,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.adb, color: color, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              stats,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
            ),
          ],
        ),
      ),
    );
  }
}

class DevLogView extends StatelessWidget {
  const DevLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Development Log")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildLogEntry(
            "2026-02-09",
            "대규모 콘텐츠 업데이트: 지식의 보고 개방",
            "Google의 품질 가이드라인을 준수하고 사용자에게 더욱 가치 있는 정보를 제공하기 위해 콘텐츠 대개편을 단행했습니다. "
                "단순 가이드를 넘어 X-Wing, Swordfish 등 전문가용 스도쿠 기술 설명을 추가하고, 던전 등급별 상세 공략 지침을 수립했습니다. "
                "또한 몬스터들의 배경 스토리(Lore)를 보강하여 Sudoku RPG만의 독창적인 세계관을 구축했습니다. "
                "웹 검색 최적화(SEO) 및 메타데이터 강화를 통해 더 많은 용사들이 이 여정에 동참할 수 있도록 기반을 마련했습니다.",
          ),
          _buildLogEntry(
            "2026-02-09",
            "전투 인터페이스 최적화: 메모 기능의 독립성 확보",
            "용사들의 피드백을 반영하여 메모(Notes) 기능을 전투 로직에서 완전히 분리했습니다. 이제 메모 모드에서는 실수로 인한 데미지 걱정 없이 자유롭게 전략을 구상할 수 있습니다. "
                "또한, 정답을 확정하는 순간 주변의 불필요한 메모들이 마법처럼 사라지는 '자동 정화' 시스템을 도입하여 퍼즐 풀이의 쾌적함을 극대화했습니다.",
          ),
          _buildLogEntry(
            "2026-02-05",
            "생동감 넘치는 전장: 몬스터 타격 리액션 고도화",
            "투사체가 몬스터에 닿는 순간의 '충격량'을 시각적으로 전달하기 위해 4단계 리액션 시스템을 구축했습니다. "
                "타격 시점에 맞춘 몬스터의 좌우 셰이크(Shake), 붉은색 섬광(Red Flash), 실시간 플로팅 데미지 텍스트, 그리고 HP 바의 물리적 진동 연출을 통합하여 "
                "퍼즐의 정답이 실제 물리적 타격으로 이어지는 인과관계를 완성했습니다.",
          ),
          _buildLogEntry(
            "2026-02-05",
            "마법 화살과 파티클: 베지어 곡선을 이용한 투사체 연출",
            "단순한 직선 이동에서 벗어나 2차 베지어 곡선(Quadratic Bézier) 궤적을 도입하여 매번 다른 경로로 날아가는 역동성을 부여했습니다. "
                "CustomPainter를 활용해 혜성 같은 잔상이 남는 마법 화살을 구현하고, 공기 저항과 중력을 모사한 파티클 시스템을 추가하여 RPG 특유의 화려한 타격감을 확보했습니다.",
          ),
          _buildLogEntry(
            "2026-02-05",
            "스도쿠와 전투의 결합: 라인 플래시 및 햅틱 피드백",
            "퍼즐 풀이와 전투 시스템을 유기적으로 연결했습니다. 숫자를 맞히면 해당 행, 열, 3x3 박스가 황금색으로 번쩍이는 라인 플래시 효과를 통해 시각적 보상을 제공하고, "
                "모바일 환경을 고려한 햅틱 피드백(Haptic Feedback)을 적용하여 손끝으로 느껴지는 타격감을 구현했습니다.",
          ),
          _buildLogEntry(
            "2024-02-05",
            "다크 모드 스도쿠의 색채 설계: 알파 블렌딩과 명암비 최적화",
            "사용자가 평균 10분 이상 집중해야 하는 퍼즐 게임에서 배경색과 숫자 사이의 명암비(Contrast Ratio)는 게임의 성패를 가릅니다.\n\n"
                "저희는 단순히 색상을 지정하는 방식에서 벗어나, 기본 배경(0xFF1E293B) 위에 투명도가 적용된 레이어를 중첩하는 Alpha Blending 기법을 도입했습니다. 이를 통해 선택된 행과 열이 은은하게 밝아지는 시각적 가이드를 구현했으며, WCAG 2.1 대비 표준을 준수하여 장시간 플레이 시에도 눈의 피로도를 최소화했습니다.\n\n"
                "특히 34px의 대담한 폰트 크기와 3x3 격자의 시각적 위계 설정은 플레이어가 복잡한 숫자 배열 속에서도 논리적 패턴을 빠르게 포착할 수 있도록 돕습니다.",
          ),
          _buildLogEntry(
            "2024-02-05",
            "UI/UX 개편 및 멀티 뷰 시스템 도입",
            "기본적인 게임 플레이를 넘어, 사용자에게 더 풍부한 정보를 제공하기 위해 사이트 구조를 전면 개편했습니다. "
                "Flutter의 BottomNavigationBar를 활용한 네비게이션 시스템을 구축하고, 가이드와 위키 콘텐츠를 추가하여 앱의 완성도를 높였습니다.",
          ),
          _buildLogEntry(
            "2024-01-30",
            "데이터 영속성 및 레벨 시스템 안정화",
            "LocalStorage를 이용한 사용자 데이터 저장 로직을 개선하여, 브라우저를 새로고침해도 골드와 경험치가 유지되도록 했습니다. "
                "레벨업 시 능력치 증가 및 보너스 골드 지급 트리거를 최적화했습니다.",
          ),
          _buildLogEntry(
            "2024-01-15",
            "전투 엔진 및 Undo 기능 구현",
            "스도쿠 입력값과 전투 데미지를 연동하는 핵심 로직을 완성했습니다. "
                "사용자의 실수를 방지하기 위해 최대 3회까지 가능한 Undo 시스템을 스택 기반으로 구현했습니다.",
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(String date, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 16,
              color: Colors.indigoAccent,
            ),
            const SizedBox(width: 8),
            Text(
              date,
              style: const TextStyle(
                color: Colors.indigoAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 15, color: Colors.white70),
        ),
        const Divider(height: 40, thickness: 1),
      ],
    );
  }
}

class SudokuScreen extends StatefulWidget {
  final bool isGameStarted;
  const SudokuScreen({super.key, this.isGameStarted = true});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen>
    with SingleTickerProviderStateMixin {
  late DungeonMap _dungeonMap; // DungeonMap 인스턴스
  UserData _userData = UserData.initial();
  Monster _currentMonster = MonsterTemplates.numberSlime();
  PlayerCombatStats _playerCombatStats = PlayerCombatStats();
  int? _selectedRow;
  int? _selectedCol;

  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isMemoMode = false;
  int _hintsRemaining = 0;
  final int _maxUndoUses = 3;
  int _undoUses = 0;
  bool _isPaused = false;
  bool _isSuccessAnimation = false;
  bool _showMoveButtons = false; // 방 클리어 후 이동 버튼 표시 여부

  final List<String> _combatLogMessages = [];
  final List<GameState> _history = [];
  int _comboCount = 0;
  DateTime? _lastCorrectEntryTime;

  late AnimationController _screenShakeController;
  late Animation<Offset> _screenShakeAnimation;

  // 연출용 상태 추가
  int? _flashingRow;
  int? _flashingCol;
  final List<Widget> _projectiles = [];
  final List<Widget> _damageEffects = []; // 플로팅 데미지 효과 관리 리스트
  final GlobalKey _monsterKey = GlobalKey();
  final GlobalKey _gridKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _dungeonMap = DungeonMap(); // 던전 맵 초기화
    _currentMonster = MonsterTemplates.getMonsterForRoom(
      _dungeonMap.currentRoom.type,
    ); // 초기 몬스터 설정
    _loadUserData();
    _createNewGame(); // 난이도 선택 기획 변경: 좌표 기반 자동 생성

    _screenShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _screenShakeAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.02, 0)).animate(
            CurvedAnimation(
              parent: _screenShakeController,
              curve: Curves.elasticOut,
            ),
          )
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _screenShakeController.reverse();
            }
          });

    if (widget.isGameStarted) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(SudokuScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 홈 화면에서 게임 시작 버튼을 눌렀을 때 타이머 시작
    if (widget.isGameStarted && !oldWidget.isGameStarted) {
      _startTimer();
    }
  }

  // 현재 방의 SudokuBoard를 가져오는 헬퍼 함수
  SudokuBoard _getCurrentSudokuBoard() => _dungeonMap.currentRoom.board;

  Future<void> _loadUserData() async {
    final UserData loadedData = await LocalStorageService.loadUserData();
    setState(() {
      _userData = loadedData;
    });
  }

  Future<void> _saveUserData() async {
    await LocalStorageService.saveUserData(_userData);
  }

  void _addCombatLog(String message) {
    setState(() {
      if (_combatLogMessages.length >= 10) {
        _combatLogMessages.removeAt(0);
      }
      _combatLogMessages.add(message);
    });
  }

  // Debug cheat function: Fills one empty cell with the correct answer.
  void _fillOneEmptyCellWithAnswer() {
    if (_isPaused || _isSuccessAnimation) return;

    // Find the first empty cell
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (_getCurrentSudokuBoard().currentGrid[r][c] == 0) {
          // Found an empty cell, fill it with the correct answer.
          // We need to set _selectedRow and _selectedCol for _handleNumberInput to work.
          // _handleNumberInput will also save the state to history.
          setState(() {
            _selectedRow = r;
            _selectedCol = c;
          });
          _handleNumberInput(_getCurrentSudokuBoard().solution[r][c]);
          return; // Fill one cell and exit
        }
      }
    }
    _addCombatLog("더 이상 채울 빈 칸이 없습니다!");
  }

  static const Map<Difficulty, int> _baseGold = {
    Difficulty.easy: 15,
    Difficulty.medium: 50,
    Difficulty.hard: 200, // 보상 대폭 강화
  };
  static const Map<Difficulty, int> _baseXp = {
    Difficulty.easy: 60,
    Difficulty.medium: 250,
    Difficulty.hard: 1200, // 보상 대폭 강화
  };

  static const Map<Difficulty, int> _targetTimes = {
    Difficulty.easy: 180,
    Difficulty.medium: 360,
    Difficulty.hard: 600,
  };

  static const Map<Difficulty, double> _difficultyDamageMultiplier = {
    Difficulty.easy: 1.5,
    Difficulty.medium: 1.0,
    Difficulty.hard: 0.8,
  };

  (int, int) _calculateReward({
    required Difficulty difficulty,
    required int timeElapsed,
    required int mistakes,
  }) {
    double gold = _baseGold[difficulty]!.toDouble();
    double xp = _baseXp[difficulty]!.toDouble();

    if (mistakes == 0) {
      gold *= 1.2;
      xp *= 1.2;
      _userData.stats.noMissCount++;
    }

    final targetTime = _targetTimes[difficulty];
    if (targetTime != null && timeElapsed <= targetTime) {
      gold *= 1.3;
      xp *= 1.3;
    }

    _userData.stats.totalCleared++;
    return (gold.toInt(), xp.toInt());
  }

  void _createNewGame([Difficulty? difficulty]) {
    _timer?.cancel();
    setState(() {
      _dungeonMap = DungeonMap(); // 새로운 던전 맵 생성
      _secondsElapsed = 0;
      _isPaused = false;
      _selectedRow = null;
      _selectedCol = null;
      _hintsRemaining = 0;
      _undoUses = 0;
      _isSuccessAnimation = false;
      _showMoveButtons = false; // 새 게임 시작 시 이동 버튼 숨김
      _currentMonster = MonsterTemplates.getMonsterForRoom(
        _dungeonMap.currentRoom.type,
      ); // 현재 방 타입에 맞는 몬스터 로드
      _playerCombatStats = PlayerCombatStats();
      _comboCount = 0;
      _lastCorrectEntryTime = null;
      _history.clear();
      _combatLogMessages.clear();
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _screenShakeController.dispose();
    super.dispose();
  }

  void _onCellTapped(int row, int col) {
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
      _isMemoMode = false;
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _handleUndo() {
    if (_history.isEmpty) {
      _addCombatLog("더 이상 실행 취소할 수 없습니다.");
      return;
    }
    if (_undoUses >= _maxUndoUses) {
      _addCombatLog("실행 취소 횟수를 모두 사용했습니다.");
      return;
    }

    setState(() {
      final lastState = _history.removeLast();
      _dungeonMap = lastState.dungeonMap; // DungeonMap 복원
      _currentMonster = lastState.currentMonster;
      _playerCombatStats = lastState.playerCombatStats;
      _combatLogMessages.clear();
      _combatLogMessages.addAll(lastState.combatLogMessages);
      _combatLogMessages.add("실행 취소됨.");

      _comboCount = lastState.comboCount;
      _lastCorrectEntryTime = lastState.lastCorrectEntryTime;
      _hintsRemaining = lastState.hintsRemaining;
      _undoUses = lastState.undoUses; // 실행 취소 횟수 복원
    });
  }

  bool _isCellCompletionCritical(int row, int col, int number) {
    final tempBoard = _getCurrentSudokuBoard().clone();
    tempBoard.currentGrid[row][col] = number;

    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    bool boxComplete = true;
    for (int rLoop = startRow; rLoop < startRow + 3; rLoop++) {
      for (int cLoop = startCol; cLoop < startCol + 3; cLoop++) {
        if (tempBoard.currentGrid[rLoop][cLoop] == 0) {
          boxComplete = false;
          break;
        }
      }
      if (!boxComplete) break;
    }
    if (boxComplete) return true;

    bool rowComplete = true;
    for (int cLoop = 0; cLoop < 9; cLoop++) {
      if (tempBoard.currentGrid[row][cLoop] == 0) {
        rowComplete = false;
        break;
      }
    }
    if (rowComplete) return true;

    bool colComplete = true;
    for (int rLoop = 0; rLoop < 9; rLoop++) {
      if (tempBoard.currentGrid[rLoop][col] == 0) {
        colComplete = false;
        break;
      }
    }
    if (colComplete) return true;

    return false;
  }

  void _handleNumberInput(int number) {
    if (_selectedRow == null ||
        _selectedCol == null ||
        _isPaused ||
        _isSuccessAnimation)
      return;

    if (_isCellLocked() && number == 0) {
      _handleUndo();
      return;
    }

    if (_isCellLocked()) {
      _addCombatLog("잠긴 칸에는 숫자를 입력할 수 없습니다.");
      return;
    }

    if (!_isMemoMode &&
        number != 0 &&
        _getCurrentSudokuBoard().getCountOfNumber(number) >= 9) {
      _addCombatLog("$number는 이미 9개 모두 채워졌습니다.");
      return;
    }

    _history.add(
      GameState(
        dungeonMap: _dungeonMap.clone(), // DungeonMap 저장
        currentMonster: _currentMonster,
        playerCombatStats: _playerCombatStats,
        combatLogMessages: List<String>.from(_combatLogMessages),
        comboCount: _comboCount,
        lastCorrectEntryTime: _lastCorrectEntryTime,
        hintsRemaining: _hintsRemaining,
        undoUses: _undoUses,
      ),
    );
    if (_history.length > 20) {
      // Limit history size
      _history.removeAt(0);
    }

    final int currentRow = _selectedRow!;
    final int currentCol = _selectedCol!;

    setState(() {
      final isCorrectInput =
          (number == 0) ||
          (number == _getCurrentSudokuBoard().solution[currentRow][currentCol]);

      final bool wasCritical = isCorrectInput && number != 0
          ? _isCellCompletionCritical(currentRow, currentCol, number)
          : false;

      _getCurrentSudokuBoard().setNumber(
        currentRow,
        currentCol,
        number,
        isMemoMode: _isMemoMode,
      );

      if (_isMemoMode) {
        _comboCount = 0;
        _lastCorrectEntryTime = null;
        return;
      }

      if (isCorrectInput && number != 0) {
        final double difficultyMultiplier =
            _difficultyDamageMultiplier[_getCurrentSudokuBoard().difficulty] ??
            1.0;
        double damage =
            number *
            _playerCombatStats.attackPower.toDouble() *
            difficultyMultiplier;
        String logMessage = "$number를 맞혔습니다!";

        if (_lastCorrectEntryTime != null &&
            DateTime.now().difference(_lastCorrectEntryTime!).inSeconds < 3) {
          _comboCount++;
          damage *= (1 + _comboCount * 0.1);
          logMessage += " 콤보! ${_comboCount}연타!";
        } else {
          _comboCount = 1;
        }
        _lastCorrectEntryTime = DateTime.now();

        if (wasCritical) {
          damage *= 2.0;
          logMessage += " 크리티컬!!";
        }

        final int damageDealt = damage.toInt();
        _addCombatLog("$logMessage $damageDealt의 데미지를 준비합니다!");

        // 정답 연출 트리거 (데미지 정보 포함)
        _triggerCorrectAnswerEffects(currentRow, currentCol, damageDealt);
      } else if (!isCorrectInput) {
        _lastCorrectEntryTime = null;

        final int damageTaken = _currentMonster.attackPower;
        _playerCombatStats = _playerCombatStats.copyWith(
          currentHp: (_playerCombatStats.currentHp - damageTaken).clamp(
            0,
            _playerCombatStats.maxHp,
          ),
        );
        _addCombatLog(
          "오답! ${_currentMonster.name}의 반격! $damageTaken 데미지를 받았습니다!",
        );
        _screenShakeController.forward(from: 0.0);

        if (_playerCombatStats.isDefeated()) {
          _addCombatLog("플레이어가 쓰러졌습니다...");
          _handlePlayerDefeat();
        } else {
          _addCombatLog(
            "${_currentMonster.name}이(가) ${currentCol + 1}열을 진흙으로 가렸습니다!",
          );
          _triggerMonsterSpecialAbility();
        }
      } else {
        _comboCount = 0;
        _lastCorrectEntryTime = null;
        _addCombatLog("숫자를 지웠습니다.");
      }
    });
  }

  void _triggerCorrectAnswerEffects(int row, int col, int damageDealt) {
    // 1. 햅틱 피드백
    HapticFeedback.lightImpact();

    // 2. 라인 플래시 효과 (0.3초간 황금색)
    setState(() {
      _flashingRow = row;
      _flashingCol = col;
    });
    Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _flashingRow = null;
          _flashingCol = null;
        });
      }
    });

    // 3. 투사체 애니메이션 생성
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createProjectile(row, col, damageDealt);
    });
  }

  void _createProjectile(int row, int col, int damageDealt) {
    final RenderBox? monsterBox =
        _monsterKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? gridBox =
        _gridKey.currentContext?.findRenderObject() as RenderBox?;

    if (monsterBox == null || gridBox == null || !mounted) return;

    final monsterPos = monsterBox.localToGlobal(
      Offset(monsterBox.size.width / 2, monsterBox.size.height / 2),
    );
    double cellSize = gridBox.size.width / 9;
    Offset startOffset = Offset((col + 0.5) * cellSize, (row + 0.5) * cellSize);
    final startPos = gridBox.localToGlobal(startOffset);

    final RenderBox screenBox = context.findRenderObject() as RenderBox;
    final relativeStart = screenBox.globalToLocal(startPos);
    final relativeEnd = screenBox.globalToLocal(monsterPos);

    late Widget projectile;
    projectile = ProjectileAnimation(
      key: UniqueKey(),
      startPos: relativeStart,
      endPos: relativeEnd,
      onHit: () {
        if (!mounted) return;
        setState(() {
          _projectiles.remove(projectile);

          // 4. 투사체 명중 시 실제 데미지 적용 및 리액션
          _currentMonster = _currentMonster.copyWith(
            currentHp: (_currentMonster.currentHp - damageDealt).clamp(
              0,
              _currentMonster.maxHp,
            ),
          );
          _addCombatLog("${_currentMonster.name}에게 ${damageDealt}의 타격!");

          // 몬스터 위치에서 플로팅 데미지 생성
          _createFloatingDamage(monsterPos, damageDealt);

          _screenShakeController.forward(from: 0.0);

          // 몬스터 처치 확인
          if (_currentMonster.isDefeated()) {
            _addCombatLog("${_currentMonster.name}을(를) 처치했습니다!");
            _applyMonsterDefeatRewards();

            // 퍼즐이 아직 안 끝났다면 다음 몬스터 소환
            if (!_getCurrentSudokuBoard().isSolved()) {
              _loadNextMonster();
            }
          }

          // 퍼즐 완료 확인
          if (!_isMemoMode && _getCurrentSudokuBoard().isSolved()) {
            _timer?.cancel();
            _triggerSuccessSequence();
          }
        });
      },
    );

    setState(() {
      _projectiles.add(projectile);
    });
  }

  void _createFloatingDamage(Offset globalPos, int damage) {
    // 화면 기준 위치로 변환
    final RenderBox screenBox = context.findRenderObject() as RenderBox;
    final relativePos = screenBox.globalToLocal(globalPos);

    late Widget effect;
    effect = FloatingDamage(
      key: UniqueKey(),
      position: relativePos,
      damage: damage,
      onComplete: () {
        if (mounted) {
          setState(() {
            _damageEffects.remove(effect);
          });
        }
      },
    );

    setState(() {
      _damageEffects.add(effect);
    });
  }

  void _applyMonsterDefeatRewards() async {
    _addCombatLog(
      "보상 획득: ${_currentMonster.rewardGold}G, ${_currentMonster.rewardXp}XP",
    );

    final int initialUserLevel = _userData.level;
    _userData.addGold(_currentMonster.rewardGold);
    _userData.addXp(_currentMonster.rewardXp);

    if (_userData.level > initialUserLevel) {
      final int levelsGained = _userData.level - initialUserLevel;
      final int bonusGoldFromLevelUp = levelsGained * 50;
      _userData.addGold(bonusGoldFromLevelUp);
      _addCombatLog(
        "🎉 레벨업! (Lv.$levelsGained UP!) 보너스 $bonusGoldFromLevelUp G 획득!",
      );
    }

    await _saveUserData();
  }

  void _loadNextMonster() {
    setState(() {
      _currentMonster = MonsterTemplates.getMonsterForRoom(
        _dungeonMap.currentRoom.type,
      ); // 현재 방 타입에 맞는 몬스터 로드
      _addCombatLog("야생의 ${_currentMonster.name}이(가) 나타났다!");
    });
  }

  void _handlePlayerDefeat() async {
    _timer?.cancel();
    _screenShakeController.forward(from: 0.0);
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("💀 패배!", textAlign: TextAlign.center),
        content: const Text(
          "플레이어가 쓰러졌습니다. 다시 도전하시겠습니까?",
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _createNewGame();
              },
              child: const Text("다시 도전"),
            ),
          ),
        ],
      ),
    );
  }

  void _triggerMonsterSpecialAbility() {
    _addCombatLog("${_currentMonster.name}이(가) 특수 능력을 사용했습니다!");
  }

  void _triggerSuccessSequence() async {
    if (!mounted) return;
    final BuildContext currentContext = context;

    setState(() {
      _isSuccessAnimation = true;
      _selectedRow = null;
      _selectedCol = null;
      // 이전에 클리어되지 않은 방만 보상 로직을 거치도록 처리
      if (!_dungeonMap.currentRoom.isCleared) {
        _dungeonMap.currentRoom.isCleared = true; // 현재 방 클리어 상태로 변경
      }
      _showMoveButtons = true; // 이동 버튼 표시
    });
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!currentContext.mounted) return;

    // 보상 중복 획득 방지: 이미 클리어된 방이 아니면 보상 지급
    if (_dungeonMap.currentRoom.isCleared) {
      // 클리어 상태를 여기서 다시 확인하여 보상 지급 여부 결정
      final int initialUserLevel = _userData.level;
      final (int earnedGold, int earnedXp) = _calculateReward(
        difficulty: _getCurrentSudokuBoard().difficulty,
        timeElapsed: _secondsElapsed,
        mistakes: _getCurrentSudokuBoard().mistakes,
      );

      _userData.addGold(earnedGold);
      _userData.addXp(earnedXp);

      int bonusGoldFromLevelUp = 0;
      final bool leveledUp = _userData.level > initialUserLevel;
      if (leveledUp) {
        bonusGoldFromLevelUp = (_userData.level - initialUserLevel) * 50;
        _userData.addGold(bonusGoldFromLevelUp);
      }
      await _saveUserData();

      // 보상 정보를 전투 로그에 상세히 출력 (팝업 대신)
      _addCombatLog("✨ 퍼즐 해결! 기록: ${_formatTime(_secondsElapsed)}");
      _addCombatLog("💰 획득 골드: $earnedGold G / 💎 획득 경험치: $earnedXp XP");

      if (leveledUp) {
        _addCombatLog(
          "🎊 레벨업! Lv.${_userData.level - initialUserLevel} 상승! 보너스: $bonusGoldFromLevelUp G",
        );
      }

      _addCombatLog("현재 상태: Lv.${_userData.level} / ${_userData.gold} G");

      // 이동 버튼은 이미 setState에서 true로 설정됨
      setState(() => _isSuccessAnimation = false);
    }
  }

  void _showGameOverDialog() {
    _timer?.cancel();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("게임 오버"),
        content: const Text("실수 횟수를 초과했습니다. 다시 시작하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _createNewGame();
            },
            child: const Text("새 게임"),
          ),
        ],
      ),
    );
  }

  bool _isCellLocked() {
    if (_selectedRow == null || _selectedCol == null) return true;
    int r = _selectedRow!;
    int c = _selectedCol!;

    bool isInitial = _getCurrentSudokuBoard().initialGrid[r][c] != 0;
    bool isCorrectlyFilled =
        _getCurrentSudokuBoard().currentGrid[r][c] != 0 &&
        !_getCurrentSudokuBoard().errorMap[r][c];

    return isInitial || isCorrectlyFilled;
  }

  Widget _buildPauseOverlay() {
    return GestureDetector(
      onTap: _togglePause,
      child: Container(
        color: Colors.white.withOpacity(0.8),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow, size: 80, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                "일시정지됨",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text("화면을 터치하여 재개", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  // 방 이동 로직
  void _moveToRoom(int newX, int newY) {
    setState(() {
      _dungeonMap.move(newX, newY); // 던전 맵의 현재 위치 업데이트
      final RoomData targetRoom =
          _dungeonMap.currentRoom; // 이동 후 현재 방 (targetRoom)

      if (targetRoom.isCleared) {
        _addCombatLog("이미 정복한 지역입니다.");
        _showMoveButtons = true; // 이동 화살표를 바로 보여줌
        // 클리어된 방은 상태를 초기화하지 않고 그대로 보여줌
        _currentMonster = Monster.empty(); // 몬스터 없음
        _timer?.cancel(); // 타이머 중지 (클리어된 방은 시간 흐르지 않음)
      } else {
        // 클리어되지 않은 방으로 이동 시 게임 상태 초기화
        _secondsElapsed = 0; // 타이머 초기화
        _isPaused = false;
        _isSuccessAnimation = false;
        _showMoveButtons = false; // 이동 후 다시 스도쿠 화면으로 전환
        _selectedRow = null;
        _selectedCol = null;
        _hintsRemaining = 0; // 힌트 초기화
        _undoUses = 0; // 실행 취소 횟수 초기화
        _history.clear(); // 기록 초기화
        _combatLogMessages.clear(); // 전투 로그 초기화
        _currentMonster = MonsterTemplates.getMonsterForRoom(
          _dungeonMap.currentRoom.type,
        ); // 현재 방 타입에 맞는 몬스터 로드
        _startTimer(); // 타이머 시작
      }
    });
  }

  // 이동 버튼 위젯 생성 헬퍼
  Widget _buildMoveButton(
    String direction,
    IconData icon,
    int targetX,
    int targetY,
  ) {
    bool canMove =
        (targetX >= 0 &&
        targetX < _dungeonMap.width &&
        targetY >= 0 &&
        targetY < _dungeonMap.height);

    return ElevatedButton(
      onPressed: canMove ? () => _moveToRoom(targetX, targetY) : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        shape: const CircleBorder(),
        backgroundColor: canMove ? Colors.blue : Colors.grey,
        foregroundColor: Colors.white,
      ),
      child: Icon(icon, size: 30),
    );
  }

  // 이동 버튼 UI를 구성하는 위젯
  Widget _buildMoveButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMoveButton(
          "Up",
          Icons.arrow_upward,
          _dungeonMap.currentX,
          _dungeonMap.currentY - 1,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMoveButton(
              "Left",
              Icons.arrow_back,
              _dungeonMap.currentX - 1,
              _dungeonMap.currentY,
            ),
            const SizedBox(width: 80), // 중앙 빈 공간
            _buildMoveButton(
              "Right",
              Icons.arrow_forward,
              _dungeonMap.currentX + 1,
              _dungeonMap.currentY,
            ),
          ],
        ),
        _buildMoveButton(
          "Down",
          Icons.arrow_downward,
          _dungeonMap.currentX,
          _dungeonMap.currentY + 1,
        ),
      ],
    );
  }

  // 실제 게임 화면을 구성하는 헬퍼
  Widget _buildGameScreen() {
    bool isLocked = _isCellLocked();
    return KeyboardListener(
      // 여기에 KeyboardListener 추가
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent && !_isPaused) {
          final label = event.logicalKey.keyLabel;
          if (RegExp(r'^[1-9]$').hasMatch(label)) {
            _handleNumberInput(int.parse(label));
          } else if (label == 'f' || label == 'F') {
            // Check for 'F' key
            _fillOneEmptyCellWithAnswer(); // Call a new function
          } else if (event.logicalKey == LogicalKeyboardKey.backspace ||
              event.logicalKey == LogicalKeyboardKey.delete) {
            _handleNumberInput(0);
          }
        }
      },
      child: Column(
        // KeyboardListener의 child는 Column
        children: [
          GameStatus(
            difficulty:
                "${_getCurrentSudokuBoard().difficulty.label} [${_getCurrentSudokuBoard().difficulty.rpgGrade}]",
            mistakes: _getCurrentSudokuBoard().mistakes,
            maxMistakes: _getCurrentSudokuBoard().maxMistakes,
            time: _formatTime(_secondsElapsed),
            onPauseTap: _togglePause,
            playerLevel: _userData.level,
            playerCurrentHp: _playerCombatStats.currentHp,
            playerMaxHp: _playerCombatStats.maxHp,
            playerCurrentXp: _userData.currentXp,
            playerTotalXpNeeded: _userData.totalXpNeeded,
            playerGold: _userData.gold,
            hintsRemaining: _hintsRemaining,
            undoCount: _undoUses,
            maxUndoCount: _maxUndoUses,
          ),
          const Divider(),

          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.zero, // 패딩 제거로 가로폭 최대 활용
                child: _showMoveButtons
                    ? Stack(
                        // 스도쿠 판 위에 메시지와 이동 버튼을 겹치기
                        children: [
                          SudokuGrid(
                            // 클리어된 방은 이전 스도쿠 판을 그대로 보여줌
                            key: _gridKey,
                            board: _getCurrentSudokuBoard(),
                            onCellTap: _onCellTapped,
                            selectedRow: _selectedRow,
                            selectedCol: _selectedCol,
                            errorMap: _getCurrentSudokuBoard().errorMap,
                            isSuccess: _isSuccessAnimation,
                            flashingRow: _flashingRow,
                            flashingCol: _flashingCol,
                          ),
                          // 클리어된 방일 경우 메시지 오버레이
                          if (_dungeonMap.currentRoom.isCleared)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black54, // 어두운 오버레이
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "이미 정복한 지역입니다!",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium!
                                          .copyWith(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildMoveButtons(), // 이동 버튼
                                  ],
                                ),
                              ),
                            )
                          else // 클리어되지 않은 방이 막 클리어된 경우
                            Positioned.fill(
                              child: Container(
                                color: Colors.black54,
                                child: _buildMoveButtons(), // 이동 버튼만 표시
                              ),
                            ),
                        ],
                      )
                    : SudokuGrid(
                        key: _gridKey,
                        board: _getCurrentSudokuBoard(),
                        onCellTap: _onCellTapped,
                        selectedRow: _selectedRow,
                        selectedCol: _selectedCol,
                        errorMap: _getCurrentSudokuBoard().errorMap,
                        isSuccess: _isSuccessAnimation,
                        flashingRow: _flashingRow,
                        flashingCol: _flashingCol,
                      ),
              ),
            ),
          ),

          CombatLog(logMessages: _combatLogMessages),

          ActionButtons(
            onUndo: (_history.isEmpty || _undoUses >= _maxUndoUses)
                ? null
                : () {
                    _undoUses++; // 실행 취소 횟수 증가
                    _handleUndo();
                  },
            onDelete: (isLocked || _isPaused)
                ? null
                : () => _handleNumberInput(0),
            onMemoToggle: isLocked
                ? null
                : () => setState(() => _isMemoMode = !_isMemoMode),
            isMemoOn: _isMemoMode,
            hintCount: _hintsRemaining,
            onHint:
                (isLocked ||
                    _hintsRemaining <= 0 ||
                    _isPaused ||
                    _selectedRow == null)
                ? null
                : () {
                    setState(() {
                      _history.add(
                        GameState(
                          dungeonMap: _dungeonMap.clone(),
                          currentMonster: _currentMonster,
                          playerCombatStats: _playerCombatStats,
                          combatLogMessages: List<String>.from(
                            _combatLogMessages,
                          ),
                          comboCount: _comboCount,
                          lastCorrectEntryTime: _lastCorrectEntryTime,
                          hintsRemaining: _hintsRemaining,
                          undoUses: _undoUses,
                        ),
                      );
                      if (_history.length > 20) {
                        _history.removeAt(0);
                      }
                      _getCurrentSudokuBoard().giveHint(
                        _selectedRow!,
                        _selectedCol!,
                      );
                      _hintsRemaining--;
                    });
                  },
            undoCount: _undoUses,
            maxUndoCount: _maxUndoUses,
          ),

          NumberKeypad(
            board: _getCurrentSudokuBoard(),
            onNumberTap: (_isPaused || isLocked)
                ? null
                : (n) => _handleNumberInput(n),
          ),
          const AdSenseWidget(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _screenShakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: _screenShakeAnimation.value,
                child: child,
              );
            },
            child: Column(
              children: [
                // 기존 AppBar의 요소를 위젯으로 직접 배치
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Battle Area",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigoAccent,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              _createNewGame();
                            },
                          ),
                          // 강제 클리어 버튼 (개발용)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _dungeonMap.currentRoom.isCleared = true;
                                _showMoveButtons = true;
                                _addCombatLog("현재 방을 강제 클리어했습니다!");
                              });
                            },
                            child: const Text(
                              "Clear",
                              style: TextStyle(color: Colors.white30),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                MonsterStatus(key: _monsterKey, monster: _currentMonster),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                "Map Pos: (${_dungeonMap.currentX}, ${_dungeonMap.currentY})",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                            Expanded(child: _buildGameScreen()),
                          ],
                        ),
                      ),
                      if (MediaQuery.of(context).size.width > 600)
                        MiniMap(dungeonMap: _dungeonMap),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isPaused) _buildPauseOverlay(),
          // 투사체 레이어
          ..._projectiles,
          // 플로팅 데미지 레이어
          ..._damageEffects,
        ],
      ),
    );
  }
}
