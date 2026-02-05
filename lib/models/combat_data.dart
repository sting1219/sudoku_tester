// lib/models/combat_data.dart
import 'package:sudoku_game/models/dungeon.dart'; // RoomType 임포트

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

  // 전투가 없는 방을 위한 빈 몬스터 객체 생성
  factory Monster.empty() {
    return Monster(
      name: "없음",
      maxHp: 1, // 최소 HP
      currentHp: 1,
      attackPower: 0,
      rewardGold: 0,
      rewardXp: 0,
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

  static Monster numberGolem() {
    return Monster(
      name: "숫자 골렘",
      maxHp: 5000,
      attackPower: 25,
      rewardGold: 150,
      rewardXp: 300,
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

  // RoomType에 따라 다른 몬스터를 반환하는 메서드
  static Monster getMonsterForRoom(RoomType type) {
    switch (type) {
      case RoomType.normal:
        return numberSlime();
      case RoomType.elite:
        return numberGolem();
      case RoomType.boss:
        return sudokuDragon();
      case RoomType.shop: // 상점 등 전투가 없는 방
        return Monster.empty();
      default:
        return numberSlime(); // 기본 몬스터
    }
  }
}