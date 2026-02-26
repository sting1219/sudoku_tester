import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/sudoku_board.dart';
import '../models/user_data.dart';
import '../models/combat_data.dart';
import '../models/dungeon.dart';
import '../models/sound_manager.dart';
import '../data/lore_data.dart';

import '../widgets/minimap.dart';
import '../widgets/number_keypad.dart';
import '../widgets/game_status.dart';
import '../widgets/action_buttons.dart';
import '../widgets/ad_element.dart';
import '../widgets/monster_status.dart';
import '../widgets/combat_log.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/projectile_animation.dart';
import '../widgets/floating_damage.dart';
import '../widgets/particle_overlay.dart';
import '../widgets/purification_gauge.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/dungeon_clear_overlay.dart';

import '../controllers/game_controller.dart';
import '../utils/app_styles.dart';

// GameState class to hold a snapshot of the entire game state for the undo feature.
class GameState {
  final DungeonMap dungeonMap; // SudokuBoard 대신 DungeonMap 저장
  final Monster currentMonster;
  final PlayerCombatStats playerCombatStats;
  final List<String> combatLogMessages;
  final int comboCount;
  final DateTime? lastCorrectEntryTime;
  final int hintsRemaining;
  final int undoUses;

  GameState({
    required this.dungeonMap,
    required this.currentMonster,
    required this.playerCombatStats,
    required this.combatLogMessages,
    required this.comboCount,
    this.lastCorrectEntryTime,
    required this.hintsRemaining,
    required this.undoUses,
  });
}

