import 'package:flutter/material.dart';

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
                color: color.withValues(alpha: 0.2),
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
