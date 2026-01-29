import 'dart:async'; // ⭐️ 타이머를 위해 추가

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/sudoku_board.dart';
import 'widgets/sudoku_grid.dart';
import 'models/user_data.dart'; // Add this import
import 'models/combat_data.dart'; // Add this import

import 'widgets/number_keypad.dart';
import 'widgets/game_status.dart';
import 'widgets/action_buttons.dart';
import 'widgets/ad_element.dart';
import 'widgets/monster_status.dart'; // Add this import
import 'widgets/combat_log.dart'; // Add this import


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
  SudokuBoard _board = SudokuBoard(difficulty: Difficulty.medium);
  UserData _userData = UserData.initial(); // Add UserData member variable
  Monster _currentMonster = MonsterTemplates.numberSlime(); // Add current monster
  PlayerCombatStats _playerCombatStats = PlayerCombatStats(); // Add player combat stats
  // 현재 선택된 셀 (선택하지 않았을 때는 null)
  int? _selectedRow;
  int? _selectedCol;
  
  // 게임 상태 변수
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isMemoMode = false;
  int _hintsRemaining = 3;
  bool _isPaused = false;
  bool _isSuccessAnimation = false;

  final List<String> _combatLogMessages = []; // Combat log messages
  int _comboCount = 0; // Combo count for attacks
  DateTime? _lastCorrectEntryTime; // To track time for combo attacks

  // Screen shake animation
  late AnimationController _screenShakeController;
  late Animation<Offset> _screenShakeAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data at startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDifficultySelector();
    });

    _screenShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // Quick shake
    );
    _screenShakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.02, 0), // Shake 2% horizontally
    ).animate(
      CurvedAnimation(
        parent: _screenShakeController,
        curve: Curves.elasticOut,
      ),
    )..addListener(() {
        setState(() {}); // Rebuild to apply shake
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _screenShakeController.reverse(); // Shake back to original position
        }
      });
  }

  // Add _loadUserData method
  Future<void> _loadUserData() async {
    final UserData loadedData = await LocalStorageService.loadUserData();
    setState(() {
      _userData = loadedData;
    });
  }

  // Add _saveUserData method
  Future<void> _saveUserData() async {
    await LocalStorageService.saveUserData(_userData);
  }

  void _addCombatLog(String message) {
    setState(() {
      _combatLogMessages.add(message);
      if (_combatLogMessages.length > 10) { // Keep log to a reasonable size
        _combatLogMessages.removeAt(0);
      }
    });
  }

  // 난이도별 기본 보상 (골드, 경험치)
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
  // TODO: Expert 난이도 추가시 업데이트

  // 난이도별 목표 시간 (초) - 보너스 배수용
  static const Map<Difficulty, int> _targetTimes = {
    Difficulty.easy: 180, // 3분
    Difficulty.medium: 360, // 6분
    Difficulty.hard: 600, // 10분
  };
  // TODO: Expert 난이도 추가시 업데이트

  // 보상 계산 함수
  (int, int) _calculateReward({
    required Difficulty difficulty,
    required int timeElapsed,
    required int mistakes,
  }) {
    double gold = _baseGold[difficulty]!.toDouble();
    double xp = _baseXp[difficulty]!.toDouble();

    // 보너스 배수 1: 실수 0회
    if (mistakes == 0) {
      gold *= 1.2;
      xp *= 1.2;
      _userData.stats.noMissCount++; // 실수 0회 통계 업데이트
    }

    // 보너스 배수 2: 목표 시간 내 클리어
    final targetTime = _targetTimes[difficulty];
    if (targetTime != null && timeElapsed <= targetTime) {
      gold *= 1.3;
      xp *= 1.3;
    }
    
    _userData.stats.totalCleared++; // 클리어 통계 업데이트

    return (gold.toInt(), xp.toInt());
  }

