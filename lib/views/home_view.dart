import 'package:flutter/material.dart';
import '../widgets/firefly_background.dart';
import '../widgets/archive_view.dart';
import '../models/user_data.dart';
import 'sudoku_screen.dart';
import 'privacy_policy_view.dart';
import 'terms_of_service_view.dart'; // Added this import

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

        Expanded(
          child: FireflyBackground(
            child: Stack(
              children: [
                SudokuScreen(isGameStarted: isStarted),
                if (!isStarted)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.8),
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
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: () {
                                  LocalStorageService.loadUserData().then((
                                    data,
                                  ) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ArchiveView(stats: data.stats),
                                      ),
                                    );
                                  });
                                },
                                icon: const Icon(
                                  Icons.inventory_2,
                                  color: Colors.amber,
                                ),
                                label: const Text(
                                  "아카이브 (도감)",
                                  style: TextStyle(color: Colors.amber),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.amber),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 15,
                                  ),
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
                                    fontFamily: 'NanumGothic',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 16,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const PrivacyPolicyView(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "개인정보처리방침",
                                      style: TextStyle(
                                        color: Colors.white24,
                                        fontSize: 11,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const TermsOfServiceView(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "이용약관",
                                      style: TextStyle(
                                        color: Colors.white24,
                                        fontSize: 11,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