class SudokuScreen extends StatefulWidget {
  final bool isGameStarted;
  const SudokuScreen({super.key, this.isGameStarted = true});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen>
    with SingleTickerProviderStateMixin {
  late DungeonMap _dungeonMap; // DungeonMap 인스턴스
  UserData _userData = UserData.initial();
  Monster _currentMonster = MonsterTemplates.numberSlime();
  PlayerCombatStats _playerCombatStats = PlayerCombatStats();
  int? _selectedRow;
  int? _selectedCol;

  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isMemoMode = false;
  int _hintsRemaining = 0;
  final int _maxUndoUses = 3;
  int _undoUses = 0;
  bool _isPaused = false;
  bool _isSuccessAnimation = false;
  bool _isDungeonCleared = false; // 던전 전체 정화 상태 추가
  bool _showMoveButtons = false; // 방 클리어 후 이동 버튼 표시 여부

  final List<String> _combatLogMessages = [];
  final List<GameState> _history = [];
  int _comboCount = 0;
  DateTime? _lastCorrectEntryTime;

  late AnimationController _screenShakeController;
  late Animation<Offset> _screenShakeAnimation;

  // 연출용 상태 추가
  int? _flashingRow;
  int? _flashingCol;
  List<Map<String, int>> _currentConflicts = [];
  int? _errorRow;
  int? _errorCol;
  double _conflictAnimationValue = 0.0;
  String? _errorExplanation;
  Timer? _errorResetTimer;
  final List<Widget> _projectiles = [];
  final List<Widget> _damageEffects = []; // 플로팅 데미지 효과 관리 리스트
  final GlobalKey _monsterKey = GlobalKey();
  final GlobalKey _gridKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _dungeonMap = DungeonMap(); // 던전 맵 초기화
    _currentMonster = MonsterTemplates.getMonsterForRoom(
      _dungeonMap.currentRoom.type,
    ); // 초기 몬스터 설정
    _loadUserData();
    _createNewGame(); // 난이도 선택 기획 변경: 좌표 기반 자동 생성

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
          )
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _screenShakeController.reverse();
            }
          });

    if (widget.isGameStarted) {
      _startTimer();
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

  Future<void> _loadUserData() async {
    final UserData loadedData = await LocalStorageService.loadUserData();
    setState(() {
      _userData = loadedData;
    });
  }

  Future<void> _saveUserData() async {
    await LocalStorageService.saveUserData(_userData);
  }

  void _addCombatLog(String message) {
    setState(() {
      if (_combatLogMessages.length >= 10) {
        _combatLogMessages.removeAt(0);
      }
      _combatLogMessages.add(message);
    });
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
      _dungeonMap = DungeonMap(); // 새로운 던전 맵 생성
      _secondsElapsed = 0;
      _isPaused = false;
      _selectedRow = null;
      _selectedCol = null;
      _hintsRemaining = 0;
      _undoUses = 0;
      _isSuccessAnimation = false;
      _showMoveButtons = false;
      _currentMonster = MonsterTemplates.getMonsterForRoom(
        _dungeonMap.currentRoom.type,
      );
      _playerCombatStats = PlayerCombatStats();
      _comboCount = 0;
      _lastCorrectEntryTime = null;
      _history.clear();
      _combatLogMessages.clear();
    });
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _secondsElapsed++;
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
    _screenShakeController.dispose();
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

  void _handleUndo() {
    if (_history.isEmpty) {
      _addCombatLog("더 이상 실행 취소할 수 없습니다.");
      return;
    }
    if (_undoUses >= _maxUndoUses) {
      _addCombatLog("실행 취소 횟수를 모두 사용했습니다.");
      return;
    }

    setState(() {
      final lastState = _history.removeLast();
      _dungeonMap = lastState.dungeonMap;
      _currentMonster = lastState.currentMonster;
      _playerCombatStats = lastState.playerCombatStats;
      _combatLogMessages.clear();
      _combatLogMessages.addAll(lastState.combatLogMessages);
      _combatLogMessages.add("실행 취소됨.");

      _comboCount = lastState.comboCount;
      _lastCorrectEntryTime = lastState.lastCorrectEntryTime;
      _hintsRemaining = lastState.hintsRemaining;
      _undoUses = lastState.undoUses;
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
      _handleUndo();
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

    _history.add(
      GameState(
        dungeonMap: _dungeonMap.clone(),
        currentMonster: _currentMonster,
        playerCombatStats: _playerCombatStats,
        combatLogMessages: List<String>.from(_combatLogMessages),
        comboCount: _comboCount,
        lastCorrectEntryTime: _lastCorrectEntryTime,
        hintsRemaining: _hintsRemaining,
        undoUses: _undoUses,
      ),
    );
    if (_history.length > 20) {
      _history.removeAt(0);
    }

    final int currentRow = _selectedRow!;
    final int currentCol = _selectedCol!;

    setState(() {
      final isCorrectInput =
          (number == 0) ||
          (number == _getCurrentSudokuBoard().solution[currentRow][currentCol]);

      final bool wasCritical = isCorrectInput && number != 0
          ? _isCellCompletionCritical(currentRow, currentCol, number)
          : false;

      _getCurrentSudokuBoard().setNumber(
        currentRow,
        currentCol,
        number,
        isMemoMode: _isMemoMode,
        autoEraserEnabled: _userData.settings.autoEraserEnabled,
      );

      if (_isMemoMode) {
        _comboCount = 0;
        _lastCorrectEntryTime = null;
        return;
      }

      if (isCorrectInput && number != 0) {
        int damageDealt = GameController.calculateDamage(
          number,
          _playerCombatStats,
          _getCurrentSudokuBoard().difficulty,
        );
        double damageValue = damageDealt.toDouble();
        String logMessage = "$number를 맞혔습니다!";

        if (_lastCorrectEntryTime != null &&
            DateTime.now().difference(_lastCorrectEntryTime!).inSeconds < 5) {
          _comboCount++;
          damageValue *= (1 + _comboCount * 0.1);
          logMessage += " 콤보! ${_comboCount}연타!";
        } else {
          _comboCount = 1;
        }
        _lastCorrectEntryTime = DateTime.now();

        if (wasCritical) {
          damageValue *= 2.0;
          logMessage += " 크리티컬!!";
        }

        damageDealt = damageValue.toInt();
        _addCombatLog("$logMessage $damageDealt의 데미지를 준비합니다!");

        _triggerCorrectAnswerEffects(currentRow, currentCol, damageDealt);
      } else if (!isCorrectInput) {
        _lastCorrectEntryTime = null;

        _triggerErrorEffects(currentRow, currentCol, number);

        final int damageTaken = _currentMonster.attackPower;
        _playerCombatStats = _playerCombatStats.copyWith(
          currentHp: (_playerCombatStats.currentHp - damageTaken).clamp(
            0,
            _playerCombatStats.maxHp,
          ),
        );
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
    });
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
                      _saveUserData();
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

  void _triggerCorrectAnswerEffects(int row, int col, int damageDealt) {
    HapticFeedback.lightImpact();
    SoundManager.instance.playComboSound(_comboCount);

    setState(() {
      _flashingRow = row;
      _flashingCol = col;
    });
    Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _flashingRow = null;
          _flashingCol = null;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createProjectile(row, col, damageDealt);
      _triggerParticleEffect(row, col);
    });
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

  void _createProjectile(int row, int col, int damageDealt) {
    final RenderBox? monsterBox =
        _monsterKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? gridBox =
        _gridKey.currentContext?.findRenderObject() as RenderBox?;

    if (monsterBox == null || gridBox == null || !mounted) return;

    final monsterPos = monsterBox.localToGlobal(
      Offset(monsterBox.size.width / 2, monsterBox.size.height / 2),
    );
    double cellSize = gridBox.size.width / 9;
    Offset startOffset = Offset((col + 0.5) * cellSize, (row + 0.5) * cellSize);
    final startPos = gridBox.localToGlobal(startOffset);

    final RenderBox screenBox = context.findRenderObject() as RenderBox;
    final relativeStart = screenBox.globalToLocal(startPos);
    final relativeEnd = screenBox.globalToLocal(monsterPos);

    late Widget projectile;
    projectile = ProjectileAnimation(
      key: UniqueKey(),
      startPos: relativeStart,
      endPos: relativeEnd,
      onHit: () {
        if (!mounted) return;
        setState(() {
          _projectiles.remove(projectile);

          _currentMonster = _currentMonster.copyWith(
            currentHp: (_currentMonster.currentHp - damageDealt).clamp(
              0,
              _currentMonster.maxHp,
            ),
          );
          _addCombatLog("${_currentMonster.name}에게 ${damageDealt}의 타격!");

          _createFloatingDamage(monsterPos, damageDealt);
          _screenShakeController.forward(from: 0.0);
          SoundManager.instance.playHitSound();

          if (_currentMonster.isDefeated()) {
            _addCombatLog("${_currentMonster.name}을(를) 처치했습니다!");
            _applyMonsterDefeatRewards();

            if (!_getCurrentSudokuBoard().isSolved()) {
              _loadNextMonster();
            }
          }

          if (!_isMemoMode && _getCurrentSudokuBoard().isSolved()) {
            _timer?.cancel();
            _triggerSuccessSequence();
          }
        });
      },
    );

    setState(() {
      _projectiles.add(projectile);
    });
  }

  void _createFloatingDamage(Offset globalPos, int damage) {
    final RenderBox screenBox = context.findRenderObject() as RenderBox;
    final relativePos = screenBox.globalToLocal(globalPos);

    late Widget effect;
    effect = FloatingDamage(
      key: UniqueKey(),
      position: relativePos,
      damage: damage,
      onComplete: () {
        if (mounted) {
          setState(() {
            _damageEffects.remove(effect);
          });
        }
      },
    );

    setState(() {
      _damageEffects.add(effect);
    });
  }

  void _applyMonsterDefeatRewards() async {
    _addCombatLog(
      "보상 획득: ${_currentMonster.rewardGold}G, ${_currentMonster.rewardXp}XP",
    );

    final int initialUserLevel = _userData.level;
    _userData.addGold(_currentMonster.rewardGold);
    _userData.addXp(_currentMonster.rewardXp);

    if (_userData.level > initialUserLevel) {
      final int levelsGained = _userData.level - initialUserLevel;
      final int bonusGoldFromLevelUp = levelsGained * 50;
      _userData.addGold(bonusGoldFromLevelUp);
      _addCombatLog(
        "🎉 레벨업! (Lv.$levelsGained UP!) 보너스 $bonusGoldFromLevelUp G 획득!",
      );
    }

    await _saveUserData();
  }

  void _loadNextMonster() {
    setState(() {
      _currentMonster = MonsterTemplates.getMonsterForRoom(
        _dungeonMap.currentRoom.type,
      );
      _addCombatLog("야생의 ${_currentMonster.name}이(가) 나타났다!");
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
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _createNewGame();
              },
              child: const Text("다시 도전"),
            ),
          ),
        ],
      ),
    );
  }

  void _triggerMonsterSpecialAbility() {
    _addCombatLog("${_currentMonster.name}이(가) 특수 능력을 사용했습니다!");
  }

  void _triggerSuccessSequence() async {
    if (!mounted) return;
    final BuildContext currentContext = context;

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
              artifactLore: LoreData.getLore(room.artifactNumber),
              artifactNumber: room.artifactNumber,
              type: room.type,
              clearedDate: dateStr,
              boardSnapshot: boardSnapshot,
            ),
          ],
        );

        if (_dungeonMap.purificationRate >= 1.0) {
          if (!_userData.stats.unlockedTitles.contains("던전의 축복")) {
            _userData.stats = _userData.stats.copyWith(
              unlockedTitles: [..._userData.stats.unlockedTitles, "던전의 축복"],
              activeTitle: "던전의 축복",
            );
            _addCombatLog("✨ 전설적인 업적 달성! '던전의 축복' 칭호를 획득했습니다! ✨");
          }
        }

        _saveUserData();

        if (room.type == RoomType.boss) {
          _isDungeonCleared = true;
          _addCombatLog("🎉 축하합니다! 던전의 핵심 근원인 보스를 처치하여 던전이 정화되었습니다!");
        }
      }
      _showMoveButtons = true;
    });
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!currentContext.mounted) return;

    if (_dungeonMap.currentRoom.isCleared) {
      final int initialUserLevel = _userData.level;
      final (int earnedGold, int earnedXp) = _calculateReward(
        difficulty: _getCurrentSudokuBoard().difficulty,
        timeElapsed: _secondsElapsed,
        mistakes: _getCurrentSudokuBoard().mistakes,
      );

      _userData.addGold(earnedGold);
      _userData.addXp(earnedXp);

      int bonusGoldFromLevelUp = 0;
      final bool leveledUp = _userData.level > initialUserLevel;
      if (leveledUp) {
        bonusGoldFromLevelUp = (_userData.level - initialUserLevel) * 50;
        _userData.addGold(bonusGoldFromLevelUp);
      }
      await _saveUserData();

      _addCombatLog("✨ 퍼즐 해결! 기록: ${_formatTime(_secondsElapsed)}");
      _addCombatLog("💰 획득 골드: $earnedGold G / 💎 획득 경험치: $earnedXp XP");

      if (leveledUp) {
        _addCombatLog(
          "🎊 레벨업! Lv.${_userData.level - initialUserLevel} 상승! 보너스: $bonusGoldFromLevelUp G",
        );
      }

      _addCombatLog("현재 상태: Lv.${_userData.level} / ${_userData.gold} G");

      setState(() => _isSuccessAnimation = false);
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
        _undoUses = 0;
        _history.clear();
        _combatLogMessages.clear();
        _currentMonster = MonsterTemplates.getMonsterForRoom(
          _dungeonMap.currentRoom.type,
        );
        _startTimer();

        if (_dungeonMap.currentRoom.type == RoomType.boss) {
          _addCombatLog("⚠️ 경고: 보스의 방에 진입했습니다! 강력한 기운이 느껴집니다!");
        }
      }
    });
  }

  Widget _buildMoveButton(
    String direction,
    IconData icon,
    int targetX,
    int targetY, {
    required bool canMove,
    required bool isBossDoor,
  }) {
    return InkWell(
      onTap: canMove ? () => _moveToRoom(targetX, targetY) : null,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: canMove
              ? (isBossDoor ? Colors.orangeAccent : Colors.blueAccent)
                    .withOpacity(0.8)
              : Colors.grey.withOpacity(0.3),
          shape: BoxShape.circle,
          boxShadow: canMove
              ? [
                  BoxShadow(
                    color: isBossDoor ? Colors.redAccent : Colors.blue,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
          border: isBossDoor
              ? Border.all(color: Colors.yellow, width: 2)
              : null,
        ),
        child: Icon(
          icon,
          size: 35,
          color: canMove ? Colors.white : Colors.white24,
        ),
      ),
    );
  }

  bool _isDirectionBoss(int tx, int ty) {
    if (tx < 0 || tx >= _dungeonMap.width || ty < 0 || ty >= _dungeonMap.height)
      return false;
    return _dungeonMap.grid[ty][tx].type == RoomType.boss;
  }

  Widget _buildMoveButtons() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: _buildMoveButton(
              "Up",
              Icons.keyboard_arrow_up,
              _dungeonMap.currentX,
              _dungeonMap.currentY - 1,
              isBossDoor: _isDirectionBoss(
                _dungeonMap.currentX,
                _dungeonMap.currentY - 1,
              ),
              canMove: _dungeonMap.canMoveTo(
                _dungeonMap.currentX,
                _dungeonMap.currentY - 1,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _buildMoveButton(
              "Down",
              Icons.keyboard_arrow_down,
              _dungeonMap.currentX,
              _dungeonMap.currentY + 1,
              isBossDoor: _isDirectionBoss(
                _dungeonMap.currentX,
                _dungeonMap.currentY + 1,
              ),
              canMove: _dungeonMap.canMoveTo(
                _dungeonMap.currentX,
                _dungeonMap.currentY + 1,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: _buildMoveButton(
              "Left",
              Icons.keyboard_arrow_left,
              _dungeonMap.currentX - 1,
              _dungeonMap.currentY,
              isBossDoor: _isDirectionBoss(
                _dungeonMap.currentX - 1,
                _dungeonMap.currentY,
              ),
              canMove: _dungeonMap.canMoveTo(
                _dungeonMap.currentX - 1,
                _dungeonMap.currentY,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: _buildMoveButton(
              "Right",
              Icons.keyboard_arrow_right,
              _dungeonMap.currentX + 1,
              _dungeonMap.currentY,
              isBossDoor: _isDirectionBoss(
                _dungeonMap.currentX + 1,
                _dungeonMap.currentY,
              ),
              canMove: _dungeonMap.canMoveTo(
                _dungeonMap.currentX + 1,
                _dungeonMap.currentY,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameScreen() {
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
      child: Column(
        children: [
          GameStatus(
            difficulty:
                "${_getCurrentSudokuBoard().difficulty.label} [${_getCurrentSudokuBoard().difficulty.rpgGrade}]",
            mistakes: _getCurrentSudokuBoard().mistakes,
            maxMistakes: _getCurrentSudokuBoard().maxMistakes,
            time: _formatTime(_secondsElapsed),
            onPauseTap: _togglePause,
            playerLevel: _userData.level,
            playerCurrentHp: _playerCombatStats.currentHp,
            playerMaxHp: _playerCombatStats.maxHp,
            playerCurrentXp: _userData.currentXp,
            playerTotalXpNeeded: _userData.totalXpNeeded,
            playerGold: _userData.gold,
            hintsRemaining: _hintsRemaining,
            undoCount: _undoUses,
            maxUndoCount: _maxUndoUses,
          ),
          PurificationGauge(progress: _dungeonMap.purificationRate),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                icon: const Icon(
                  Icons.settings,
                  size: 18,
                  color: Colors.white70,
                ),
                label: const Text(
                  "설정",
                  style: TextStyle(color: Colors.white70),
                ),
                onPressed: _showSettingsDialog,
              ),
              const SizedBox(width: 10),
            ],
          ),
          const Divider(),

          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.zero,
                child: _showMoveButtons
                    ? Stack(
                        children: [
                          SudokuGrid(
                            key: _gridKey,
                            board: _getCurrentSudokuBoard(),
                            onCellTap: _onCellTapped,
                            onCellLongPress: _handleCellLongPress,
                            selectedRow: _selectedRow,
                            selectedCol: _selectedCol,
                            errorMap: _getCurrentSudokuBoard().errorMap,
                            isSuccess: _isSuccessAnimation,
                            flashingRow: _flashingRow,
                            flashingCol: _flashingCol,
                            conflicts: _currentConflicts,
                            errorRow: _errorRow,
                            errorCol: _errorCol,
                            conflictAnimationValue: _conflictAnimationValue,
                          ),
                          if (_errorExplanation != null)
                            Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.dangerColor.withOpacity(
                                      0.9,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _errorExplanation!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (_dungeonMap.currentRoom.isCleared)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black54,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "이미 정복한 지역입니다!",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium!
                                          .copyWith(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildMoveButtons(),
                                  ],
                                ),
                              ),
                            )
                          else
                            Positioned.fill(
                              child: Container(
                                color: Colors.black54,
                                child: _buildMoveButtons(),
                              ),
                            ),
                        ],
                      )
                    : Stack(
                        children: [
                          SudokuGrid(
                            key: _gridKey,
                            board: _getCurrentSudokuBoard(),
                            onCellTap: _onCellTapped,
                            onCellLongPress: _handleCellLongPress,
                            selectedRow: _selectedRow,
                            selectedCol: _selectedCol,
                            errorMap: _getCurrentSudokuBoard().errorMap,
                            isSuccess: _isSuccessAnimation,
                            flashingRow: _flashingRow,
                            flashingCol: _flashingCol,
                            conflicts: _currentConflicts,
                            errorRow: _errorRow,
                            errorCol: _errorCol,
                            conflictAnimationValue: _conflictAnimationValue,
                          ),
                          if (_errorExplanation != null)
                            Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _errorExplanation!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),

          CombatLog(logMessages: _combatLogMessages),

          ActionButtons(
            onUndo: (_history.isEmpty || _undoUses >= _maxUndoUses)
                ? null
                : () {
                    _undoUses++;
                    _handleUndo();
                  },
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
                : () {
                    setState(() {
                      _history.add(
                        GameState(
                          dungeonMap: _dungeonMap.clone(),
                          currentMonster: _currentMonster,
                          playerCombatStats: _playerCombatStats,
                          combatLogMessages: List<String>.from(
                            _combatLogMessages,
                          ),
                          comboCount: _comboCount,
                          lastCorrectEntryTime: _lastCorrectEntryTime,
                          hintsRemaining: _hintsRemaining,
                          undoUses: _undoUses,
                        ),
                      );
                      if (_history.length > 20) {
                        _history.removeAt(0);
                      }
                      _getCurrentSudokuBoard().giveHint(
                        _selectedRow!,
                        _selectedCol!,
                      );
                      _hintsRemaining--;
                    });
                  },
            undoCount: _undoUses,
            maxUndoCount: _maxUndoUses,
          ),

          NumberKeypad(
            board: _getCurrentSudokuBoard(),
            onNumberTap: (_isPaused || isLocked)
                ? null
                : (n) => _handleNumberInput(n),
          ),
          const AdSenseWidget(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Stack(
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
                MonsterStatus(key: _monsterKey, monster: _currentMonster),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                "Map Pos: (${_dungeonMap.currentX}, ${_dungeonMap.currentY})",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                            Expanded(child: _buildGameScreen()),
                          ],
                        ),
                      ),
                      if (MediaQuery.of(context).size.width > 600)
                        MiniMap(dungeonMap: _dungeonMap),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isPaused) PauseOverlay(onTap: _togglePause),
          ..._projectiles,
          ..._damageEffects,
          if (_isDungeonCleared)
            DungeonClearOverlay(
              onLeave: () {
                setState(() => _isDungeonCleared = false);
                _createNewGame();
              },
            ),
        ],
      ),
    );
  }
}
