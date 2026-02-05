import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/sudoku_board.dart';
import 'models/user_data.dart';
import 'models/combat_data.dart';
import 'models/dungeon.dart'; // DungeonMap 임포트
import 'widgets/minimap.dart'; // MiniMap 위젯 임포트

import 'widgets/number_keypad.dart';
import 'widgets/game_status.dart';
import 'widgets/action_buttons.dart';
import 'widgets/ad_element.dart';
import 'widgets/monster_status.dart';
import 'widgets/combat_log.dart';
import 'widgets/sudoku_grid.dart';

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
    required this.dungeonMap, // DungeonMap으로 변경
    required this.currentMonster,
    required this.playerCombatStats,
    required this.combatLogMessages,
    required this.comboCount,
    required this.lastCorrectEntryTime,
    required this.hintsRemaining,
    required this.undoUses,
  });
}

void main() {
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SudokuScreen(),
    );
  }
}

class SudokuScreen extends StatefulWidget {
  const SudokuScreen({super.key});

  @override
  State<SudokuScreen> createState() => _SudokuScreenState();
}

class _SudokuScreenState extends State<SudokuScreen> with SingleTickerProviderStateMixin {
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
  bool _showMoveButtons = false; // 방 클리어 후 이동 버튼 표시 여부

  final List<String> _combatLogMessages = [];
  final List<GameState> _history = [];
  int _comboCount = 0;
  DateTime? _lastCorrectEntryTime;

  late AnimationController _screenShakeController;
  late Animation<Offset> _screenShakeAnimation;