void _createNewGame([Difficulty? difficulty]) {
  // 만약 취소 등으로 난이도가 전달되지 않으면 기본값 medium 사용
  final targetDifficulty = difficulty ?? Difficulty.medium;
  
  _timer?.cancel(); 
  setState(() {
    _board = SudokuBoard(difficulty: targetDifficulty);
    _secondsElapsed = 0;
    _isPaused = false;
    _selectedRow = null;
    _selectedCol = null;
    _hintsRemaining = 3;
    _isSuccessAnimation = false; // 성공 애니메이션 초기화
    _currentMonster = MonsterTemplates.numberSlime(); // Reset monster HP
    _playerCombatStats = PlayerCombatStats(); // Reset player HP
    _comboCount = 0; // Reset combo count
    _lastCorrectEntryTime = null; // Reset combo timer
  });
  _startTimer();
}

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  // 초 단위를 00:00 형식으로 변환
  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

@override
  void dispose() {
    _timer?.cancel();
    _screenShakeController.dispose(); // Dispose shake controller
    super.dispose();
  }

  // 보드 셀이 탭되었을 때 호출되는 함수
  void _onCellTapped(int row, int col) {
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
      _isMemoMode = false; // 다른 칸 누르면 메모 모드 꺼짐
    });
  }

  // 일시정지 토글 함수
void _togglePause() {
  setState(() {
    _isPaused = !_isPaused;
    if (_isPaused) {
      _timer?.cancel();
    } else {
      _startTimer();
    }
  });
}

// 2. 입력 처리 함수 수정 (성공 시퀀스 트리거 추가)
  bool _isCellCompletionCritical(int row, int col, int number) {
    // Check if completing 3x3 box
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    bool boxComplete = true;
    for (int rLoop = startRow; rLoop < startRow + 3; rLoop++) {
      for (int cLoop = startCol; cLoop < startCol + 3; cLoop++) {
        if (_board.currentGrid[rLoop][cLoop] == 0 && !(rLoop == row && cLoop == col)) {
          boxComplete = false;
          break;
        }
      }
      if (!boxComplete) break;
    }
    if (boxComplete) return true;

    // Check if completing row
    bool rowComplete = true;
    for (int cLoop = 0; cLoop < 9; cLoop++) {
      if (_board.currentGrid[row][cLoop] == 0 && cLoop != col) {
        rowComplete = false;
        break;
      }
    }
    if (rowComplete) return true;

    // Check if completing column
    bool colComplete = true;
    for (int rLoop = 0; rLoop < 9; rLoop++) {
      if (_board.currentGrid[rLoop][col] == 0 && rLoop != row) {
        colComplete = false;
        break;
      }
    }
    if (colComplete) return true;

    return false;
  }

