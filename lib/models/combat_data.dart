// lib/models/combat_data.dart

class Monster {
  final String name;
  final int currentHp;
  final int maxHp;
  final int attackPower; // Damage monster deals to player on player error
  final int rewardGold;
  final int rewardXp;
  // TODO: Add special abilities (e.g., board obfuscation) later

  Monster({
    required this.name,
    required this.maxHp,
    int? currentHp,
    required this.attackPower,
    required this.rewardGold,
    required this.rewardXp,
  }) : currentHp = currentHp ?? maxHp;

  bool isDefeated() => currentHp <= 0;

  Monster copyWith({
    String? name,
    int? currentHp,
    int? maxHp,
    int? attackPower,
    int? rewardGold,
    int? rewardXp,
  }) {
    return Monster(
      name: name ?? this.name,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      attackPower: attackPower ?? this.attackPower,
      rewardGold: rewardGold ?? this.rewardGold,
      rewardXp: rewardXp ?? this.rewardXp,
    );
  }
}

class PlayerCombatStats {
  final int currentHp;
  final int maxHp;
  final int attackPower; // Base damage player deals

  PlayerCombatStats({
    this.maxHp = 100, // Default player HP
    int? currentHp,
    this.attackPower = 100, // Default player attack power (multiplier for number entered)
  }) : currentHp = currentHp ?? maxHp;

  bool isDefeated() => currentHp <= 0;

  PlayerCombatStats copyWith({
    int? currentHp,
    int? maxHp,
    int? attackPower,
  }) {
    return PlayerCombatStats(
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      attackPower: attackPower ?? this.attackPower,
    );
  }
}

// Predefined Monsters
class MonsterTemplates {
  static Monster numberSlime() {
    return Monster(
      name: "숫자 슬라임",
      maxHp: 2000,
      attackPower: 10, // Slime deals 10 damage on player error
      rewardGold: 50,
      rewardXp: 100,
    );
  }
  // TODO: Add more monster types for different difficulties
}