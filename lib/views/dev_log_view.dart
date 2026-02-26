import 'package:flutter/material.dart';

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
          _buildLogEntry(
            "2024-01-05", // 중복 날짜 수정
            "초기 아키텍처 설계",
            "스도쿠 로직과 RPG 요소의 결합을 위한 기본 프레임워크를 설계했습니다.",
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