// 2. 입력 처리 함수 수정 (성공 시퀀스 트리거 추가)
void _handleNumberInput(int number) {
  // 1. 기본 방어막: 선택된 칸이 없거나, 일시정지 중이거나, 성공 애니메이션 중이면 무시
  if (_selectedRow == null || _selectedCol == null || _isPaused || _isSuccessAnimation) return;

  // 2. 잠금 체크: 문제 칸(Initial)이거나 이미 맞춘 정답 칸이면 '입력'도 '지우기'도 불가
  if (_isCellLocked()) {
    _addCombatLog("잠긴 칸에는 숫자를 입력할 수 없습니다.");
    return;
  }

  // 3. 숫자 개수 제한 체크: 이미 9개가 다 찬 숫자를 일반 모드에서 입력하려 할 때 무시
  if (!_isMemoMode && number != 0 && _board.getCountOfNumber(number) >= 9) {
    _addCombatLog("$number는 이미 9개 모두 채워졌습니다.");
    return;
  }

  // Check if the current input is correct
  final int currentRow = _selectedRow!;
  final int currentCol = _selectedCol!;
  // Temporarily apply the number to check if it's correct against the solution
  final bool isCorrectInput = (number == 0) || (number == _board.solution[currentRow][currentCol]);
  
  if (isCorrectInput && number != 0) { // Correct number placed (not erasing)
    setState(() {
      _board.setNumber(currentRow, currentCol, number, isMemoMode: _isMemoMode);
      
      // 전투 로직 - 정답일 때
      double damage = number * _playerCombatStats.attackPower.toDouble();
      String logMessage = "$number를 맞혔습니다!";

      // 콤보 로직
      if (_lastCorrectEntryTime != null && DateTime.now().difference(_lastCorrectEntryTime!).inSeconds < 3) { // 3초 이내
        _comboCount++;
        damage *= (1 + _comboCount * 0.1); // 콤보 보너스 (예: 콤보당 10% 추가)
        logMessage += " 콤보! ${_comboCount}연타!";
      } else {
        _comboCount = 1; // 새 콤보 시작
      }
      _lastCorrectEntryTime = DateTime.now(); // 콤보 타이머 업데이트

      // 크리티컬 로직 (현재 숫자 입력으로 완성될 때)
      bool isCritical = _isCellCompletionCritical(currentRow, currentCol, number);
      if (isCritical) {
        damage *= 2.0; // 크리티컬 데미지 2배
        logMessage += " 크리티컬!!";
      }

      _currentMonster.takeDamage(damage.toInt());
      logMessage += " ${_currentMonster.name}에게 ${damage.toInt()}의 데미지!";
      _addCombatLog(logMessage);

      // 몬스터 처치 확인
      if (_currentMonster.isDefeated()) {
        _addCombatLog("${_currentMonster.name}을(를) 처치했습니다!");
        _handleMonsterDefeat(); // 몬스터 처치 로직
      } else {
        // 일반적인 게임 로직 (실수 체크, 성공 체크)는 몬스터 처치 후가 아닌 경우에만 진행
        if (!_isMemoMode) {
          if (_board.mistakes >= _board.maxMistakes) {
            _timer?.cancel();
            _showGameOverDialog();
            return; 
          }
          if (_board.isSolved()) { // 스도쿠 자체가 풀렸을 때 (몬스터 처치와 별개)
            _timer?.cancel();
            _triggerSuccessSequence(); 
          }
        }
      }
    });
  } else if (!isCorrectInput) { // Incorrect number placed
    setState(() {
      _board.setNumber(currentRow, currentCol, number, isMemoMode: _isMemoMode); // 기록은 남김
      _comboCount = 0; // 콤보 초기화
      _lastCorrectEntryTime = null; // 콤보 타이머 초기화

      // 플레이어 피격 로직
      _playerCombatStats.takeDamage(_currentMonster.attackPower);
      _addCombatLog("오답! ${_currentMonster.name}의 반격! ${_playerCombatStats.attackPower} 데미지를 받았습니다!");
      _screenShakeController.forward(from: 0.0); // Trigger screen shake

      // 플레이어 사망 확인
      if (_playerCombatStats.isDefeated()) {
        _addCombatLog("플레이어가 쓰러졌습니다...");
        _handlePlayerDefeat(); // 플레이어 사망 로직
      } else {
        // 몬스터의 특수 능력 발동 (일단은 로그만)
        _addCombatLog("${_currentMonster.name}이(가) ${currentCol+1}열을 진흙으로 가렸습니다!"); // 임시 메시지
        _triggerMonsterSpecialAbility(); // Monster special ability (e.g., board obfuscation)
      }
      
      // 실수 카운트는 _board.setNumber 내부에서 처리되므로 별도 처리 불필요
      if (_board.mistakes >= _board.maxMistakes) {
        _timer?.cancel();
        _showGameOverDialog();
      }
    });
  } else { // Number is 0 (erasing a correct input by user)
    setState(() {
      _board.setNumber(currentRow, currentCol, 0, isMemoMode: _isMemoMode); // 지우기
      _comboCount = 0; // 지웠으니 콤보 초기화
      _lastCorrectEntryTime = null; // 콤보 타이머 초기화
      _addCombatLog("숫자를 지웠습니다.");
    });
  }
}

  // 몬스터 처치 로직
  void _handleMonsterDefeat() async {
    _timer?.cancel();

    // 보상 지급
    final int initialUserLevel = _userData.level;
    _userData.addGold(_currentMonster.rewardGold);
    _userData.addXp(_currentMonster.rewardXp);
    await _saveUserData();

    final bool leveledUp = _userData.level > initialUserLevel;
    final int bonusGoldFromLevelUp = leveledUp ? (_userData.level - initialUserLevel) * 50 : 0;
    if (leveledUp) {
      _userData.addGold(bonusGoldFromLevelUp);
      await _saveUserData();
    }

    String dialogContent = "${_currentMonster.name}을(를) 물리쳤습니다!\n\n";
    dialogContent += "획득 골드: ${_currentMonster.rewardGold} G\n";
    dialogContent += "획득 경험치: ${_currentMonster.rewardXp} XP\n\n";

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
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("🎉 몬스터 처치!", textAlign: TextAlign.center),
        content: Text(dialogContent, textAlign: TextAlign.center),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _isSuccessAnimation = false);
                _showDifficultySelector(); // 다음 몬스터 (새 게임) 시작
              },
              child: const Text("새 게임 시작"),
            ),
          ),
        ],
      ),
    );
  }

  // 플레이어 패배 로직
  void _handlePlayerDefeat() async {
    _timer?.cancel();
    _screenShakeController.forward(from: 0.0); // Trigger screen shake
    // ignore: use_build_context_synchronously
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
                _createNewGame(); // 새 게임 시작
              },
              child: const Text("다시 도전"),
            ),
          ),
        ],
      ),
    );
  }

  // 몬스터 특수 능력 (플레이어 오답 시)
  void _triggerMonsterSpecialAbility() {
    // 숫자 슬라임은 보드 한 칸을 진흙으로 가림 (구현은 일단 로그만)
    _addCombatLog("${_currentMonster.name}이(가) 특수 능력을 사용했습니다!");
    // 실제 보드 가리기 로직 (예: 랜덤한 빈 칸을 일시적으로 비활성화)
    // TODO: Need to implement actual board obfuscation if desired.
  }

