import 'package:flutter/material.dart';

enum AchievementCategory { combat, puzzle, collection, special }

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
    Achievement(
      id: 'first_victory',
      name: '첫 번째 승리',
      description: '처음으로 몬스터를 정화했습니다.',
      icon: Icons.emoji_events,
      category: AchievementCategory.combat,
      rewardGold: 100,
      rewardGems: 5,
    ),
    Achievement(
      id: 'monster_hunter',
      name: '몬스터 사냥꾼',
      description: '몬스터를 10회 정화했습니다.',
      icon: Icons.security,
      category: AchievementCategory.combat,
      rewardGold: 500,
      rewardGems: 10,
    ),
    Achievement(
      id: 'daily_hero',
      name: '성실한 모험가',
      description: '데일리 챌린지를 클리어했습니다.',
      icon: Icons.calendar_today,
      category: AchievementCategory.special,
      rewardGold: 200,
      rewardGems: 2,
    ),
    Achievement(
      id: 'combo_master',
      name: '콤보 마스터',
      description: '10 콤보 이상을 달성했습니다.',
      icon: Icons.bolt,
      category: AchievementCategory.puzzle,
      rewardGold: 300,
      rewardGems: 3,
    ),
    Achievement(
      id: 'collector_start',
      name: '수집의 시작',
      description: '몬스터 도감을 3종 이상 채웠습니다.',
      icon: Icons.menu_book,
      category: AchievementCategory.collection,
      rewardGold: 400,
      rewardGems: 5,
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