  @override
  void initState() {
    super.initState();
    _dungeonMap = DungeonMap(); // 던전 맵 초기화
    _currentMonster = MonsterTemplates.getMonsterForRoom(_dungeonMap.currentRoom.type); // 초기 몬스터 설정
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDifficultySelector();
    });

    _screenShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _screenShakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.02, 0),
    ).animate(
      CurvedAnimation(
        parent: _screenShakeController,
        curve: Curves.elasticOut,
      ),)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _screenShakeController.reverse();
        }
      });
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
          // Found an empty cell, fill it with the correct answer.
          // We need to set _selectedRow and _selectedCol for _handleNumberInput to work.
          // _handleNumberInput will also save the state to history.
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

  static const Map<Difficulty, int> _baseGold = {
    Difficulty.easy: 10,
    Difficulty.medium: 30,
    Difficulty.hard: 100,
  };
  static const Map<Difficulty, int> _baseXp = {
    Difficulty.easy: 50,
    Difficulty.medium: 150,
    Difficulty.hard: 500,
  };

  static const Map<Difficulty, int> _targetTimes = {
    Difficulty.easy: 180,
    Difficulty.medium: 360,
    Difficulty.hard: 600,
  };

  static const Map<Difficulty, double> _difficultyDamageMultiplier = {
    Difficulty.easy: 1.5,
    Difficulty.medium: 1.0,
    Difficulty.hard: 0.8,
  };

  (int, int) _calculateReward({
    required Difficulty difficulty,
    required int timeElapsed,
    required int mistakes,
  }) {
    double gold = _baseGold[difficulty]!.toDouble();
    double xp = _baseXp[difficulty]!.toDouble();

    if (mistakes == 0) {
      gold *= 1.2;
      xp *= 1.2;
      _userData.stats.noMissCount++;
    }

    final targetTime = _targetTimes[difficulty];
    if (targetTime != null && timeElapsed <= targetTime) {
      gold *= 1.3;
      xp *= 1.3;
    }
    
    _userData.stats.totalCleared++;
    return (gold.toInt(), xp.toInt());
  }

  void _createNewGame([Difficulty? difficulty]) {
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
      _showMoveButtons = false; // 새 게임 시작 시 이동 버튼 숨김
      _currentMonster = MonsterTemplates.getMonsterForRoom(_dungeonMap.currentRoom.type); // 현재 방 타입에 맞는 몬스터 로드
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
      _dungeonMap = lastState.dungeonMap; // DungeonMap 복원
      _currentMonster = lastState.currentMonster;
      _playerCombatStats = lastState.playerCombatStats;
      _combatLogMessages.clear();
      _combatLogMessages.addAll(lastState.combatLogMessages);
      _combatLogMessages.add("실행 취소됨.");

      _comboCount = lastState.comboCount;
      _lastCorrectEntryTime = lastState.lastCorrectEntryTime;
      _hintsRemaining = lastState.hintsRemaining;
      _undoUses = lastState.undoUses; // 실행 취소 횟수 복원
    });
  }

  bool _isCellCompletionCritical(int row, int col, int number) {
    final tempBoard = _getCurrentSudokuBoard().clone();
    tempBoard.currentGrid[row][col] = number;

    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    bool boxComplete = true;
    for (int rLoop = startRow; rLoop < startRow + 3; rLoop++) {
      for (int cLoop = startCol; cLoop < startCol + 3; cLoop++) {
        if (tempBoard.currentGrid[rLoop][cLoop] == 0) {
          boxComplete = false;
          break;
        }
      }
      if (!boxComplete) break;
    }
    if (boxComplete) return true;

    bool rowComplete = true;
    for (int cLoop = 0; cLoop < 9; cLoop++) {
      if (tempBoard.currentGrid[row][cLoop] == 0) {
        rowComplete = false;
        break;
      }
    }
    if (rowComplete) return true;

    bool colComplete = true;
    for (int rLoop = 0; rLoop < 9; rLoop++) {
      if (tempBoard.currentGrid[rLoop][col] == 0) {
        colComplete = false;
        break;
      }
    }
    if (colComplete) return true;

    return false;
  }

  void _handleNumberInput(int number) {
    if (_selectedRow == null || _selectedCol == null || _isPaused || _isSuccessAnimation) return;

    if (_isCellLocked() && number == 0) {
      _handleUndo();
      return;
    }
    
    if (_isCellLocked()) {
       _addCombatLog("잠긴 칸에는 숫자를 입력할 수 없습니다.");
       return;
    }


    if (!_isMemoMode && number != 0 && _getCurrentSudokuBoard().getCountOfNumber(number) >= 9) {
      _addCombatLog("$number는 이미 9개 모두 채워졌습니다.");
      return;
    }

    _history.add(GameState(
      dungeonMap: _dungeonMap.clone(), // DungeonMap 저장
      currentMonster: _currentMonster,
      playerCombatStats: _playerCombatStats,
      combatLogMessages: List<String>.from(_combatLogMessages),
      comboCount: _comboCount,
      lastCorrectEntryTime: _lastCorrectEntryTime,
      hintsRemaining: _hintsRemaining,
      undoUses: _undoUses,
    ));
    if (_history.length > 20) { // Limit history size
      _history.removeAt(0);
    }

    final int currentRow = _selectedRow!;
    final int currentCol = _selectedCol!;
    
    setState(() {
      final isCorrectInput = (number == 0) || (number == _getCurrentSudokuBoard().solution[currentRow][currentCol]);
      
      final bool wasCritical = isCorrectInput && number != 0 ? _isCellCompletionCritical(currentRow, currentCol, number) : false;

      _getCurrentSudokuBoard().setNumber(currentRow, currentCol, number, isMemoMode: _isMemoMode);
      
      if (isCorrectInput && number != 0) {
        final double difficultyMultiplier = _difficultyDamageMultiplier[_getCurrentSudokuBoard().difficulty] ?? 1.0;
        double damage = number * _playerCombatStats.attackPower.toDouble() * difficultyMultiplier;
        String logMessage = "$number를 맞혔습니다!";

        if (_lastCorrectEntryTime != null && DateTime.now().difference(_lastCorrectEntryTime!).inSeconds < 3) {
          _comboCount++;
          damage *= (1 + _comboCount * 0.1);
          logMessage += " 콤보! ${_comboCount}연타!";
        } else {
          _comboCount = 1;
        }
        _lastCorrectEntryTime = DateTime.now();

        if (wasCritical) {
          damage *= 2.0;
          logMessage += " 크리티컬!!";
        }

        final int damageDealt = damage.toInt();
        _currentMonster = _currentMonster.copyWith(
          currentHp: (_currentMonster.currentHp - damageDealt).clamp(0, _currentMonster.maxHp),
        );
        logMessage += " ${_currentMonster.name}에게 $damageDealt의 데미지!";
        _addCombatLog(logMessage);

        bool monsterWasDefeated = _currentMonster.isDefeated();
        if (monsterWasDefeated) {
          _addCombatLog("${_currentMonster.name}을(를) 처치했습니다!");
          _applyMonsterDefeatRewards(); // Apply rewards, but don't load next monster yet.
        }

        if (!_isMemoMode && _getCurrentSudokuBoard().isSolved()) {
          _timer?.cancel();
          _triggerSuccessSequence();
        } else if (monsterWasDefeated) {
          _loadNextMonster();
        }

      } else if (!isCorrectInput) {
        _comboCount = 0;
        _lastCorrectEntryTime = null;

        final int damageTaken = _currentMonster.attackPower;
        _playerCombatStats = _playerCombatStats.copyWith(
          currentHp: (_playerCombatStats.currentHp - damageTaken).clamp(0, _playerCombatStats.maxHp),
        );
        _addCombatLog("오답! ${_currentMonster.name}의 반격! $damageTaken 데미지를 받았습니다!");
        _screenShakeController.forward(from: 0.0);

        if (_playerCombatStats.isDefeated()) {
          _addCombatLog("플레이어가 쓰러졌습니다...");
          _handlePlayerDefeat();
        } else {
          _addCombatLog("${_currentMonster.name}이(가) ${currentCol+1}열을 진흙으로 가렸습니다!");
          _triggerMonsterSpecialAbility();
        }
      } else {
        _comboCount = 0;
        _lastCorrectEntryTime = null;
        _addCombatLog("숫자를 지웠습니다.");
      }
    });
  }

  void _applyMonsterDefeatRewards() async {
    _addCombatLog("보상 획득: ${_currentMonster.rewardGold}G, ${_currentMonster.rewardXp}XP");

    final int initialUserLevel = _userData.level;
    _userData.addGold(_currentMonster.rewardGold);
    _userData.addXp(_currentMonster.rewardXp);

    if (_userData.level > initialUserLevel) {
      final int levelsGained = _userData.level - initialUserLevel;
      final int bonusGoldFromLevelUp = levelsGained * 50;
      _userData.addGold(bonusGoldFromLevelUp);
      _addCombatLog("🎉 레벨업! (Lv.$levelsGained UP!) 보너스 $bonusGoldFromLevelUp G 획득!");
    }

    await _saveUserData();
  }

  void _loadNextMonster() {
    setState(() {
      _currentMonster = MonsterTemplates.getMonsterForRoom(_dungeonMap.currentRoom.type); // 현재 방 타입에 맞는 몬스터 로드
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
                _showDifficultySelector();
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
    // 이전에 클리어되지 않은 방만 보상 로직을 거치도록 처리
    if (!_dungeonMap.currentRoom.isCleared) { 
      _dungeonMap.currentRoom.isCleared = true; // 현재 방 클리어 상태로 변경
    }
    _showMoveButtons = true; // 이동 버튼 표시
  });
  await Future.delayed(const Duration(milliseconds: 1500));
  
  if (!currentContext.mounted) return;

  // 보상 중복 획득 방지: 이미 클리어된 방이 아니면 보상 지급
  if (_dungeonMap.currentRoom.isCleared) { // 클리어 상태를 여기서 다시 확인하여 보상 지급 여부 결정
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

    String dialogContent = "기록: ${_formatTime(_secondsElapsed)}\n";
    dialogContent += "획득 골드: $earnedGold G\n";
    dialogContent += "획득 경험치: $earnedXp XP\n\n";
    
    if (leveledUp) {
      dialogContent += "🎉 레벨업! (Lv.${_userData.level - initialUserLevel} UP!)\n";
      dialogContent += "레벨업 보너스: $bonusGoldFromLevelUp G\n\n";
    }

    dialogContent += "현재 레벨: Lv.${_userData.level}\n";
    dialogContent += "현재 XP: ${_userData.currentXp} / ${_userData.totalXpNeeded} XP\n";
    dialogContent += "현재 골드: ${_userData.gold} G\n\n";
    dialogContent += "새로운 도전을 시작할까요?";

    // ignore: use_build_context_synchronously
    showDialog(
      context: currentContext,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("🎉 퍼즐 해결!", textAlign: TextAlign.center),
        content: Text(
          dialogContent,
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _isSuccessAnimation = false);
                // _showDifficultySelector(); // 방 클리어 후에는 난이도 선택 대신 이동 버튼을 보여줘야 함
              },
              child: const Text("새 게임 시작"),
            ),
          ),
        ],
      ),
    );
  }
}

