import 'package:sudoku_game/models/dungeon.dart'; // RoomType 임포트
import '../services/localization_service.dart';

class Monster {
  final String name;
  final int currentHp;
  final int maxHp;
  final int attackPower; // Damage monster deals to player on player error
  final int rewardGold;
  final int rewardXp;
  final String description; // 몬스터 상세 설명 추가
  final bool isBoss; // 보스 여부

  Monster({
    required this.name,
    required this.maxHp,
    int? currentHp,
    required this.attackPower,
    required this.rewardGold,
    required this.rewardXp,
    this.description = "이 존재는 아직 정체의 많은 부분이 베일에 싸여 있습니다.",
    this.isBoss = false,
  }) : currentHp = currentHp ?? maxHp;

  // 전투가 없는 방을 위한 빈 몬스터 객체 생성
  factory Monster.empty() {
    return Monster(
      name: L10n.t('monster_none'),
      maxHp: 1, // 최소 HP
      currentHp: 1,
      attackPower: 0,
      rewardGold: 0,
      rewardXp: 0,
      description: L10n.t('monster_none_desc'),
    );
  }

  bool isDefeated() => currentHp <= 0;

  Monster copyWith({
    String? name,
    int? currentHp,
    int? maxHp,
    int? attackPower,
    int? rewardGold,
    int? rewardXp,
    String? description,
    bool? isBoss,
  }) {
    return Monster(
      name: name ?? this.name,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      attackPower: attackPower ?? this.attackPower,
      rewardGold: rewardGold ?? this.rewardGold,
      rewardXp: rewardXp ?? this.rewardXp,
      description: description ?? this.description,
      isBoss: isBoss ?? this.isBoss,
    );
  }
}

class PlayerCombatStats {
  final int currentHp;
  final int maxHp;
  final int attackPower; // Base damage player deals

  PlayerCombatStats({
    required this.maxHp,
    int? currentHp,
    required this.attackPower,
  }) : currentHp = currentHp ?? maxHp;

  bool isDefeated() => currentHp <= 0;

  PlayerCombatStats copyWith({int? currentHp, int? maxHp, int? attackPower}) {
    return PlayerCombatStats(
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      attackPower: attackPower ?? this.attackPower,
    );
  }

  PlayerCombatStats heal(int amount) {
    int newHp = (currentHp + amount).clamp(0, maxHp);
    return copyWith(currentHp: newHp);
  }
}

// Predefined Monsters
class MonsterTemplates {
  static Monster numberSlime() {
    return Monster(
      name: L10n.t('monster_slime_name'),
      maxHp: 2000,
      attackPower: 10, // Slime deals 10 damage on player error
      rewardGold: 50,
      rewardXp: 100,
      description: L10n.t('monster_slime_desc'),
    );
  }

  static Monster numberGolem() {
    return Monster(
      name: L10n.t('monster_golem_name'),
      maxHp: 5000,
      attackPower: 25,
      rewardGold: 150,
      rewardXp: 300,
      description: L10n.t('monster_golem_desc'),
    );
  }

  static Monster sudokuDragon() {
    return Monster(
      name: "스도쿠 드래곤",
      maxHp: 10000,
      attackPower: 50,
      rewardGold: 500,
      rewardXp: 1000,
    );
  }

