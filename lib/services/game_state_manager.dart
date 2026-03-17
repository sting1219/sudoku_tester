import 'package:flutter/material.dart';
import '../models/combat_data.dart';
import '../models/dungeon.dart';
import '../models/user_data.dart';
import '../models/dungeon_theme.dart';
import 'currency_service.dart';

class GameStateManager extends ChangeNotifier {
  static final GameStateManager _instance = GameStateManager._internal();
  factory GameStateManager() => _instance;
  GameStateManager._internal();

  DungeonMap? _dungeonMap;
  Monster? _currentMonster;
  PlayerCombatStats? _playerCombatStats;
  final List<String> _combatLogMessages = [];
  int _comboCount = 0;
  int _secondsElapsed = 0;
  bool _isInitialized = false;

  DungeonMap? get dungeonMap => _dungeonMap;
  Monster? get currentMonster => _currentMonster;
  PlayerCombatStats? get playerCombatStats => _playerCombatStats;
  List<String> get combatLogMessages => List.unmodifiable(_combatLogMessages);
  int get comboCount => _comboCount;
  int get secondsElapsed => _secondsElapsed;
  bool get isInitialized => _isInitialized;

  void initializeGame(UserData userData, {int? seed, DungeonTheme? theme}) {
    // 테마가 없으면 기본값(숲) 사용
    final targetTheme = theme ?? DungeonTheme.allThemes.first;
    _dungeonMap = DungeonMap(theme: targetTheme, seed: seed);

    // 테마별 몬스터 생성 로직 적용
    var initialMonster = MonsterTemplates.getMonsterForTheme(
      _dungeonMap!.currentRoom.type,
      targetTheme.name,
      userData.level,
    );
    if (initialMonster.name == "없음" || initialMonster.maxHp <= 0) {
      initialMonster = MonsterTemplates.numberSlime();
    }
    _currentMonster = initialMonster;
    _playerCombatStats = PlayerCombatStats(
      maxHp: (userData.baseMaxHp * CurrencyService().collectionHpBonus).toInt(),
      attackPower:
          (userData.baseAttackPower * CurrencyService().collectionAtkBonus)
              .toInt(),
    );
    _combatLogMessages.clear();
    _comboCount = 0;
    _secondsElapsed = 0;
    _isInitialized = true;
    notifyListeners();
  }

  void updateSeconds() {
    _secondsElapsed++;
    notifyListeners();
  }

  void addCombatLog(String message) {
    if (_combatLogMessages.length >= 10) {
      _combatLogMessages.removeAt(0);
    }
    _combatLogMessages.add(message);
    notifyListeners();
  }

  void updateMonster(Monster monster) {
    _currentMonster = monster;
    notifyListeners();
  }

  void updatePlayerStats(PlayerCombatStats stats) {
    _playerCombatStats = stats;
    notifyListeners();
  }

  void updateCombo(int count) {
    _comboCount = count;
    notifyListeners();
  }

  void setDungeonMap(DungeonMap map) {
    _dungeonMap = map;
    notifyListeners();
  }

  void clearCombatLogs() {
    _combatLogMessages.clear();
    notifyListeners();
  }
}