// 3. 🎉 성공 시퀀스: 이펙트 후 난이도 선택창 호출
void _triggerSuccessSequence() async {
  if (!mounted) return; // Pre-check before capturing context
  final BuildContext currentContext = context; // Capture context

  setState(() {
    _isSuccessAnimation = true;
    _selectedRow = null; // 강조 효과를 위해 선택 해제
    _selectedCol = null;
  });
  // 1.5초 동안 초록색 반짝임 효과 대기
  await Future.delayed(const Duration(milliseconds: 1500));
  
  if (!currentContext.mounted) return; // Re-check mounted status after async gap with captured context

  // Calculate rewards
  final int initialUserLevel = _userData.level;
  final (int earnedGold, int earnedXp) = _calculateReward(
    difficulty: _board.difficulty,
    timeElapsed: _secondsElapsed,
    mistakes: _board.mistakes,
  );

  // Update user data
  _userData.addGold(earnedGold);
  _userData.addXp(earnedXp);
  await _saveUserData(); // Save updated data

  final bool leveledUp = _userData.level > initialUserLevel;
  final int bonusGoldFromLevelUp = leveledUp ? (_userData.level - initialUserLevel) * 50 : 0; // 50G per level up
  if (leveledUp) {
    _userData.addGold(bonusGoldFromLevelUp);
    await _saveUserData(); // Save again if bonus gold is added
  }

  // Build the content for the dialog
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


  // 성공 팝업 띄우기
  // ignore: use_build_context_synchronously
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text("🎉 퍼즐 해결!", textAlign: TextAlign.center),
      content: Text(
        dialogContent, // Use the dynamically built content
        textAlign: TextAlign.center,
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isSuccessAnimation = false);
              _showDifficultySelector(); // 👈 바로 난이도 선택창 오픈
            },
            child: const Text("새 게임 시작"),
          ),
        ),
      ],
    ),
  );
}

void _showGameOverDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text("게임 오버"),
      content: const Text("실수 횟수(3회)를 초과했습니다. 다시 시작하시겠습니까?"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _createNewGame(Difficulty.hard); // ⭐️ 직접 생성하지 말고 이 함수를 호출하세요.
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
  
  bool isInitial = _board.initialGrid[r][c] != 0;
  // 이미 정답을 맞혔고 에러가 없는 상태 (즉, 확정된 상태)
  bool isCorrect = _board.currentGrid[r][c] != 0 && !_board.errorMap[r][c];
  
  return isInitial || isCorrect;
}