  // 테마별 몬스터 리스트 정의 (도감용 및 생성용)
  static Map<String, List<Monster>> getThemeMonsterTemplates() {
    return {
      "고요한 시작의 숲": [
        Monster(
          name: "새싹 슬라임",
          maxHp: 1500,
          attackPower: 8,
          rewardGold: 40,
          rewardXp: 80,
          description:
              "숫자 정원의 입구에서 흔히 발견되는 작고 투명한 슬라임입니다. 머리 위에 돋아난 작은 새싹은 정원의 맑은 기운을 흡수합니다.",
        ),
        Monster(
          name: "나무껍질 슬라임",
          maxHp: 2200,
          attackPower: 12,
          rewardGold: 55,
          rewardXp: 110,
          description:
              "오래된 나무의 정수를 흡수하여 몸체가 단단해진 슬라임입니다. 일반적인 슬라임보다 방어력이 높습니다.",
        ),
        Monster(
          name: "꽃망울 요정",
          maxHp: 1800,
          attackPower: 15,
          rewardGold: 60,
          rewardXp: 120,
          description:
              "정원의 꽃들이 혼돈에 물들어 변형된 모습입니다. 아름다운 외모 뒤에 날카로운 꽃잎 공격을 숨기고 있습니다.",
        ),
        Monster(
          name: "숲의 파수꾼",
          maxHp: 5000,
          attackPower: 25,
          rewardGold: 150,
          rewardXp: 300,
          description:
              "시작의 숲 깊은 곳을 지키는 고대의 수호자입니다. 논리의 질서를 흐트러뜨리는 자들을 가차 없이 응징합니다.",
        ),
        Monster(
          name: "태초의 숲 군주",
          maxHp: 12000,
          attackPower: 50,
          rewardGold: 600,
          rewardXp: 1200,
          description:
              "시작의 숲 전체를 다스리는 거대한 존재입니다. 그가 내뿜는 정화의 기운은 혼돈에 물든 수많은 숫자를 원래대로 되돌리는 힘이 있습니다.",
          isBoss: true,
        ),
      ],
      "타오르는 심연의 굴": [
        Monster(
          name: "불꽃 불순물",
          maxHp: 3000,
          attackPower: 18,
          rewardGold: 80,
          rewardXp: 160,
          description:
              "용암 속에서 태어난 작은 불꽃의 찌꺼기들입니다. 작지만 매우 뜨거우며, 접근하는 것만으로도 열기를 느낄 수 있습니다.",
        ),
        Monster(
          name: "용암 방울 숫괴물",
          maxHp: 4000,
          attackPower: 22,
          rewardGold: 100,
          rewardXp: 200,
          description:
              "용암이 숫자의 결정체와 결합하여 자의식을 갖게 된 존재입니다. 뜨거운 용암을 내뿜어 침입자를 공격합니다.",
        ),
        Monster(
          name: "마그마 가고일",
          maxHp: 5500,
          attackPower: 28,
          rewardGold: 130,
          rewardXp: 260,
          description:
              "동굴의 천장에 매달려 있다가 순식간에 낙하하여 공격하는 바위 괴물입니다. 몸 전체가 굳은 용암으로 이루어져 있습니다.",
        ),
        Monster(
          name: "화염 정령",
          maxHp: 10000,
          attackPower: 45,
          rewardGold: 400,
          rewardXp: 800,
          description:
              "심연의 굴의 순수한 에너지가 형상화된 존재입니다. 그의 주변은 너무 뜨거워 공기조차 일렁이며 숫자의 형상을 일그러뜨립니다.",
        ),
        Monster(
          name: "심연의 염황",
          maxHp: 25000,
          attackPower: 85,
          rewardGold: 1500,
          rewardXp: 3000,
          description:
              "동굴 깊은 곳, 만물을 태우는 태초의 불꽃을 다스리는 절대자입니다. 그의 분노는 모든 논리를 재로 만들어버릴 만큼 강력합니다.",
          isBoss: true,
        ),
      ],
      "꽁꽁 얼어붙은 성벽": [
        Monster(
          name: "얼음 조각 숫자병",
          maxHp: 6000,
          attackPower: 35,
          rewardGold: 180,
          rewardXp: 360,
          description:
              "성벽을 지키는 병사들의 영혼이 얼음 속에 갇혀 만들어진 존재입니다. 차가운 얼음 창으로 오차 없는 공격을 가해옵니다.",
        ),
        Monster(
          name: "서리 눈사람",
          maxHp: 7500,
          attackPower: 40,
          rewardGold: 220,
          rewardXp: 440,
          description:
              "귀여운 겉모습과 달리, 내부에는 날카로운 얼음 가시를 품고 있는 위험한 존재입니다. 눈보라를 일으켜 시야를 방해합니다.",
        ),
        Monster(
          name: "냉기 유령",
          maxHp: 9000,
          attackPower: 48,
          rewardGold: 280,
          rewardXp: 560,
          description:
              "추위 때문에 육체를 잃고 영혼만 남은 존재입니다. 만지는 모든 것을 얼려버리며 숫자의 배열을 경직시킵니다.",
        ),
        Monster(
          name: "얼어붙은 숫거인",
          maxHp: 18000,
          attackPower: 75,
          rewardGold: 800,
          rewardXp: 1600,
          description:
              "성벽의 일부가 살아 움직이는 듯한 거대한 얼음 괴물입니다. 그의 발구르기 한 번에 성 전체가 진동합니다.",
        ),
        Monster(
          name: "얼음 여왕",
          maxHp: 45000,
          attackPower: 130,
          rewardGold: 3000,
          rewardXp: 6000,
          description:
              "얼어붙은 성의 진정한 주인입니다. 차갑고 고결한 그녀의 마음은 어떤 논리적 허점도 용납하지 않는 완벽함을 지향합니다.",
          isBoss: true,
        ),
      ],
      "공허의 마법 도서관": [
        Monster(
          name: "서적 악령",
          maxHp: 12000,
          attackPower: 65,
          rewardGold: 400,
          rewardXp: 800,
          description:
              "금지된 마도서 속에 깃든 악한 의지입니다. 페이지 사이사이에 숨겨진 오답의 공식으로 마법사들을 미치게 만듭니다.",
        ),
        Monster(
          name: "잉크 환영",
          maxHp: 14000,
          attackPower: 75,
          rewardGold: 500,
          rewardXp: 1000,
          description:
              "쏟아진 잉크가 숫자의 마법과 반응하여 생명을 얻었습니다. 흐물거리는 몸체로 공격을 흘려보내며 환영 숫자를 만들어냅니다.",
        ),
        Monster(
          name: "지식 탐구자 미믹",
          maxHp: 16000,
          attackPower: 85,
          rewardGold: 600,
          rewardXp: 1200,
          description:
              "오래된 보물상자로 위장하고 지식을 탐내는 자들을 사냥합니다. 상자 안에는 보석 대신 뒤틀린 수식들이 가득합니다.",
        ),
        Monster(
          name: "도서관 사서",
          maxHp: 32000,
          attackPower: 140,
          rewardGold: 1800,
          rewardXp: 3600,
          description:
              "도서관의 질서를 유지하던 자였으나 공허에 잠식되었습니다. 정숙을 강요하며 논리적 사고를 마비시키는 주문을 외웁니다.",
        ),
        Monster(
          name: "공허의 현자",
          maxHp: 80000,
          attackPower: 240,
          rewardGold: 7000,
          rewardXp: 14000,
          description:
              "도서관 가장 깊은 곳, 공허의 지식을 깨우친 존재입니다. 그는 정답이 없는 퍼즐을 만들어 모든 존재를 무(無)로 돌리고자 합니다.",
          isBoss: true,
        ),
      ],
      "황금빛 신들의 성전": [
        Monster(
          name: "황금 갑주 숫자병",
          maxHp: 25000,
          attackPower: 120,
          rewardGold: 1000,
          rewardXp: 2000,
          description:
              "신들의 성전을 수호하는 황금빛 갑옷을 입은 병사입니다. 그의 창 끝은 태양의 빛을 담아 오답의 어둠을 꿰뚫습니다.",
        ),
        Monster(
          name: "영혼의 결정",
          maxHp: 30000,
          attackPower: 150,
          rewardGold: 1400,
          rewardXp: 2800,
          description:
              "죽은 용사들의 순수한 논리가 응집되어 만들어진 눈부신 결정체입니다. 강력한 신성 마법으로 부정한 침입자를 배척합니다.",
        ),
        Monster(
          name: "빛 사자",
          maxHp: 35000,
          attackPower: 180,
          rewardGold: 1800,
          rewardXp: 3600,
          description:
              "성전의 마법 통로를 가로막는 빛의 맹수입니다. 빛의 속도로 움직이며 숫자의 빈틈을 허용하지 않는 예리함을 가졌습니다.",
        ),
        Monster(
          name: "타락한 천사",
          maxHp: 70000,
          attackPower: 320,
          rewardGold: 5000,
          rewardXp: 10000,
          description:
              "한때 신들의 사자였으나 인간들의 오답에 실망하여 타락했습니다. 그는 완벽하지 않은 자의 몰락을 가장 큰 기쁨으로 여깁니다.",
        ),
        Monster(
          name: "태양의 신",
          maxHp: 200000,
          attackPower: 600,
          rewardGold: 20000,
          rewardXp: 40000,
          description:
              "숫자 정원의 모든 질서와 빛의 근원입니다. 그는 정화의 마지막 시험을 주관하며, 오직 완벽한 논리를 가진 자만을 축복할 것입니다.",
          isBoss: true,
        ),
      ],
    };
  }

