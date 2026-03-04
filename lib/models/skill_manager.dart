// lib/models/skill_manager.dart

import 'combat_data.dart';
import 'user_data.dart';

class Skill {
  final String id;
  final String name;
  final String description;
  final Function(SkillContext context) onTrigger;

  Skill({
    required this.id,
    required this.name,
    required this.description,
    required this.onTrigger,
  });
}

class SkillContext {
  final int inputNumber;
  final Monster currentMonster;
  final PlayerCombatStats playerStats;
  final int comboCount;

  SkillContext({
    required this.inputNumber,
    required this.currentMonster,
    required this.playerStats,
    required this.comboCount,
  });
}

class SkillManager {
  static final List<Skill> allSkills = [
    Skill(
      id: 'lucky_seven',
      name: '럭키 7',
      description: '숫자 7을 맞힐 때마다 몬스터에게 777의 추가 데미지를 입힙니다.',
      onTrigger: (context) {
        if (context.inputNumber == 7) {
          return 777;
        }
        return 0;
      },
    ),
    Skill(
      id: 'combo_master',
      name: '콤보 마스터',
      description: '5콤보 이상일 때 데미지가 1.5배 보너스를 받습니다.',
      onTrigger: (context) {
        // 이 스킬은 데미지 계산식에서 별도로 처리할 수도 있지만,
        // 여기서는 추가 데미지 형태로 반환하거나 배율 정보를 전달할 수 있습니다.
        return 0;
      },
    ),
  ];

  static int calculateBonusDamage(UserData userData, SkillContext context) {
    int totalBonus = 0;
    for (var skillId in userData.unlockedSkillIds) {
      final skill = allSkills.firstWhere(
        (s) => s.id == skillId,
        orElse: () => _emptySkill(),
      );
      if (skill.id != 'unknown') {
        final result = skill.onTrigger(context);
        if (result is int) {
          totalBonus += result;
        }
      }
    }
    return totalBonus;
  }

  static Skill _emptySkill() =>
      Skill(id: 'unknown', name: '', description: '', onTrigger: (_) => 0);
}