void _showDifficultySelector() {
  showDialog(
    context: context,
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
    onTap: _togglePause, // 화면을 터치하면 다시 시작
    child: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_arrow, size: 80, color: Colors.blue),
          SizedBox(height: 16),
          Text("게임 일시정지됨", style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
          Text("화면을 터치하여 재개", style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    ),
  );
}

    @override

  Widget build(BuildContext context) {

    // 1. 현재 선택된 셀의 상태를 미리 계산합니다.

    bool isCellLocked = _isCellLocked(); // 이미 맞춘 정답이나 문제 칸인가?

    

    return Scaffold(

      backgroundColor: Colors.white,

      appBar: AppBar(
      title: const Text('Sudoku Master', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.black),
          onPressed: () {
            _timer?.cancel(); // 진행 중인 타이머 멈춤
            _showDifficultySelector(); // 즉시 난이도 선택창 팝업
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(100.0), // Adjust height as needed
        child: MonsterStatus(monster: _currentMonster),
      ),
    ),
    body: AnimatedBuilder( // Wrap the body with AnimatedBuilder for shake
      animation: _screenShakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: _screenShakeAnimation.value,
          child: child, // Pass the child to Transform.translate
        );
      },
      child: KeyboardListener(
        focusNode: FocusNode()..requestFocus(), // 키보드 포커스 강제 지정
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            final label = event.logicalKey.keyLabel;
            // 숫자 1-9 키 감지
            if (RegExp(r'^[1-9]$').hasMatch(label)) {
              _handleNumberInput(int.parse(label));
            } 
            // 백스페이스나 Delete 키로 숫자 지우기
            else if (event.logicalKey == LogicalKeyboardKey.backspace || 
                     event.logicalKey == LogicalKeyboardKey.delete) {
              _handleNumberInput(0);
            }
          }
        },
        child: Column(
          children: [
            GameStatus(
              difficulty: _board.difficulty.label,
              mistakes: _board.mistakes,
              maxMistakes: _board.maxMistakes,
              // score: _board.score, // Removed, no longer needed
              time: _formatTime(_secondsElapsed),
              onPauseTap: _togglePause,
              // Pass new player stats
              playerLevel: _userData.level,
              playerCurrentXp: _userData.currentXp,
              playerTotalXpNeeded: _userData.totalXpNeeded,
              playerGold: _userData.gold,
            ),
            const Divider(),
            
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isPaused 
                      ? _buildPauseOverlay() 
                      : SudokuGrid(
                          board: _board,
                          onCellTap: _onCellTapped,
                          selectedRow: _selectedRow,
                          selectedCol: _selectedCol,
                          errorMap: _board.errorMap,
                          isSuccess: _isSuccessAnimation, // 👈 추가된 상태 전달
                        ),
                ),
              ),
            ),

            CombatLog(logMessages: _combatLogMessages), // Add CombatLog here

            // ⭐️ 복원 2: 비활성화 상태(null)를 하단 버튼들에 전달합니다.
            ActionButtons(
              onUndo: () => setState(() => _board.undo()),
              // 문제 칸(initial)은 절대 지울 수 없음
              onDelete: (isCellLocked || _isPaused) ? null : () => _handleNumberInput(0),
              // 이미 맞춘 칸이나 문제 칸은 메모/힌트 불가
              onMemoToggle: isCellLocked ? null : () => setState(() => _isMemoMode = !_isMemoMode),
              isMemoOn: _isMemoMode,
              hintCount: _hintsRemaining,
              onHint: (isCellLocked || _hintsRemaining <= 0) 
                  ? null 
                  : () {
                      setState(() {
                        _board.giveHint(_selectedRow!, _selectedCol!);
                        _hintsRemaining--;
                      });
                    },
            ),

            // ⭐️ 복원 3: 숫자 키패드에도 비활성화 로직 적용
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: NumberKeypad(
                board: _board, // ⭐️ 보드 객체 전달
                onNumberTap: isCellLocked ? null : (n) => _handleNumberInput(n),
              ),
            ),
            const AdSenseWidget(),
          ],
        ),
      ),
    )
    );
}
}