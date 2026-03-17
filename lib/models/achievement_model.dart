import 'package:flutter/material.dart';

enum AchievementCategory { combat, puzzle, growth, collection, special }

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final AchievementCategory category;
  final bool isHidden;
  final int rewardGold;
  final int rewardGems;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.category = AchievementCategory.special,
    this.isHidden = false,
    this.rewardGold = 0,
    this.rewardGems = 0,
  });
}

class AchievementTemplates {
  static const List<Achievement> allAchievements = [
    // --- 전투 (Combat) ---
    Achievement(
      id: 'first_purification',
      name: '첫 걸음',
      description: '첫 몬스터를 정화했습니다.',
      icon: Icons.directions_walk,
      category: AchievementCategory.combat,
      rewardGold: 100,
    ),
    Achievement(
      id: 'slayer_10',
      name: '견습 사냥꾼',
      description: '몬스터 10마리를 정화했습니다.',
      icon: Icons.shutter_speed,
      category: AchievementCategory.combat,
      rewardGold: 200,
    ),
    Achievement(
      id: 'slayer_100',
      name: '학살자',
      description: '몬스터 100마리를 정화했습니다.',
      icon: Icons.colorize,
      category: AchievementCategory.combat,
      rewardGold: 1000, // 보상: 공격력 펜 아이템 (추후 인벤토리 연동 시 고려)
      rewardGems: 5,
    ),
    Achievement(
      id: 'slayer_500',
      name: '베테랑 전사',
      description: '몬스터 500마리를 정화했습니다.',
      icon: Icons.military_tech,
      category: AchievementCategory.combat,
      rewardGold: 5000,
      rewardGems: 20,
    ),
    Achievement(
      id: 'slayer_1000',
      name: '전설의 도살자',
      description: '몬스터 1000마리를 정화했습니다.',
      icon: Icons.dangerous,
      category: AchievementCategory.combat,
      rewardGold: 20000,
      rewardGems: 100,
    ),
    Achievement(
      id: 'boss_counter_5',
      name: '보스 카운터',
      description: '테마 보스를 5회 처치했습니다.',
      icon: Icons.gavel,
      category: AchievementCategory.combat,
      rewardGold: 500,
      rewardGems: 10,
    ),
    Achievement(
      id: 'boss_hunter_10',
      name: '전문 보스 사냥꾼',
      description: '테마 보스를 10회 처치했습니다.',
      icon: Icons.workspace_premium,
      category: AchievementCategory.combat,
      rewardGold: 2000,
      rewardGems: 30,
    ),
    Achievement(
      id: 'boss_temple',
      name: '신들의 정복자',
      description: '성전의 보스를 처치했습니다.',
      icon: Icons.wb_sunny,
      category: AchievementCategory.combat,
      rewardGold: 5000,
      rewardGems: 50,
    ),

    // --- 스도쿠 실력 (Puzzle) ---
    Achievement(
      id: 'perfectionist',
      name: '완벽주의자',
      description: '실수 없이 한 판을 완료했습니다.',
      icon: Icons.verified,
      category: AchievementCategory.puzzle,
      rewardGold: 500, // 보상: '무결점' 칭호 (UI 표시용)
      rewardGems: 10,
    ),
    Achievement(
      id: 'fast_hand_3',
      name: '신속의 손',
      description: '3분 이내에 정화를 완료했습니다.',
      icon: Icons.timer_3,
      category: AchievementCategory.puzzle,
      rewardGold: 300, // 보상: 시간 정지 포션 3개 (아이템 시스템 연동 시)
      rewardGems: 5,
    ),
    Achievement(
      id: 'fast_hand_1',
      name: '빛보다 빠른 손',
      description: '1분 이내에 정화를 완료했습니다.',
      icon: Icons.bolt,
      category: AchievementCategory.puzzle,
      rewardGold: 1000,
      rewardGems: 20,
    ),
    Achievement(
      id: 'combo_50',
      name: '연속 정화',
      description: '콤보 50회를 달성했습니다.',
      icon: Icons.auto_awesome,
      category: AchievementCategory.puzzle,
      rewardGold: 400, // 보상: 경험치 부스터
      rewardGems: 5,
    ),
    Achievement(
      id: 'combo_100',
      name: '콤보의 신',
      description: '콤보 100회를 달성했습니다.',
      icon: Icons.all_inclusive,
      category: AchievementCategory.puzzle,
      rewardGold: 2000,
      rewardGems: 50,
    ),
    Achievement(
      id: 'total_correct_1000',
      name: '논리의 달인',
      description: '누적 1,000개의 숫자를 올바르게 배치했습니다.',
      icon: Icons.calculate,
      category: AchievementCategory.puzzle,
      rewardGold: 1000,
      rewardGems: 10,
    ),

    // --- 성장 (Growth) ---
    Achievement(
      id: 'rich_10000',
      name: '부자',
      description: '10,000 골드를 보유했습니다.',
      icon: Icons.savings,
      category: AchievementCategory.growth,
      rewardGold: 0, // 보상: 황금 스도쿠 스킨
      rewardGems: 10,
    ),
    Achievement(
      id: 'millionaire',
      name: '자산가',
      description: '100,000 골드를 모았습니다.',
      icon: Icons.monetization_on,
      category: AchievementCategory.growth,
      rewardGold: 5000,
      rewardGems: 50,
    ),
    Achievement(
      id: 'purifier_lv_50',
      name: '만렙 정화가',
      description: '레벨 50을 달성했습니다.',
      icon: Icons.trending_up,
      category: AchievementCategory.growth,
      rewardGold: 5000, // 보상: 전설급 지우개 장비
      rewardGems: 100,
    ),
    Achievement(
      id: 'lev_100',
      name: '최고의 군주',
      description: '레벨 100을 달성했습니다.',
      icon: Icons.star,
      category: AchievementCategory.growth,
      rewardGold: 100000,
      rewardGems: 500,
    ),
    Achievement(
      id: 'atk_100',
      name: '강력한 타격',
      description: '공격력 100 이상을 달성했습니다.',
      icon: Icons.hardware,
      category: AchievementCategory.growth,
      rewardGold: 1000,
      rewardGems: 10,
    ),
    Achievement(
      id: 'hp_10000',
      name: '강철의 신체',
      description: '최대 체력 10,000 이상을 달성했습니다.',
      icon: Icons.favorite,
      category: AchievementCategory.growth,
      rewardGold: 1000,
      rewardGems: 10,
    ),

    // --- 수집 (Collection) ---
    Achievement(
      id: 'collector_10',
      name: '수집가',
      description: '몬스터 도감을 10종 개방했습니다.',
      icon: Icons.menu_book,
      category: AchievementCategory.collection,
      rewardGold: 1000,
      rewardGems: 50,
    ),
    Achievement(
      id: 'collector_full',
      name: '도감 마스터',
      description: '도감의 모든 몬스터를 발견했습니다.',
      icon: Icons.auto_stories,
      category: AchievementCategory.collection,
      rewardGold: 10000,
      rewardGems: 200,
    ),

    // --- 진행 단계 업적 (추가 30여개) ---
    // (레벨 단계)
    Achievement(
      id: 'lv_5',
      name: '꿈틀대는 힘',
      description: '레벨 5 달성',
      icon: Icons.keyboard_double_arrow_up,
      category: AchievementCategory.growth,
      rewardGold: 500,
    ),
    Achievement(
      id: 'lv_20',
      name: '중견 모험가',
      description: '레벨 20 달성',
      icon: Icons.keyboard_double_arrow_up,
      category: AchievementCategory.growth,
      rewardGold: 2000,
    ),
    Achievement(
      id: 'lv_30',
      name: '숙련된 손길',
      description: '레벨 30 달성',
      icon: Icons.keyboard_double_arrow_up,
      category: AchievementCategory.growth,
      rewardGold: 3000,
    ),

    // (처치 단계)
    Achievement(
      id: 'kill_50',
      name: '사냥꾼의 본능',
      description: '몬스터 50마리 처치',
      icon: Icons.radar,
      category: AchievementCategory.combat,
      rewardGold: 500,
    ),
    Achievement(
      id: 'kill_250',
      name: '정화의 화신',
      description: '몬스터 250마리 처치',
      icon: Icons.flash_on,
      category: AchievementCategory.combat,
      rewardGold: 2500,
    ),

    // (테마 클리어)
    Achievement(
      id: 'clear_forest',
      name: '숲의 해방자',
      description: '시작의 숲 테마를 완전히 정복했습니다.',
      icon: Icons.park,
      category: AchievementCategory.combat,
      rewardGold: 1000,
    ),
    Achievement(
      id: 'clear_cave',
      name: '동굴의 탐험가',
      description: '심연의 굴 테마를 완전히 정복했습니다.',
      icon: Icons.volcano,
      category: AchievementCategory.combat,
      rewardGold: 2000,
    ),
    Achievement(
      id: 'clear_wall',
      name: '성벽의 수호자',
      description: '얼어붙은 성벽 테마를 완전히 정복했습니다.',
      icon: Icons.castle,
      category: AchievementCategory.combat,
      rewardGold: 3000,
    ),
    Achievement(
      id: 'clear_library',
      name: '도서관의 학자',
      description: '마법 도서관 테마를 완전히 정복했습니다.',
      icon: Icons.architecture,
      category: AchievementCategory.combat,
      rewardGold: 4000,
    ),

    // (콤보 및 시간)
    Achievement(
      id: 'combo_20',
      name: '리듬을 타는 중',
      description: '20 콤보 달성',
      icon: Icons.music_note,
      category: AchievementCategory.puzzle,
      rewardGold: 500,
    ),
    Achievement(
      id: 'fast_hand_2',
      name: '신속 정화',
      description: '2분 이내 클리어',
      icon: Icons.speed,
      category: AchievementCategory.puzzle,
      rewardGold: 1000,
    ),

    // (도감 단계)
    Achievement(
      id: 'coll_5',
      name: '관찰자',
      description: '도감 5종 개방',
      icon: Icons.visibility,
      category: AchievementCategory.collection,
      rewardGold: 500,
    ),
    Achievement(
      id: 'coll_15',
      name: '박물학자',
      description: '도감 15종 개방',
      icon: Icons.science,
      category: AchievementCategory.collection,
      rewardGold: 3000,
    ),
    Achievement(
      id: 'coll_20',
      name: '정원의 대백과',
      description: '도감 20종 개방',
      icon: Icons.library_books,
      category: AchievementCategory.collection,
      rewardGold: 5000,
    ),

    // (골드 및 젬)
    Achievement(
      id: 'gold_5000',
      name: '푼돈 수집가',
      description: '5,000 골드 누적',
      icon: Icons.toll,
      category: AchievementCategory.growth,
      rewardGold: 500,
    ),
    Achievement(
      id: 'gold_50000',
      name: '상인 연합 초대권',
      description: '50,000 골드 누적',
      icon: Icons.shopping_bag,
      category: AchievementCategory.growth,
      rewardGold: 5000,
    ),
    Achievement(
      id: 'gem_100',
      name: '유료 재화의 맛',
      description: '보석 100개 획득',
      icon: Icons.diamond,
      category: AchievementCategory.growth,
      rewardGold: 1000,
    ),

    // (연속 행동 및 특수한 상황)
    Achievement(
      id: 'daily_3',
      name: '성실함의 증거',
      description: '데일리 챌린지 3회 클리어',
      icon: Icons.event_available,
      category: AchievementCategory.special,
      rewardGold: 1000,
    ),
    Achievement(
      id: 'daily_7',
      name: '규칙적인 습관',
      description: '데일리 챌린지 7회 클리어',
      icon: Icons.event_note,
      category: AchievementCategory.special,
      rewardGold: 5000,
    ),
    Achievement(
      id: 'no_hint',
      name: '진정한 지천명',
      description: '힌트 없이 고난도 한 판 클리어',
      icon: Icons.lightbulb_outline,
      category: AchievementCategory.puzzle,
      rewardGold: 2000,
    ),
    Achievement(
      id: 'survivor',
      name: '기사회생',
      description: '체력 10% 이하에서 승리',
      icon: Icons.heart_broken,
      category: AchievementCategory.combat,
      rewardGold: 1000,
    ),
    Achievement(
      id: 'undefeatable',
      name: '철벽 방어',
      description: '한 판 동안 데미지 한 번도 안 입음',
      icon: Icons.shield,
      category: AchievementCategory.puzzle,
      rewardGold: 2000,
    ),

    // (숫자별 상호작용)
    Achievement(
      id: 'one_lover',
      name: '1의 수호자',
      description: '숫자 1을 100번 입력',
      icon: Icons.looks_one,
      category: AchievementCategory.puzzle,
      rewardGold: 500,
    ),
    Achievement(
      id: 'nine_master',
      name: '9의 마스터리',
      description: '숫자 9로 마지막 칸 채우기 10회',
      icon: Icons.filter_9_plus,
      category: AchievementCategory.puzzle,
      rewardGold: 2000,
    ),

    // (상점 이용)
    Achievement(
      id: 'shopper',
      name: '단골 손님',
      description: '상점 누적 구매 10회',
      icon: Icons.shopping_cart,
      category: AchievementCategory.special,
      rewardGold: 1000,
    ),
    Achievement(
      id: 'big_spender',
      name: '큰손',
      description: '상점 한 번에 5,000골드 지출',
      icon: Icons.payments,
      category: AchievementCategory.special,
      rewardGold: 2000,
    ),

    // (기타 - 채우기)
    Achievement(
      id: 'early_bird',
      name: '얼리버드',
      description: '첫 게임 30초 이내 종료',
      icon: Icons.wb_twilight,
      category: AchievementCategory.special,
      rewardGold: 500,
    ),
    Achievement(
      id: 'night_owl',
      name: '밤샘 정화가',
      description: '심야 시간대 클리어',
      icon: Icons.nightlight_round,
      category: AchievementCategory.special,
      rewardGold: 500,
    ),
    Achievement(
      id: 'lucky_lucky',
      name: '행운의 주인공',
      description: '몬스터 보상에서 크리티컬 잭팟 발생',
      icon: Icons.casino,
      category: AchievementCategory.special,
      rewardGold: 777,
    ),
    Achievement(
      id: 'undo_limit',
      name: '실수는 없다',
      description: 'Undo 30번 사용하고 결국 클리어',
      icon: Icons.undo,
      category: AchievementCategory.puzzle,
      rewardGold: 1000,
    ),
    Achievement(
      id: 'ranking_entry',
      name: '전당 입성',
      description: '처음으로 랭킹에 이름 등록',
      icon: Icons.list_alt,
      category: AchievementCategory.special,
      rewardGold: 5000,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return allAchievements.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
