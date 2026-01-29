// lib/models/combat_data.dart

class Monster {
  String name;
  int currentHp;
  int maxHp;
  int attackPower; // Damage monster deals to player on player error
  int rewardGold;
  int rewardXp;
  // TODO: Add special abilities (e.g., board obfuscation) later

  Monster({
    required this.name,
    required this.maxHp,
    int? currentHp,
    required this.attackPower,
    required this.rewardGold,
    required this.rewardXp,
  }) : currentHp = currentHp ?? maxHp;

  void takeDamage(int damage) {
    currentHp -= damage;
    if (currentHp < 0) currentHp = 0;
  }

  bool isDefeated() => currentHp <= 0;
}

class PlayerCombatStats {
  int currentHp;
  int maxHp;
  int attackPower; // Base damage player deals

  PlayerCombatStats({
    this.maxHp = 100, // Default player HP
    int? currentHp,
    this.attackPower = 1, // Default player attack power (multiplier for number entered)
  }) : currentHp = currentHp ?? maxHp;

  void takeDamage(int damage) {
    currentHp -= damage;
    if (currentHp < 0) currentHp = 0;
  }

  bool isDefeated() => currentHp <= 0;
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