  // 테마별 몬스터 생성
  static Monster getMonsterForTheme(
    RoomType type,
    String themeName,
    int level,
  ) {
    if (type == RoomType.shop) return Monster.empty();

    final themeTemplates = getThemeMonsterTemplates();
    // 테마 명칭이 정확히 일치하지 않을 경우를 대비해 포함 여부로 확인
    String matchedKey = themeTemplates.keys.firstWhere(
      (key) => themeName.contains(key),
      orElse: () => "고요한 시작의 숲",
    );

    List<Monster> monsters = themeTemplates[matchedKey]!;
    Monster selected;

    switch (type) {
      case RoomType.boss:
        selected = monsters[4]; // 마지막 5번째는 항상 보스
        break;
      case RoomType.elite:
        selected = monsters[3]; // 4번째는 정예
        break;
      case RoomType.normal:
      default:
        // 일반 방은 1~3번 중 랜덤 또는 순차적 (여기서는 시드 기반 무작위가 좋지만 간단히 레벨/위치 기반 선택 가능)
        // 일단 0~2 인덱스 중 하나 선택
        int idx = (level + (DateTime.now().millisecond)) % 3;
        selected = monsters[idx];
        break;
    }

    // 기본 레벨에 따른 추가 스케일링 (테마 기본 밸런스 외에 플레이어 성장에 맞춤)
    double levelScale = 1.0 + (level * 0.05);

    return selected.copyWith(
      maxHp: (selected.maxHp * levelScale).toInt(),
      currentHp: (selected.maxHp * levelScale).toInt(),
      attackPower: (selected.attackPower * levelScale).toInt(),
      rewardGold: (selected.rewardGold * levelScale).toInt(),
      rewardXp: (selected.rewardXp * levelScale).toInt(),
      isBoss: selected.isBoss,
    );
  }

  // 기존 코드와의 호환성을 위해 유지 (필요시 삭제 가능)
  static Monster getMonsterForRoom(RoomType type) {
    switch (type) {
      case RoomType.normal:
        return numberSlime();
      case RoomType.elite:
        return numberGolem();
      case RoomType.boss:
        return sudokuDragon();
      case RoomType.shop:
        return Monster.empty();
    }
  }
}
