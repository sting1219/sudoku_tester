import 'package:flutter/material.dart';

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
            color: Colors.indigo.withValues(alpha: 0.3),
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
