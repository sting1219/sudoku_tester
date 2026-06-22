import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/sudoku_board.dart';
import '../models/user_data.dart';
import '../models/combat_data.dart';
import '../models/dungeon.dart';
import '../models/dungeon_theme.dart';
import '../models/sound_manager.dart';
import '../services/achievement_service.dart';
import '../services/currency_service.dart';
import '../services/collection_service.dart';
import '../services/game_state_manager.dart';
import '../services/artifact_service.dart'; // 유물 서비스 추가

import '../widgets/minimap.dart';
import '../widgets/number_keypad.dart';
import '../widgets/game_status.dart';
import '../widgets/action_buttons.dart';
import '../widgets/monster_status.dart';
import '../widgets/combat_log.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/new_card_dialog.dart';
import '../widgets/particle_overlay.dart';
import '../widgets/damage_popup.dart';
import '../services/localization_service.dart';
import '../data/monster_data.dart';
import '../data/artifact_data.dart';
import '../services/stage_manager.dart';
import '../src/ui/screens/wiki_screen.dart';
import '../widgets/purification_gauge.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/dungeon_clear_overlay.dart';

import '../controllers/game_controller.dart';
import '../utils/app_styles.dart';
import '../models/skill_manager.dart';
import '../models/item_model.dart';
import 'inventory_screen.dart';
import '../widgets/victory_dialog.dart';

// GameState class is removed since undo feature is no longer supported.

class SudokuScreen extends StatefulWidget {
  final bool isGameStarted;
  final bool isDailyChallenge;
  const SudokuScreen({
    super.key,
    this.isGameStarted = true,
    this.isDailyChallenge = false,
  });

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final GameStateManager _gameState = GameStateManager();
  late DungeonMap _dungeonMap;
  UserData _userData = UserData.initial();
  Monster _currentMonster = MonsterTemplates.numberSlime();
  late PlayerCombatStats _playerCombatStats;
  int? _selectedRow;
  int? _selectedCol;

  Timer? _timer;
  int _secondsElapsed = 0;
  int _currentMistakes = 0; // 이번 판의 실수 횟수 추적
  bool _isMemoMode = false;
  int _hintsRemaining = 0;
  bool _isPaused = false;
  bool _isSuccessAnimation = false;
  bool _isDungeonCleared = false;
  bool _showMoveButtons = false;
  final bool _showPurifiedOverlay = false;
  bool _isInitialized = false;

  int? _dailySeed;
  double _comboMultiplier = 1.0;
  final List<SudokuEvent> _activeEvents = [];
  late AnimationController _comboAnimationController;
  late Animation<double> _comboScaleAnimation;

  final List<String> _combatLogMessages = [];
  int _comboCount = 0;
  DateTime? _lastCorrectEntryTime;

  late AnimationController _screenShakeController;
  late Animation<Offset> _screenShakeAnimation;

  // int? _flashingRow;
  // int? _flashingCol;
  List<Map<String, int>> _currentConflicts = [];
  int? _errorRow;
  int? _errorCol;
  String? _errorExplanation;
  double _conflictAnimationValue = 0.0;
  Timer? _errorResetTimer;
  Timer? _saveDebounceTimer;
  
  // 부분 리빌드를 위한 ValueNotifier 도입
  late ValueNotifier<Monster> _monsterNotifier;
  late ValueNotifier<PlayerCombatStats> _playerStatsNotifier;
  late ValueNotifier<int> _goldNotifier;
  late ValueNotifier<int> _xpNotifier;
  late ValueNotifier<SudokuBoard> _boardNotifier;
  late ValueNotifier<int> _comboNotifier;
  late ValueNotifier<double> _comboMultiplierNotifier;
  late ValueNotifier<List<String>> _combatLogNotifier;
  late ValueNotifier<Map<String, int>?> _flashingCellNotifier;

  // 보스 패턴 관련
  final Set<String> _foggyCells = {};
  Timer? _bossSkillTimer;
  int _currentWorldIndex = 0;

  final List<DamagePopupData> _damagePopups = [];

  final List<Widget> _projectiles = [];
  final List<Widget> _damageEffects = [];
  // final GlobalKey _monsterKey = GlobalKey();
  final GlobalKey _gridKey = GlobalKey();
  Key _gridUniqueKey = UniqueKey();


