import 'dart:math';

class SudokuEntry {
  final int row;
  final int col;
  final int previousValue;
  final List<int> previousNotes;

  SudokuEntry(this.row, this.col, this.previousValue, this.previousNotes);
}

enum Difficulty {
  easy(emptyCells: 30, label: "쉬움"),
  medium(emptyCells: 45, label: "보통"),
  hard(emptyCells: 55, label: "어려움");

  final int emptyCells;
  final String label;
  const Difficulty({required this.emptyCells, required this.label});
}

class SudokuBoard {
  late List<List<int>> initialGrid;
  late List<List<int>> solution;
  late List<List<int>> currentGrid;
  List<List<bool>> errorMap = List.generate(9, (_) => List.filled(9, false));
  List<List<List<int>>> notes = List.generate(9, (_) => List.generate(9, (_) => []));
  late List<List<bool>> scoreAwarded;

  int mistakes = 0;
  final int maxMistakes = 3;
  int score = 0;
  List<SudokuEntry> undoStack = [];
  Difficulty difficulty;

  // ⭐️ 단일 생성자로 통합
  SudokuBoard({this.difficulty = Difficulty.medium}) {
    // 1. 완성된 판 생성
    solution = _generateSolvedBoard();
    // 2. 난이도에 맞춰 구멍 뚫기
    initialGrid = _createPuzzle(solution, difficulty);
    // 3. 현재 판 복사
    currentGrid = initialGrid.map((row) => List<int>.from(row)).toList();

    scoreAwarded = List.generate(9, (_) => List.filled(9, false));
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (initialGrid[r][c] != 0) {
          scoreAwarded[r][c] = true; // 이미 채워진 문제는 점수 대상 제외
        }
      }
    }
  }
  

  // --- 보드 생성 알고리즘 ---

  static List<List<int>> _generateSolvedBoard() {
    List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
    _fillBoard(board);
    return board;
  }

  static bool _fillBoard(List<List<int>> board) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle();
          for (int num in numbers) {
            if (_isValid(board, row, col, num)) {
              board[row][col] = num;
              if (_fillBoard(board)) return true;
              board[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  static List<List<int>> _createPuzzle(List<List<int>> solved, Difficulty diff) {
    List<List<int>> puzzle = solved.map((row) => List<int>.from(row)).toList();
    int cellsToRemove = diff.emptyCells;
    Random random = Random();
    
    while (cellsToRemove > 0) {
      int r = random.nextInt(9);
      int c = random.nextInt(9);
      if (puzzle[r][c] != 0) {
        puzzle[r][c] = 0;
        cellsToRemove--;
      }
    }
    return puzzle;
  }

  static bool _isValid(List<List<int>> board, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (board[row][i] == num || board[i][col] == num) return false;
    }
    int startRow = (row ~/ 3) * 3, startCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[startRow + i][startCol + j] == num) return false;
      }
    }
    return true;
  }

  // --- 게임 로직 ---

  void setNumber(int row, int col, int number, {bool isMemoMode = false}) {
    if (initialGrid[row][col] != 0) return;

    undoStack.add(SudokuEntry(
      row, col, currentGrid[row][col], List<int>.from(notes[row][col]),
    ));

    if (isMemoMode && number != 0) {
      if (notes[row][col].contains(number)) {
        notes[row][col].remove(number);
      } else {
        notes[row][col].add(number);
        notes[row][col].sort();
      }
      currentGrid[row][col] = 0;
      errorMap[row][col] = false; // 메모 모드 시 에러 표시 제거
    } else {
      currentGrid[row][col] = number;
      notes[row][col].clear();

      if (number != 0) {
        if (number != solution[row][col]) {
          errorMap[row][col] = true;
          mistakes++;
        } else {
          errorMap[row][col] = false;
          if (!scoreAwarded[row][col]) {
            score += 10;
            scoreAwarded[row][col] = true; // 점수 지급 완료 기록
          }
        }
      } else {
        errorMap[row][col] = false;
      }
    }
  }

// ⭐️ 4. 힌트 사용 시에도 점수를 주지 않도록 설정 (선택 사항)
  void giveHint(int row, int col) {
    if (initialGrid[row][col] == 0) {
      currentGrid[row][col] = solution[row][col];
      notes[row][col].clear();
      errorMap[row][col] = false;
      scoreAwarded[row][col] = true; // 힌트로 맞춘 칸은 점수 지급 대상으로 잠금
    }
  }
  void undo() {
    if (undoStack.isEmpty) return;
    final lastAction = undoStack.removeLast();
    currentGrid[lastAction.row][lastAction.col] = lastAction.previousValue;
    notes[lastAction.row][lastAction.col] = lastAction.previousNotes;
    
    // 이전 값이 정답인지 다시 체크하여 errorMap 갱신
    int val = currentGrid[lastAction.row][lastAction.col];
    if (val != 0 && val != solution[lastAction.row][lastAction.col]) {
      errorMap[lastAction.row][lastAction.col] = true;
    } else {
      errorMap[lastAction.row][lastAction.col] = false;
    }
  }

  bool isSolved() {
  for (int r = 0; r < 9; r++) {
    for (int c = 0; c < 9; c++) {
      // 빈칸이 하나라도 있거나, 에러(중복)가 하나라도 있으면 false
      if (currentGrid[r][c] == 0 || errorMap[r][c]) {
        return false;
      }
    }
  }
  return true;
}

  int getCountOfNumber(int number) {
  int count = 0;
  for (int r = 0; r < 9; r++) {
    for (int c = 0; c < 9; c++) {
      // 숫자가 같고, 에러가 없는(정답인) 상태만 카운트
      if (currentGrid[r][c] == number && !errorMap[r][c]) {
        count++;
      }
    }
  }
  return count;
}
}