void _showGameOverDialog() {
    _timer?.cancel();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("게임 오버"),
        content: const Text("실수 횟수를 초과했습니다. 다시 시작하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showDifficultySelector();
            }, 
            child: const Text("새 게임")
          )
        ],
      ),
    );
  }

  bool _isCellLocked() {
    if (_selectedRow == null || _selectedCol == null) return true;
    int r = _selectedRow!;
    int c = _selectedCol!;
    
    bool isInitial = _getCurrentSudokuBoard().initialGrid[r][c] != 0;
    bool isCorrectlyFilled = _getCurrentSudokuBoard().currentGrid[r][c] != 0 && !_getCurrentSudokuBoard().errorMap[r][c];

    return isInitial || isCorrectlyFilled;
  }

  void _showDifficultySelector() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("새 게임 난이도 선택"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Difficulty.values.map((d) {
            return ListTile(
              title: Text(d.label),
              subtitle: Text("빈칸 개수: ${d.emptyCells}"),
              onTap: () {
                Navigator.pop(context);
                _createNewGame(d);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return GestureDetector(
      onTap: _togglePause,
      child: Container(
        color: Colors.white.withOpacity(0.8),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow, size: 80, color: Colors.blue),
              SizedBox(height: 16),
              Text("일시정지됨", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text("화면을 터치하여 재개", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  // 방 이동 로직
  void _moveToRoom(int newX, int newY) {
    setState(() {
      _dungeonMap.move(newX, newY); // 던전 맵의 현재 위치 업데이트
      final RoomData targetRoom = _dungeonMap.currentRoom; // 이동 후 현재 방 (targetRoom)

      if (targetRoom.isCleared) {
        _addCombatLog("이미 정복한 지역입니다.");
        _showMoveButtons = true; // 이동 화살표를 바로 보여줌
        // 클리어된 방은 상태를 초기화하지 않고 그대로 보여줌
        _currentMonster = Monster.empty(); // 몬스터 없음
        _timer?.cancel(); // 타이머 중지 (클리어된 방은 시간 흐르지 않음)
      } else {
        // 클리어되지 않은 방으로 이동 시 게임 상태 초기화
        _secondsElapsed = 0; // 타이머 초기화
        _isPaused = false;
        _isSuccessAnimation = false;
        _showMoveButtons = false; // 이동 후 다시 스도쿠 화면으로 전환
        _selectedRow = null;
        _selectedCol = null;
        _hintsRemaining = 0; // 힌트 초기화
        _undoUses = 0; // 실행 취소 횟수 초기화
        _history.clear(); // 기록 초기화
        _combatLogMessages.clear(); // 전투 로그 초기화
        _currentMonster = MonsterTemplates.getMonsterForRoom(_dungeonMap.currentRoom.type); // 현재 방 타입에 맞는 몬스터 로드
        _startTimer(); // 타이머 시작
      }
    });
  }

  // 이동 버튼 위젯 생성 헬퍼
  Widget _buildMoveButton(String direction, IconData icon, int targetX, int targetY) {
    bool canMove = (targetX >= 0 && targetX < _dungeonMap.width &&
                    targetY >= 0 && targetY < _dungeonMap.height);

    return ElevatedButton(
      onPressed: canMove ? () => _moveToRoom(targetX, targetY) : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        shape: const CircleBorder(),
        backgroundColor: canMove ? Colors.blue : Colors.grey,
        foregroundColor: Colors.white,
      ),
      child: Icon(icon, size: 30),
    );
  }

  // 이동 버튼 UI를 구성하는 위젯
  Widget _buildMoveButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildMoveButton("Up", Icons.arrow_upward, _dungeonMap.currentX, _dungeonMap.currentY - 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMoveButton("Left", Icons.arrow_back, _dungeonMap.currentX - 1, _dungeonMap.currentY),
            const SizedBox(width: 80), // 중앙 빈 공간
            _buildMoveButton("Right", Icons.arrow_forward, _dungeonMap.currentX + 1, _dungeonMap.currentY),
          ],
        ),
        _buildMoveButton("Down", Icons.arrow_downward, _dungeonMap.currentX, _dungeonMap.currentY + 1),
      ],
    );
  }

  // 실제 게임 화면을 구성하는 헬퍼
  Widget _buildGameScreen() {
    bool isLocked = _isCellLocked();
    return KeyboardListener( // 여기에 KeyboardListener 추가
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent && !_isPaused) {
          final label = event.logicalKey.keyLabel;
          if (RegExp(r'^[1-9]$').hasMatch(label)) {
            _handleNumberInput(int.parse(label));
          } else if (label == 'f' || label == 'F') { // Check for 'F' key
            _fillOneEmptyCellWithAnswer(); // Call a new function
          } else if (event.logicalKey == LogicalKeyboardKey.backspace ||
                     event.logicalKey == LogicalKeyboardKey.delete) {
            _handleNumberInput(0);
          }
        }
      },
      child: Column( // KeyboardListener의 child는 Column
        children: [
        GameStatus(
          difficulty: _getCurrentSudokuBoard().difficulty.label,
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
        const Divider(),
        
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _showMoveButtons
                  ? Stack( // 스도쿠 판 위에 메시지와 이동 버튼을 겹치기
                      children: [
                        SudokuGrid( // 클리어된 방은 이전 스도쿠 판을 그대로 보여줌
                          board: _getCurrentSudokuBoard(),
                          onCellTap: _onCellTapped,
                          selectedRow: _selectedRow,
                          selectedCol: _selectedCol,
                          errorMap: _getCurrentSudokuBoard().errorMap,
                          isSuccess: _isSuccessAnimation,
                        ),
                        // 클리어된 방일 경우 메시지 오버레이
                        if (_dungeonMap.currentRoom.isCleared)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black54, // 어두운 오버레이
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "이미 정복한 지역입니다!",
                                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildMoveButtons(), // 이동 버튼
                                ],
                              ),
                            ),
                          )
                        else // 클리어되지 않은 방이 막 클리어된 경우
                          Positioned.fill(
                            child: Container(
                              color: Colors.black54,
                              child: _buildMoveButtons(), // 이동 버튼만 표시
                            ),
                          ),
                      ],
                    )
                  : SudokuGrid(
                      board: _getCurrentSudokuBoard(),
                      onCellTap: _onCellTapped,
                      selectedRow: _selectedRow,
                      selectedCol: _selectedCol,
                      errorMap: _getCurrentSudokuBoard().errorMap,
                      isSuccess: _isSuccessAnimation,
                    ),
            ),
          ),
        ),

        CombatLog(logMessages: _combatLogMessages),

        ActionButtons(
          onUndo: (_history.isEmpty || _undoUses >= _maxUndoUses) ? null : () {
            _undoUses++; // 실행 취소 횟수 증가
            _handleUndo();
          },
          onDelete: (isLocked || _isPaused) ? null : () => _handleNumberInput(0),
          onMemoToggle: isLocked ? null : () => setState(() => _isMemoMode = !_isMemoMode),
          isMemoOn: _isMemoMode,
          hintCount: _hintsRemaining,
          onHint: (isLocked || _hintsRemaining <= 0 || _isPaused || _selectedRow == null) 
              ? null 
              : () {
                  setState(() {
                    _history.add(GameState(
                      dungeonMap: _dungeonMap.clone(),
                      currentMonster: _currentMonster,
                      playerCombatStats: _playerCombatStats,
                      combatLogMessages: List<String>.from(_combatLogMessages),
                      comboCount: _comboCount,
                      lastCorrectEntryTime: _lastCorrectEntryTime,
                      hintsRemaining: _hintsRemaining,
                      undoUses: _undoUses,
                    ));
                    if (_history.length > 20) {
                      _history.removeAt(0);
                    }
                    _getCurrentSudokuBoard().giveHint(_selectedRow!, _selectedCol!);
                    _hintsRemaining--;
                  });
                },
          undoCount: _undoUses,
          maxUndoCount: _maxUndoUses,
        ),

        NumberKeypad(
          board: _getCurrentSudokuBoard(),
          onNumberTap: (_isPaused || isLocked) ? null : (n) => _handleNumberInput(n),
        ),
        const AdSenseWidget(),
      ],
      )
    );
  }

    @override
  Widget build(BuildContext context) {
    // build 메서드에서는 _isCellLocked를 직접 사용하지 않고 _buildGameScreen에 위임
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              _timer?.cancel();
              _showDifficultySelector();
            },
          ),
          // 강제 클리어 버튼
          TextButton(
            onPressed: () {
              setState(() {
                _dungeonMap.currentRoom.isCleared = true;
                _showMoveButtons = true;
                _addCombatLog("현재 방을 강제 클리어했습니다!");
              });
            },
            child: const Text("강제 클리어", style: TextStyle(color: Colors.black)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: MonsterStatus(monster: _currentMonster),
        ),
      ),
      body: Stack( // Use Stack to overlay the pause screen
        children: [
          AnimatedBuilder(
            animation: _screenShakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: _screenShakeAnimation.value,
                child: child,
              );
            },
            child: Row( // Row로 변경하여 미니맵과 게임 화면을 나란히 배치
              children: [
                Expanded(
                  child: Column( // 기존 Column 내용을 Expanded로 감싸고 디버그 UI 추가
                    children: [
                      // 디버그 UI: 현재 좌표 표시
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "현재 위치: (${_dungeonMap.currentX}, ${_dungeonMap.currentY})",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(child: _buildGameScreen()), // 게임 화면 헬퍼 호출
                    ],
                  ),
                ),
                MiniMap(dungeonMap: _dungeonMap), // 미니맵 위젯 추가
              ],
            ),
          ),
          if (_isPaused) _buildPauseOverlay(), // Overlay pause screen
        ],
      )
    );
  }
}