  @override
  void initState() {
    super.initState();
    if (!_gameState.isInitialized) {
      if (widget.isDailyChallenge) {
        _dailySeed = SudokuBoard.getDailySeed();
      }
      _gameState.initializeGame(_userData, seed: _dailySeed);
    }
    _syncWithGameState();

    setState(() {
      _userData = CurrencyService().userData;
      if (!_gameState.isInitialized) {
        _gameState.initializeGame(_userData, seed: _dailySeed);
      }
      _syncWithGameState();
      _isInitialized = true;
    });
    _createNewGame();

    _comboAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _comboScaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _comboAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _screenShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _screenShakeAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.02, 0)).animate(
          CurvedAnimation(
            parent: _screenShakeController,
            curve: Curves.elasticOut,
          ),
        );

    // ValueNotifier 초기화
    _monsterNotifier = ValueNotifier(_currentMonster);
    _playerStatsNotifier = ValueNotifier(_playerCombatStats);
    _goldNotifier = ValueNotifier(_userData.gold);
    _xpNotifier = ValueNotifier(_userData.currentXp);
    _boardNotifier = ValueNotifier(_getCurrentSudokuBoard());
    _comboNotifier = ValueNotifier(_comboCount);
    _comboMultiplierNotifier = ValueNotifier<double>(1.0);
    _combatLogNotifier = ValueNotifier<List<String>>([]);
    _flashingCellNotifier = ValueNotifier<Map<String, int>?>(null);

    if (widget.isGameStarted) {
      _startTimer();
    }
  }

  void _syncWithGameState() {
    if (_gameState.isInitialized) {
      _dungeonMap = _gameState.dungeonMap!;
      _currentMonster = _gameState.currentMonster!;
      _playerCombatStats = _gameState.playerCombatStats!;
      _combatLogMessages.clear();
      _combatLogMessages.addAll(_gameState.combatLogMessages);
      _secondsElapsed = _gameState.secondsElapsed;
      _comboCount = _gameState.comboCount;
      
      // Notifier 동기화 (초기화 이후 시점 대응)
      if (_isInitialized) {
        _monsterNotifier.value = _currentMonster;
        _playerStatsNotifier.value = _playerCombatStats;
        _goldNotifier.value = _userData.gold;
        _xpNotifier.value = _userData.currentXp;
      }
    }
  }

  @override
  void didUpdateWidget(SudokuScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 홈 화면에서 게임 시작 버튼을 눌렀을 때 타이머 시작
    if (widget.isGameStarted && !oldWidget.isGameStarted) {
      _startTimer();
    }
  }

  // 현재 방의 SudokuBoard를 가져오는 헬퍼 함수
  SudokuBoard _getCurrentSudokuBoard() => _dungeonMap.currentRoom.board;

  // 현재 방의 정화 진행도를 계산하는 게터
  double get _roomPurificationRate {
    final board = _getCurrentSudokuBoard();
    int initialCount = 0;
    int correctCount = 0;

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board.initialGrid[r][c] != 0) {
          initialCount++;
        } else if (board.currentGrid[r][c] == board.solution[r][c]) {
          correctCount++;
        }
      }
    }

    int remainingToFill = 81 - initialCount;
    if (remainingToFill == 0) return 1.0;
    return (correctCount / remainingToFill).clamp(0.0, 1.0);
  }

  // 전역 데이터 동기화 (CurrencyService를 통해 저장 및 모든 리스너 알림)
  Future<void> _saveGlobalData() async {
    _saveDebounceTimer?.cancel();
    _userData.stats = _userData.stats.copyWith(
      lastDungeonMap: _dungeonMap.toJson(),
    );
    await CurrencyService().saveCurrentData();
  }

  // 디바운싱된 저장 로직 (연속 입력 시 부하 감소)
  void _saveGlobalDataDebounced() {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _saveGlobalData();
    });
  }

  void _addCombatLog(String message) {
    if (_combatLogMessages.length >= 10) {
      _combatLogMessages.removeAt(0);
    }
    _combatLogMessages.add(message);
    _combatLogNotifier.value = List.from(_combatLogMessages);
  }

  // Debug cheat function: Fills one empty cell with the correct answer.
  void _fillOneEmptyCellWithAnswer() {
    if (_isPaused || _isSuccessAnimation) return;

    // Find the first empty cell
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (_getCurrentSudokuBoard().currentGrid[r][c] == 0) {
          setState(() {
            _selectedRow = r;
            _selectedCol = c;
          });
          _handleNumberInput(_getCurrentSudokuBoard().solution[r][c]);
          return; // Fill one cell and exit
        }
      }
    }
    _addCombatLog("더 이상 채울 빈 칸이 없습니다!");
  }

  (int, int) _calculateReward({
    required Difficulty difficulty,
    required int timeElapsed,
    required int mistakes,
  }) {
    final (goldReward, xpReward) = GameController.calculateReward(
      difficulty: difficulty,
      timeElapsed: timeElapsed,
      mistakes: mistakes,
    );

    // 통계 업데이트 (copyWith 사용)
    _userData.stats = _userData.stats.copyWith(
      totalGamesWon: _userData.stats.totalGamesWon + 1,
      noMissCount: (mistakes == 0)
          ? _userData.stats.noMissCount + 1
          : _userData.stats.noMissCount,
      totalCleared: _userData.stats.totalCleared + 1,
    );

    return (goldReward, xpReward);
  }

  void _createNewGame() {
    _timer?.cancel();
    setState(() {
      _currentMistakes = 0; // 실수 횟수 초기화
      // GameStateManager에 이미 초기화된 지도가 있다면 그것을 사용하고, 없다면 기본 테마로 생성
      if (_userData.stats.lastDungeonMap != null) {
        _dungeonMap = DungeonMap.fromJson(_userData.stats.lastDungeonMap!);
      } else {
        final currentTheme = _gameState.dungeonMap?.theme ?? DungeonTheme.allThemes.first;
        _dungeonMap = DungeonMap(theme: currentTheme, seed: _dailySeed);
      }

      _secondsElapsed = 0;
      _isPaused = false;
      _selectedRow = null;
      _selectedCol = null;
      _hintsRemaining = 0;
      _isSuccessAnimation = false;
      _showMoveButtons = false;

      // 테마 기반 몬스터 생성
      _currentMonster = MonsterTemplates.getMonsterForTheme(
        _dungeonMap.currentRoom.type,
        _dungeonMap.theme.name,
        _userData.level,
      );

      _playerCombatStats = PlayerCombatStats(
        maxHp: (_userData.baseMaxHp * CurrencyService().collectionHpBonus)
            .toInt(),
        attackPower:
            (_userData.baseAttackPower * CurrencyService().collectionAtkBonus)
                .toInt(),
      );
      _comboCount = 0;
      _lastCorrectEntryTime = null;
      _combatLogMessages.clear();

      // 몬스터 도감 등록
      if (_currentMonster.name != "없음") {
        _userData.stats.discoveredMonsterNames.add(_currentMonster.name);
      }

      // 신규 게임 시 위젯 강제 리빌드를 위한 키 갱신
      _gridUniqueKey = UniqueKey();

      // 매니저 상태와 동기화
      _gameState.setDungeonMap(_dungeonMap);
      _gameState.updateMonster(_currentMonster);
      _gameState.updatePlayerStats(_playerCombatStats);
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        _gameState.updateSeconds(); // 매니저 데이터 업데이트
        setState(() {
          _secondsElapsed = _gameState.secondsElapsed;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _saveDebounceTimer?.cancel();
    _screenShakeController.dispose();
    _monsterNotifier.dispose();
    _playerStatsNotifier.dispose();
    _goldNotifier.dispose();
    _xpNotifier.dispose();
    _boardNotifier.dispose();
    _comboMultiplierNotifier.dispose();
    _combatLogNotifier.dispose();
    _flashingCellNotifier.dispose();
    super.dispose();
  }

  void _onCellTapped(int row, int col) {
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
      _isMemoMode = false;
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  bool _isCellCompletionCritical(int row, int col, int number) {
    return GameController.isCellCompletionCritical(
      _getCurrentSudokuBoard(),
      row,
      col,
      number,
    );
  }

  void _handleNumberInput(int number) {
    if (_selectedRow == null ||
        _selectedCol == null ||
        _isPaused ||
        _isSuccessAnimation)
      return;

    if (_isCellLocked() && number == 0) {
      return;
    }

    if (_isCellLocked()) {
      _addCombatLog("잠긴 칸에는 숫자를 입력할 수 없습니다.");
      return;
    }

    if (!_isMemoMode &&
        number != 0 &&
        _getCurrentSudokuBoard().getCountOfNumber(number) >= 9) {
      _addCombatLog("$number는 이미 9개 모두 채워졌습니다.");
      return;
    }

    final int currentRow = _selectedRow!;
    final int currentCol = _selectedCol!;

    final isCorrectInput = (number == 0) ||
        (number == _getCurrentSudokuBoard().solution[currentRow][currentCol]);

    final bool wasCritical = isCorrectInput && number != 0
        ? _isCellCompletionCritical(currentRow, currentCol, number)
        : false;

    // 보드 업데이트 (리빌드 최소화)
    _getCurrentSudokuBoard().setNumber(
      currentRow,
      currentCol,
      number,
      isMemoMode: _isMemoMode,
      autoEraserEnabled: _userData.settings.autoEraserEnabled,
    );
    _boardNotifier.value = _getCurrentSudokuBoard(); // 그리드 부분 리빌드 유도

    if (_isMemoMode) {
      HapticFeedback.selectionClick();
      _comboCount = 0;
      _comboNotifier.value = 0;
      _lastCorrectEntryTime = null;
      return;
    }

    if (isCorrectInput && number != 0) {
      // 유물 보너스 계산
      final artifactBonuses = ArtifactService().calculateTotalBonuses(_userData);
      final double atkMult = artifactBonuses['atkMultiplier'] ?? 1.0;
      final int hpRegenBonus = artifactBonuses['hpRegen']?.toInt() ?? 0;

      int unlockedCount = CollectionService().totalUnlockedCount;
      int baseDamageDealt = GameController.calculateDamage(
        number,
        _playerCombatStats,
        _getCurrentSudokuBoard().difficulty,
        unlockedCount,
      );
      
      // 유물 공격력 배수 적용
      int damageDealt = (baseDamageDealt * atkMult).toInt();
      double damageValue = damageDealt.toDouble();
      String logMessage = "$number를 맞혔습니다!";

      // 정답 시 HP 회복 (기본 + 유물 보너스)
      if (hpRegenBonus > 0) {
        _playerStatsNotifier.value = _playerStatsNotifier.value.heal(hpRegenBonus);
        _addCombatLog("✨ 유물 효과로 HP $hpRegenBonus 회복!");
      }

      if (_lastCorrectEntryTime != null &&
          DateTime.now().difference(_lastCorrectEntryTime!).inSeconds < 5) {
        _comboCount++;
        _comboMultiplier = (1.0 + _comboCount * 0.1).clamp(1.0, 3.0);
        damageValue *= _comboMultiplier;
        logMessage +=
            " ${_comboCount} 콤보! (x${_comboMultiplier.toStringAsFixed(1)})";
        _comboAnimationController.forward(from: 0.0);
      } else {
        _comboCount = 1;
        _comboMultiplier = 1.0;
      }
      _lastCorrectEntryTime = DateTime.now();

      // 정답을 맞혔으므로 안개가 있었다면 제거
      if (_foggyCells.contains("$currentRow,$currentCol")) {
        setState(() {
          _foggyCells.remove("$currentRow,$currentCol");
          _addCombatLog("✨ 안개가 걷혔습니다!");
        });
      }

      // 콤보 리스너 업데이트
      _comboNotifier.value = _comboCount;
      _comboMultiplierNotifier.value = _comboMultiplier;

      if (Random().nextDouble() < 0.1) {
        _triggerRandomEvent();
      }

      if (_hasActiveEvent(EventType.blessing)) {
        damageValue *= 2.0;
        _addCombatLog("축복의 힘으로 데미지가 증폭됩니다!");
      }

      if (wasCritical) {
        damageValue *= 2.0;
        logMessage += " 크리티컬!!";
      }

      damageDealt = damageValue.toInt();

      // 스킬 매니저를 통한 추가 데미지 계산 및 적용
      int bonusDamage = SkillManager.calculateBonusDamage(
        _userData,
        SkillContext(
          inputNumber: number,
          currentMonster: _currentMonster,
          playerStats: _playerCombatStats,
          comboCount: _comboCount,
        ),
      );
      damageDealt += bonusDamage;
      if (bonusDamage > 0) {
        _addCombatLog("패시브 스킬 발동! ${bonusDamage}의 추가 데미지!");
      }

      _addCombatLog("$logMessage $damageDealt의 데미지를 준비합니다!");

      _triggerCorrectAnswerEffects(currentRow, currentCol, damageDealt, number);
    } else if (!isCorrectInput) {
      _lastCorrectEntryTime = null;
    } else if (number != 0) {
      _comboCount = 0;
      _comboMultiplier = 1.0;
      _comboNotifier.value = 0;
      _comboMultiplierNotifier.value = 1.0;
      _currentMistakes++;
      _triggerErrorEffects(currentRow, currentCol, number);
      _addCombatLog("오답입니다! 실수 횟수: $_currentMistakes");

      int unlockedCount = CollectionService().totalUnlockedCount;
      final int damageTaken = GameController.calculatePenalty(
        _currentMonster.attackPower,
        unlockedCount,
      );
      setState(() {
        _playerCombatStats = _playerCombatStats.copyWith(
          currentHp: (_playerCombatStats.currentHp - damageTaken).clamp(
            0,
            _playerCombatStats.maxHp,
          ),
        );
      });
      _playerStatsNotifier.value = _playerCombatStats;
      _addCombatLog(
        "오답! ${_currentMonster.name}의 반격! $damageTaken 데미지를 받았습니다!",
      );
      _screenShakeController.forward(from: 0.0);

      if (_playerCombatStats.isDefeated()) {
        _addCombatLog("플레이어가 쓰러졌습니다...");
        _handlePlayerDefeat();
      } else {
        _addCombatLog(
          "${_currentMonster.name}이(가) ${currentCol + 1}열을 진흙으로 가렸습니다!",
        );
        _triggerMonsterSpecialAbility();
      }
    } else {
      _comboCount = 0;
      _lastCorrectEntryTime = null;
      _addCombatLog("숫자를 지웠습니다.");
    }

    // 콤보 및 상태 동기화
    _gameState.updateCombo(_comboCount);
    _gameState.updatePlayerStats(_playerCombatStats);
    _gameState.updateMonster(_currentMonster);

    // 숫자를 입력할 때마다 디바운싱된 저장 로직 실행
    _saveGlobalDataDebounced();
  }


  void _showLevelUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          "LEVEL UP!",
          style: GoogleFonts.cinzel(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "레벨 ${_userData.level} -> ${_userData.level + 1}",
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              "보너스 스탯을 선택하세요:",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatSelectButton("공격력 +10", Icons.bolt, () {
                  _userData.baseAttackPower += 10;
                  _finishLevelUp();
                }),
                _buildStatSelectButton("최대 HP +20", Icons.favorite, () {
                  _userData.baseMaxHp += 20;
                  _finishLevelUp();
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSelectButton(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.indigoAccent),
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void _finishLevelUp() {
    setState(() {
      _userData.consumeXpForLevelUp();
      _playerCombatStats = _playerCombatStats.copyWith(
        maxHp: _userData.baseMaxHp,
        attackPower: _userData.baseAttackPower,
      );
      _gameState.updatePlayerStats(_playerCombatStats);
    });
    _saveGlobalData();
    Navigator.pop(context);
    if (_userData.canLevelUp) {
      _showLevelUpDialog(); // 연속 레벨업 처리
    }
  }

  void _handleCellLongPress(int row, int col) {
    if (_isPaused || _isSuccessAnimation) return;
    if (_getCurrentSudokuBoard().initialGrid[row][col] != 0 ||
        _getCurrentSudokuBoard().currentGrid[row][col] != 0)
      return;

    setState(() {
      _getCurrentSudokuBoard().fillPossibleNotes(row, col);
    });
    HapticFeedback.mediumImpact();
    _addCombatLog("후보수를 자동으로 분석하여 메모했습니다.");
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.dialogBackground,
              title: const Text("게임 설정", style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text(
                      "메모 자동 삭제",
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      "정답 입력 시 주변 메모를 자동으로 제거합니다.",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    value: _userData.settings.autoEraserEnabled,
                    activeColor: AppColors.accentColor,
                    onChanged: (bool value) {
                      setState(() {
                        _userData.settings.autoEraserEnabled = value;
                      });
                      setDialogState(() {});
                      _saveGlobalData();
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "닫기",
                    style: TextStyle(color: AppColors.accentColor),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _triggerCorrectAnswerEffects(int row, int col, int damageDealt, int inputNumber) {
    HapticFeedback.lightImpact();
    SoundManager.instance.playComboSound(_comboCount);

    _flashingCellNotifier.value = {'row': row, 'col': col};
    Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _flashingCellNotifier.value = null;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyHitResult(row, col, damageDealt, inputNumber);
      _triggerParticleEffect(row, col);
      _addDamagePopup(row, col, damageDealt);
    });
  }

  void _applyHitResult(int row, int col, int damageDealt, int inputNumber) async {
    if (!mounted) return;
    
    // 1. 즉각적인 UI 피드백 (Lightweight)
    final newMonster = _currentMonster.copyWith(
      currentHp: (_currentMonster.currentHp - damageDealt).clamp(
        0,
        _currentMonster.maxHp,
      ),
    );
    _currentMonster = newMonster;
    _monsterNotifier.value = newMonster;
    
    _addCombatLog("${newMonster.name}에게 $damageDealt의 타격!");
    _screenShakeController.forward(from: 0.0);

    // 2. 무거운 연산 (저장, 업적, 도감 등)은 Microtask와 Delay로 분산
    Future.microtask(() {
      if (!mounted) return;
      SoundManager.instance.playHitSound();
    });

    Future.delayed(const Duration(milliseconds: 200), () async {
      if (!mounted) return;

      // 도감 및 업적 체크 (비동기 처리 유도)
      _recordProgress(inputNumber);

      // 몬스터 처치 시 연출을 위한 추가 지연 (약 600ms, FadeOut 대기)
      if (_currentMonster.currentHp <= 0) {
        await Future.delayed(const Duration(milliseconds: 600));
      }

      if (_currentMonster.isDefeated()) {
        _addCombatLog("${_currentMonster.name}을(를) 처치했습니다!");
        _applyMonsterDefeatRewards(); // 내부에서 _saveGlobalData 호출 (처치는 즉시 저장 권장)

        if (!_getCurrentSudokuBoard().isSolved()) {
          _loadNextMonster();
        }
      } else {
        // 일반적인 정답 입력 시에는 디바운싱 저장
        _saveGlobalDataDebounced();
      }

      if (!_isMemoMode && _getCurrentSudokuBoard().isSolved()) {
        _timer?.cancel();
        _triggerSuccessSequence();
      }

      _goldNotifier.value = _userData.gold;
      _xpNotifier.value = _userData.currentXp;

      if (_userData.canLevelUp) {
        _showLevelUpDialog();
      }
    });
  }

  // 무거운 데이터 기록 로직 분리
  void _recordProgress(int inputNumber) {
    CollectionService().recordNumberUsage(
      inputNumber,
      onUnlock: (msg) {
        _addCombatLog(msg);
        _showCollectionDialog("문헌 해금", msg);
      },
    );
    AchievementService().checkComboAchievement(_userData, _comboCount);
  }

  void _triggerErrorEffects(int row, int col, int number) {
    HapticFeedback.heavyImpact();
    SoundManager.instance.playWrongSound();
    _errorResetTimer?.cancel();

    setState(() {
      _errorRow = row;
      _errorCol = col;
      _currentConflicts = _getCurrentSudokuBoard().getConflicts(
        row,
        col,
        number,
      );
      _conflictAnimationValue = 1.0;

      String? message;
      bool rowConflict = _currentConflicts.any(
        (c) => c['row'] == row && c['col'] != col,
      );
      bool colConflict = _currentConflicts.any(
        (c) => c['col'] == col && c['row'] != row,
      );
      bool boxConflict = _currentConflicts.any(
        (c) =>
            (c['row']! ~/ 3 == row ~/ 3) &&
            (c['col']! ~/ 3 == col ~/ 3) &&
            (c['row'] != row || c['col'] != col),
      );

      if (rowConflict)
        message = "가로줄에 이미 $number가 존재합니다.";
      else if (colConflict)
        message = "세로줄에 이미 $number가 존재합니다.";
      else if (boxConflict)
        message = "3x3 구역 내에 이미 $number가 존재합니다.";
      else
        message = "잘못된 숫자입니다!";

      _errorExplanation = message;
    });

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted || _conflictAnimationValue <= 0) {
        timer.cancel();
        return;
      }
      setState(() {
        _conflictAnimationValue -= 0.05;
        if (_conflictAnimationValue < 0) _conflictAnimationValue = 0;
      });
    });

    _errorResetTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _errorRow = null;
          _errorCol = null;
          _currentConflicts = [];
          _errorExplanation = null;
        });
      }
    });

    _screenShakeController.forward(from: 0.0);
  }

  void _triggerParticleEffect(int row, int col) {
    final RenderBox? gridBox =
        _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (gridBox == null || !mounted) return;

    double cellSize = gridBox.size.width / 9;
    Offset localCenter = Offset((col + 0.5) * cellSize, (row + 0.5) * cellSize);
    final globalCenter = gridBox.localToGlobal(localCenter);

    ParticleOverlay.show(context, globalCenter);
  }

  void _addDamagePopup(int row, int col, int damage) {
    final RenderBox? gridBox =
        _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (gridBox == null || !mounted) return;

    double cellSize = gridBox.size.width / 9;
    // 격자의 좌상단 기준 로컬 좌표 계산
    Offset localCenter = Offset((col + 0.5) * cellSize, (row + 0.5) * cellSize);
    
    setState(() {
      _damagePopups.add(DamagePopupData(
        damage: damage,
        position: localCenter,
        combo: _comboCount,
        timestamp: DateTime.now(),
        key: UniqueKey(),
      ));
    });
  }



  void _applyMonsterDefeatRewards() async {
    _addCombatLog(
      "보상 획득: ${_currentMonster.rewardGold}G, ${_currentMonster.rewardXp}XP",
    );

    final int initialUserLevel = _userData.level;
    CurrencyService().addGold(_currentMonster.rewardGold);
    _userData.addXp(_currentMonster.rewardXp);

    // 방 클리어 횟수 증가 (스테이지 진행)
    _userData.stats = _userData.stats.copyWith(
      totalRoomsCleared: _userData.stats.totalRoomsCleared + 1,
    );

    if (_userData.level > initialUserLevel) {
      final int levelsGained = _userData.level - initialUserLevel;
      final int bonusGoldFromLevelUp = levelsGained * 50;
      CurrencyService().addGold(bonusGoldFromLevelUp);
      _addCombatLog(
        "🎉 레벨업! (Lv.$levelsGained UP!) 보너스 $bonusGoldFromLevelUp G 획득!",
      );
    }

    // 업적 체크 (대량 확장된 업적 시스템 연동)
    AchievementService().checkAchievements(_userData);
    AchievementService().checkGameEndAchievements(
      _userData,
      seconds: _secondsElapsed,
      mistakes: _currentMistakes,
      combo: _comboCount,
    );

    // 데일리 챌린지 성공 업적 (간단 구현)
    if (widget.isDailyChallenge) {
      AchievementService().checkDailyAchievement(_userData);
    }

    // 수집형 도감: 퍼즐 조각 5% 드롭 판정
    CollectionService().tryDropIllustrationPiece(
      onUnlock: (msg) {
        _addCombatLog(msg);
        _showCollectionDialog("차원의 낱장 획득", msg);
      },
    );

    // 몬스터 처치 기록 업데이트 (도감 해금 기본 조건)
    CollectionService().recordMonsterKill(_currentMonster.name);

    // 몬스터 카드 15% 드롭 판정
    CollectionService().tryDropMonsterCard(
      _currentMonster.name,
      onDrop: () {
        _addCombatLog("✨ 새로운 몬스터 카드 [${_currentMonster.name}] 획득!");
        final monsterEntry = MonsterData.monsters.firstWhere(
          (m) => m.name == _currentMonster.name,
          orElse: () => MonsterData.monsters.first,
        );
        NewCardDialog.show(context, monsterEntry);
      },
    );

    await _saveGlobalData();
  }

  void _loadNextMonster() {
    _bossSkillTimer?.cancel();
    _foggyCells.clear();

    setState(() {
      Monster nextMonster;
      // StageManager를 통해 현재 방 번호에 맞는 몬스터 결정
      if (StageManager().isBossStage) {
        nextMonster = MonsterTemplates.getMonsterForTheme(
          RoomType.boss,
          StageManager().currentWorldTheme.name,
          _userData.level,
        );
      } else {
        nextMonster = MonsterTemplates.getMonsterForTheme(
          RoomType.normal,
          StageManager().currentWorldTheme.name,
          _userData.level,
        );
      }

      if (nextMonster.name == "없음" || nextMonster.maxHp <= 0) {
        nextMonster = MonsterTemplates.numberSlime();
      }
      _currentMonster = nextMonster;
      _monsterNotifier.value = _currentMonster;
      _addCombatLog("야생의 ${_currentMonster.name}이(가) 나타났다!");

      if (_currentMonster.isBoss) {
        _startBossFogSkill();
      }

      _checkWorldChange();
    });
  }

  void _checkWorldChange() {
    int worldIdx = StageManager().currentWorldIndex;
    if (_currentWorldIndex != worldIdx) {
      _currentWorldIndex = worldIdx;
      _addCombatLog("✨ 새로운 지역 [${StageManager().worldName}]에 진입했습니다!");
      // BGM 교체 및 배경 이미지 변경 이벤트 처리 가능
      SoundManager.instance.playVictorySound(); // 임시 알림음
    }
  }

  void _startBossFogSkill() {
    _bossSkillTimer?.cancel();
    _bossSkillTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted || !_currentMonster.isBoss || _currentMonster.isDefeated()) {
        timer.cancel();
        return;
      }
      _applyBossFogSkill();
    });
  }

  void _applyBossFogSkill() {
    final board = _getCurrentSudokuBoard();
    List<String> emptyCells = [];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board.currentGrid[r][c] == 0 && !_foggyCells.contains("$r,$c")) {
          emptyCells.add("$r,$c");
        }
      }
    }

    if (emptyCells.isEmpty) return;

    // 보스 체력이 50% 이하일 때 안개 개수 증가
    int fogCount = (_currentMonster.currentHp < _currentMonster.maxHp * 0.5) ? 5 : 3;
    emptyCells.shuffle();
    
    setState(() {
      for (int i = 0; i < fogCount && i < emptyCells.length; i++) {
        _foggyCells.add(emptyCells[i]);
      }
      _addCombatLog("🌫️ 보스가 안개를 소환하여 시야를 방해합니다!");
    });
  }

  void _handlePlayerDefeat() async {
    _timer?.cancel();
    _screenShakeController.forward(from: 0.0);
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("💀 패배!", textAlign: TextAlign.center),
        content: const Text(
          "플레이어가 쓰러졌습니다. 다시 도전하시겠습니까?",
          textAlign: TextAlign.center,
        ),
        actions: [
          Column(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_fill),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(200, 45),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _showAdAndRevive();
                },
                label: Text(L10n.t('revive_ad')),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _createNewGame();
                },
                child: Text(
                  L10n.t('restart'),
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAdAndRevive() async {
    if (!mounted) return;

    // 광고 시청 연출 (로딩 다이얼로그)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.orangeAccent),
            const SizedBox(height: 20),
            Text(L10n.t('reviving'), style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );

    // 2초간 광고 시청 시뮬레이션
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pop(context); // 로딩 다이얼로그 닫기

    setState(() {
      // HP 100% 회복
      _playerCombatStats = _playerCombatStats.copyWith(
        currentHp: _playerCombatStats.maxHp,
      );
      _playerStatsNotifier.value = _playerCombatStats;
      
      // 타이머 재시작
      _startTimer();
      
      _addCombatLog("💖 ${L10n.t('hp_restored')}");
    });
  }

  void _showCollectionDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.amberAccent, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars, color: Colors.amberAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.cinzel(
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "닫기",
                      style: TextStyle(color: Colors.white24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent.withValues(
                        alpha: 0.2,
                      ),
                      foregroundColor: Colors.amberAccent,
                      side: const BorderSide(color: Colors.amberAccent),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // 팝업 닫기
                      // 도감 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WikiScreen(userData: _userData),
                        ),
                      );
                    },
                    child: const Text("도감에서 확인하기"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _triggerMonsterSpecialAbility() {
    _addCombatLog("${_currentMonster.name}이(가) 특수 능력을 사용했습니다!");
  }

  void _triggerSuccessSequence() async {
    if (!mounted) return;

    // 1초 지연 (사용자 요청)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isSuccessAnimation = true;
      _selectedRow = null;
      _selectedCol = null;
      
      if (!_dungeonMap.currentRoom.isCleared) {
        final room = _dungeonMap.currentRoom;
        room.isCleared = true;

        final boardSnapshot = <int>[];
        for (int r = 0; r < 9; r++) {
          for (int c = 0; c < 9; c++) {
            boardSnapshot.add(room.board.currentGrid[r][c]);
          }
        }

        final now = DateTime.now();
        final dateStr = "${now.year}-${now.month}-${now.day}";
        _userData.stats = _userData.stats.copyWith(
          archive: [
            ..._userData.stats.archive,
            ClearedRoom(
              artifactName: room.artifactName,
              artifactNumber: room.artifactNumber,
              type: room.type,
              clearedDate: dateStr,
              boardSnapshot: boardSnapshot,
            ),
          ],
        );
      }
    });

    final (int earnedGold, int earnedXp) = _calculateReward(
      difficulty: _getCurrentSudokuBoard().difficulty,
      timeElapsed: _secondsElapsed,
      mistakes: _getCurrentSudokuBoard().mistakes,
    );

    // 재화 추가 (VictoryDialog에서 최종 저장됨)
    CurrencyService().addGold(earnedGold);
    _userData.addXp(earnedXp);

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => VictoryDialog(
          earnedGold: earnedGold,
          earnedXp: earnedXp,
          onConfirm: () {
            Navigator.pop(context); // 다이얼로그 닫기
            Navigator.pop(context); // 게임 화면 닫고 로비로 이동
          },
        ),
      );
    }
  }

  bool _isCellLocked() {
    if (_selectedRow == null || _selectedCol == null) return true;
    int r = _selectedRow!;
    int c = _selectedCol!;

    bool isInitial = _getCurrentSudokuBoard().initialGrid[r][c] != 0;
    bool isCorrectlyFilled =
        _getCurrentSudokuBoard().currentGrid[r][c] != 0 &&
        !_getCurrentSudokuBoard().errorMap[r][c];

    return isInitial || isCorrectlyFilled;
  }

  void _moveToRoom(int newX, int newY) {
    setState(() {
      _dungeonMap.move(newX, newY);
      final RoomData targetRoom = _dungeonMap.currentRoom;

      if (targetRoom.isCleared) {
        _addCombatLog("이미 정복한 지역입니다.");
        _showMoveButtons = true;
        _currentMonster = Monster.empty();
        _timer?.cancel();
      } else {
        _secondsElapsed = 0;
        _isPaused = false;
        _isSuccessAnimation = false;
        _showMoveButtons = false;
        _selectedRow = null;
        _selectedCol = null;
        _hintsRemaining = 0;
        _combatLogMessages.clear();
        // 신규 방 진입 시 스도쿠 판 강제 초기화 및 생성
        targetRoom.board = SudokuBoard(difficulty: targetRoom.difficulty);
        _boardNotifier.value = targetRoom.board;

        var nextMonster = MonsterTemplates.getMonsterForTheme(
          targetRoom.type,
          _dungeonMap.theme.name,
          _userData.level,
        );
        _currentMonster = nextMonster;
        _monsterNotifier.value = nextMonster;

        _addCombatLog("Map (${_dungeonMap.currentX}, ${_dungeonMap.currentY}) - 새로운 정화 구역");

        // 신규 방 진입 시 위젯 강제 리빌드를 위한 키 갱신
        _gridUniqueKey = UniqueKey();


        // 몬스터 도감 발견 기록
        if (_currentMonster.name != "없음") {
          _userData.stats.discoveredMonsterNames.add(_currentMonster.name);
        }

        _startTimer();

        if (_dungeonMap.currentRoom.type == RoomType.boss) {
          _addCombatLog("⚠️ 경고: 보스의 방에 진입했습니다! 강력한 기운이 느껴집니다!");
        }
        
        // 이동 즉시 저장 (새로고침 대응)
        _saveGlobalData();
      }
    });
  }


  Widget _buildComboUI() {
    return ValueListenableBuilder<int>(
      valueListenable: _comboNotifier,
      builder: (context, comboCount, child) {
        if (comboCount < 1) return const SizedBox.shrink();

        return ValueListenableBuilder<double>(
          valueListenable: _comboMultiplierNotifier,
          builder: (context, multiplier, child) {
            return Positioned(
              top: 20,
              right: 20,
              child: AnimatedBuilder(
                animation: _comboScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _comboScaleAnimation.value,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "$comboCount COMBO!",
                          style: GoogleFonts.cinzel(
                            color: Colors.amber,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              const Shadow(
                                blurRadius: 10,
                                color: Colors.orange,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "Damage x${multiplier.toStringAsFixed(1)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventStatusBar() {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _activeEvents
            .map(
              (e) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: e.type == EventType.blessing
                      ? Colors.blueAccent.withValues(alpha: 0.5)
                      : Colors.redAccent.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    Icon(
                      e.type == EventType.blessing
                          ? Icons.auto_awesome
                          : Icons.warning_amber,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      e.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void _handleHint() {
    if (_isCellLocked() ||
        _hintsRemaining <= 0 ||
        _isPaused ||
        _selectedRow == null) {
      return;
    }
    setState(() {
      _getCurrentSudokuBoard().giveHint(_selectedRow!, _selectedCol!);
      _hintsRemaining--;
    });
  }

  Widget _buildTopControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<int>(
          valueListenable: _xpNotifier,
          builder: (context, xp, _) {
            return ValueListenableBuilder<int>(
              valueListenable: _goldNotifier,
              builder: (context, gold, _) {
                return ValueListenableBuilder<PlayerCombatStats>(
                  valueListenable: _playerStatsNotifier,
                  builder: (context, playerStats, _) {
                    return GameStatus(
                      difficulty:
                          "${_getCurrentSudokuBoard().difficulty.label} [${_getCurrentSudokuBoard().difficulty.rpgGrade}]",
                      mistakes: _getCurrentSudokuBoard().mistakes,
                      maxMistakes: _getCurrentSudokuBoard().maxMistakes,
                      time: _formatTime(_secondsElapsed),
                      onPauseTap: _togglePause,
                      playerLevel: _userData.level,
                      playerCurrentHp: playerStats.currentHp,
                      playerMaxHp: playerStats.maxHp,
                      playerCurrentXp: xp,
                      playerTotalXpNeeded: _userData.totalXpNeeded,
                      playerGold: gold,
                      hintsRemaining: _hintsRemaining,
                    );
                  },
                );
              },
            );
          },
        ),
        PurificationGauge(progress: _roomPurificationRate),
        _buildArtifactRow(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.settings, size: 18, color: Colors.white70),
              label: const Text("설정", style: TextStyle(color: Colors.white70)),
              onPressed: _showSettingsDialog,
            ),
            const SizedBox(width: 10),
          ],
        ),
        const Divider(),
      ],
    );
  }

  Widget _buildArtifactRow() {
    final unlockedArtifactIds = _userData.stats.unlockedArtifacts;
    final ownedArtifacts = CollectionTemplates.artifacts
        .where((a) => unlockedArtifactIds.contains(a.id))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.account_balance, color: Colors.amberAccent, size: 16),
          const SizedBox(width: 8),
          const Text(
            "보유 유물:",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ownedArtifacts.isEmpty
                ? const Text(
                    "장착된 유물 없음",
                    style: TextStyle(color: Colors.white24, fontSize: 12),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ownedArtifacts.map((artifact) {
                        return Tooltip(
                          message: "${artifact.name}\n${artifact.description}",
                          child: GestureDetector(
                            onTap: () {
                              _showCollectionDialog(
                                artifact.name,
                                artifact.description,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.amberAccent.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.amberAccent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Icon(
                                artifact.icon,
                                color: Colors.amberAccent,
                                size: 16,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSlots() {
    // 포션류 아이템만 퀵슬롯에 표시
    final potions = _userData.inventory
        .where((item) => item.type == ItemType.potion)
        .toList();

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black26,
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: Colors.amberAccent, size: 20),
          const SizedBox(width: 8),
          const Text(
            "QUICK",
            style: TextStyle(
              color: Colors.amberAccent,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: potions.isEmpty
                ? const Text(
                    "사용 가능한 포션이 없습니다.",
                    style: TextStyle(color: Colors.white24, fontSize: 12),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: potions.length,
                    itemBuilder: (context, index) {
                      final item = potions[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          right: 12.0,
                          top: 8.0,
                          bottom: 8.0,
                        ),
                        child: InkWell(
                          onTap: () => _usePotion(item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.indigoAccent.withOpacity(
                                  0.5,
                                ),
                              ),
                            ),
                            child: Center(
                              child: Row(
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "${item.count}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          IconButton(
            icon: const Icon(Icons.backpack, color: Colors.white70),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InventoryScreen(
                    userData: _userData,
                    onUpdate: () => setState(() {}),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _usePotion(Item item) {
    setState(() {
      if (item.id == 'hp_potion') {
        _playerCombatStats = _playerCombatStats.copyWith(
          currentHp: (_playerCombatStats.currentHp + item.value).clamp(
            0,
            _playerCombatStats.maxHp,
          ),
        );
        item.count--;
        _addCombatLog(
          "${item.name}을(를) 사용하여 HP ${_playerCombatStats.currentHp}가 되었습니다!",
        );
      }
      if (item.count <= 0) {
        _userData.inventory.remove(item);
      }
    });
    _saveGlobalData();
  }

  Widget _buildSudokuBoardWidget() {
    return Container(
      key: _gridUniqueKey, // 위젯 완벽 강제 초기화를 위해 상위 Container에 Key 부여
      padding: const EdgeInsets.all(8.0),
      child: ValueListenableBuilder<SudokuBoard>(
        valueListenable: _boardNotifier,
        builder: (context, board, child) {
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ValueListenableBuilder<Map<String, int>?>(
                    valueListenable: _flashingCellNotifier,
                    builder: (context, flashingCell, _) {
                      return SudokuGrid(
                        board: board,
                        onCellTap: _onCellTapped,
                        selectedRow: _selectedRow,
                        selectedCol: _selectedCol,
                        errorMap: board.errorMap,
                        flashingRow: flashingCell?['row'],
                        flashingCol: flashingCell?['col'],
                        onCellLongPress: _handleCellLongPress,
                        conflicts: _currentConflicts,
                        errorRow: _errorRow,
                        errorCol: _errorCol,
                        conflictAnimationValue: _conflictAnimationValue,
                        foggyCells: _foggyCells,
                      );
                    },
                  ),
                  // 데미지 팝업 렌더링
                  ..._damagePopups.map((data) => DamagePopup(
                        key: data.key,
                        data: data,
                        onComplete: () {
                          setState(() {
                            _damagePopups.remove(data);
                          });
                        },
                      )),
                  if (_roomPurificationRate >= 1.0)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.7),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.verified,
                                  color: Colors.cyanAccent.withValues(alpha: 0.8),
                                  size: 80,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  "이미 정복한 지역입니다!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 80),
                              ],
                            ),
                            _buildMoveButtons(),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResponsiveLayout() {
    bool isLocked = _isCellLocked();
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent && !_isPaused) {
          if (_showMoveButtons) {
            switch (event.logicalKey) {
              case LogicalKeyboardKey.arrowUp:
                _moveToRoom(_dungeonMap.currentX, _dungeonMap.currentY - 1);
                break;
              case LogicalKeyboardKey.arrowDown:
                _moveToRoom(_dungeonMap.currentX, _dungeonMap.currentY + 1);
                break;
              case LogicalKeyboardKey.arrowLeft:
                _moveToRoom(_dungeonMap.currentX - 1, _dungeonMap.currentY);
                break;
              case LogicalKeyboardKey.arrowRight:
                _moveToRoom(_dungeonMap.currentX + 1, _dungeonMap.currentY);
                break;
            }
          }
          final label = event.logicalKey.keyLabel;
          if (RegExp(r'^[1-9]$').hasMatch(label)) {
            _handleNumberInput(int.parse(label));
          } else if (label == 'f' || label == 'F') {
            _fillOneEmptyCellWithAnswer();
          } else if (event.logicalKey == LogicalKeyboardKey.backspace ||
              event.logicalKey == LogicalKeyboardKey.delete) {
            _handleNumberInput(0);
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 75,
                  child: Column(
                    children: [
                      ValueListenableBuilder<Monster>(
                        valueListenable: _monsterNotifier,
                        builder: (context, monster, _) {
                          return Column(
                            children: [
                              MonsterStatus(key: ObjectKey(monster), monster: monster),
                              ValueListenableBuilder<List<String>>(
                                valueListenable: _combatLogNotifier,
                                builder: (context, messages, _) {
                                  return CombatLog(logMessages: messages);
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(child: _buildSudokuBoardWidget()),
                    ],
                  ),
                ),
                Expanded(
                  flex: 25,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        children: [
                          _buildTopControls(),
                          ActionButtons(
                            onDelete: (isLocked || _isPaused)
                                ? null
                                : () => _handleNumberInput(0),
                            onMemoToggle: isLocked
                                ? null
                                : () => setState(
                                    () => _isMemoMode = !_isMemoMode,
                                  ),
                            isMemoOn: _isMemoMode,
                            hintCount: _hintsRemaining,
                            onHint:
                                (isLocked ||
                                    _hintsRemaining <= 0 ||
                                    _isPaused ||
                                    _selectedRow == null)
                                ? null
                                : _handleHint,
                          ),
                          NumberKeypad(
                            board: _getCurrentSudokuBoard(),
                            onNumberTap: (_isPaused || isLocked)
                                ? null
                                : (n) => _handleNumberInput(n),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Map Pos: (${_dungeonMap.currentX}, ${_dungeonMap.currentY})",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                          Transform.scale(
                            scale: 0.8,
                            child: _buildQuickSlots(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                _buildTopControls(),
                ValueListenableBuilder<Monster>(
                  valueListenable: _monsterNotifier,
                  builder: (context, monster, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MonsterStatus(key: ObjectKey(monster), monster: monster),
                        ValueListenableBuilder<List<String>>(
                          valueListenable: _combatLogNotifier,
                          builder: (context, messages, _) {
                            return CombatLog(logMessages: messages);
                          },
                        ),
                      ],
                    );
                  },
                ),
                Expanded(child: _buildSudokuBoardWidget()),
                ActionButtons(
                  onDelete: (isLocked || _isPaused)
                      ? null
                      : () => _handleNumberInput(0),
                  onMemoToggle: isLocked
                      ? null
                      : () => setState(() => _isMemoMode = !_isMemoMode),
                  isMemoOn: _isMemoMode,
                  hintCount: _hintsRemaining,
                  onHint:
                      (isLocked ||
                          _hintsRemaining <= 0 ||
                          _isPaused ||
                          _selectedRow == null)
                      ? null
                      : _handleHint,
                ),
                NumberKeypad(
                  board: _getCurrentSudokuBoard(),
                  onNumberTap: (_isPaused || isLocked)
                      ? null
                      : (n) => _handleNumberInput(n),
                ),
                if (constraints.maxHeight > 560) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text(
                      "Map Pos: (${_dungeonMap.currentX}, ${_dungeonMap.currentY})",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                  Transform.scale(scale: 0.75, child: _buildQuickSlots()),
                ],
              ],
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 필수 호출
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(color: Colors.indigoAccent),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _screenShakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: _screenShakeAnimation.value,
                child: child,
              );
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Battle Area",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigoAccent,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              _createNewGame();
                            },
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _dungeonMap.currentRoom.isCleared = true;
                                _showMoveButtons = true;
                                _addCombatLog("현재 방을 강제 클리어했습니다!");
                              });
                            },
                            child: const Text(
                              "Clear",
                              style: TextStyle(color: Colors.white30),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _buildResponsiveLayout()),
                      if (MediaQuery.of(context).size.width > 600)
                        MiniMap(dungeonMap: _dungeonMap),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isPaused) PauseOverlay(onTap: _togglePause),
          // 미사일 애니메이션 영역을 RepaintBoundary로 감싸서 다른 영역(스도쿠 판 등)의 재그리기를 방지
          RepaintBoundary(
            child: Stack(
              children: [
                ..._projectiles,
                ..._damageEffects,
              ],
            ),
          ),
          if (_isDungeonCleared)
            DungeonClearOverlay(
              onLeave: () {
                setState(() => _isDungeonCleared = false);
                _createNewGame();
              },
            ),

          if (_comboCount > 1) _buildComboUI(),
          if (_activeEvents.isNotEmpty) _buildEventStatusBar(),

          // "PURIFIED!" 오버레이 추가
          if (_showPurifiedOverlay)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.5 + (0.5 * value),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "PURIFIED!",
                                style: GoogleFonts.cinzel(
                                  color: Colors.cyanAccent,
                                  fontSize: 60,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 8,
                                  shadows: [
                                    const Shadow(
                                      color: Colors.cyan,
                                      blurRadius: 20,
                                    ),
                                    const Shadow(
                                      color: Colors.white,
                                      blurRadius: 40,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.cyanAccent.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "지역이 정화되었습니다",
                                  style: TextStyle(
                                    color: Colors.white,
                                    letterSpacing: 4,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _triggerRandomEvent() {
    final isBlessing = Random().nextBool();
    final event = isBlessing
        ? SudokuEvent(name: "정화의 축복", type: EventType.blessing, duration: 5)
        : SudokuEvent(name: "심연의 저주", type: EventType.curse, duration: 5);

    setState(() {
      _activeEvents.add(event);
    });
    _addCombatLog("${event.name}이(가) 발생했습니다!");

    Future.delayed(Duration(seconds: event.duration), () {
      if (mounted) {
        setState(() {
          _activeEvents.remove(event);
        });
        _addCombatLog("${event.name} 효과가 사라졌습니다.");
      }
    });
  }

  bool _hasActiveEvent(EventType type) =>
      _activeEvents.any((e) => e.type == type);

  Widget _buildMoveButtons() {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            // 위쪽 버튼
            Align(
              alignment: Alignment.topCenter,
              child: _buildMoveButton(
                icon: Icons.keyboard_arrow_up,
                label: "NORTH",
                dx: 0,
                dy: -1,
                isVisible: _dungeonMap.canMoveTo(
                  _dungeonMap.currentX,
                  _dungeonMap.currentY - 1,
                ),
              ),
            ),
            // 아래쪽 버튼
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildMoveButton(
                icon: Icons.keyboard_arrow_down,
                label: "SOUTH",
                dx: 0,
                dy: 1,
                isVisible: _dungeonMap.canMoveTo(
                  _dungeonMap.currentX,
                  _dungeonMap.currentY + 1,
                ),
              ),
            ),
            // 왼쪽 버튼
            Align(
              alignment: Alignment.centerLeft,
              child: _buildMoveButton(
                icon: Icons.keyboard_arrow_left,
                label: "WEST",
                dx: -1,
                dy: 0,
                isVisible: _dungeonMap.canMoveTo(
                  _dungeonMap.currentX - 1,
                  _dungeonMap.currentY,
                ),
              ),
            ),
            // 오른쪽 버튼
            Align(
              alignment: Alignment.centerRight,
              child: _buildMoveButton(
                icon: Icons.keyboard_arrow_right,
                label: "EAST",
                dx: 1,
                dy: 0,
                isVisible: _dungeonMap.canMoveTo(
                  _dungeonMap.currentX + 1,
                  _dungeonMap.currentY,
                ),
              ),
            ),
            // 중앙 안내
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.explore,
                    color: Colors.cyanAccent.withValues(alpha: 0.8),
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "CHOOSE\nDIRECTION",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoveButton({
    required IconData icon,
    required String label,
    required int dx,
    required int dy,
    required bool isVisible,
  }) {
    if (!isVisible) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _moveToRoom(
          _dungeonMap.currentX + dx,
          _dungeonMap.currentY + dy,
        ),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.cyanAccent.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.cyanAccent, size: 36),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum EventType { blessing, curse }

class SudokuEvent {
  final String name;
  final EventType type;
  final int duration;

  SudokuEvent({required this.name, required this.type, required this.duration});
}
