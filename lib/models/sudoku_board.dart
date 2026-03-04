import 'dart:math';

// This class is no longer used by SudokuBoard's internal undo system.
class SudokuEntry {
  final int row;
  final int col;
  final int previousValue;
  final List<int> previousNotes;

  SudokuEntry(this.row, this.col, this.previousValue, this.previousNotes);
}

enum Difficulty {
  easy(emptyCells: 30, label: "안전", rpgGrade: "Safe"),
  medium(emptyCells: 45, label: "위험", rpgGrade: "Danger"),
  hard(emptyCells: 55, label: "치명적", rpgGrade: "Fatal");

  final int emptyCells;
  final String label;
  final String rpgGrade;
  const Difficulty({
    required this.emptyCells,
    required this.label,
    required this.rpgGrade,
  });
}

class SudokuBoard {
  late List<List<int>> initialGrid;
  late List<List<int>> solution;
  late List<List<int>> currentGrid;
  List<List<bool>> errorMap = List.generate(9, (_) => List.filled(9, false));
  List<List<List<int>>> notes = List.generate(
    9,
    (_) => List.generate(9, (_) => []),
  );
  late List<List<bool>> scoreAwarded;

  int mistakes = 0;
  final int maxMistakes = 3;
  int score = 0;
  // undoStack is removed, will be handled by GameState history.
  Difficulty difficulty;
  final int? seed;

  SudokuBoard({this.difficulty = Difficulty.medium, this.seed}) {
    solution = _generateSolvedBoard(seed);
    initialGrid = _createPuzzle(solution, difficulty, seed);
    currentGrid = initialGrid.map((row) => List<int>.from(row)).toList();
    scoreAwarded = List.generate(9, (_) => List.filled(9, false));
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (initialGrid[r][c] != 0) {
          scoreAwarded[r][c] = true;
        }
      }
    }
  }

  // Method to create a deep copy of the board state.
  SudokuBoard clone() {
    final newBoard = SudokuBoard(difficulty: difficulty, seed: seed);
    newBoard.initialGrid = initialGrid
        .map((row) => List<int>.from(row))
        .toList();
    newBoard.solution = solution.map((row) => List<int>.from(row)).toList();
    newBoard.currentGrid = currentGrid
        .map((row) => List<int>.from(row))
        .toList();
    newBoard.errorMap = errorMap.map((row) => List<bool>.from(row)).toList();
    newBoard.notes = notes
        .map((row) => row.map((cell) => List<int>.from(cell)).toList())
        .toList();
    newBoard.scoreAwarded = scoreAwarded
        .map((row) => List<bool>.from(row))
        .toList();
    newBoard.mistakes = mistakes;
    newBoard.score = score;
    return newBoard;
  }

  // --- Board Generation Algorithms ---

  static List<List<int>> _generateSolvedBoard(int? seed) {
    List<List<int>> board = List.generate(9, (_) => List.filled(9, 0));
    _fillBoard(board, Random(seed));
    return board;
  }

  static bool _fillBoard(List<List<int>> board, Random random) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (board[row][col] == 0) {
          List<int> numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle(random);
          for (int num in numbers) {
            if (_isValid(board, row, col, num)) {
              board[row][col] = num;
              if (_fillBoard(board, random)) return true;
              board[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  static List<List<int>> _createPuzzle(
    List<List<int>> solved,
    Difficulty diff,
    int? seed,
  ) {
    List<List<int>> puzzle = solved.map((row) => List<int>.from(row)).toList();
    int cellsToRemove = diff.emptyCells;
    Random random = Random(seed);

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

  // --- Game Logic ---

  void setNumber(
    int row,
    int col,
    int number, {
    bool isMemoMode = false,
    bool autoEraserEnabled = true,
  }) {
    if (initialGrid[row][col] != 0) return;

    // The undoStack logic is removed from here.
    if (isMemoMode && number != 0) {
      if (notes[row][col].contains(number)) {
        notes[row][col].remove(number);
      } else {
        notes[row][col].add(number);
        notes[row][col].sort();
      }
      currentGrid[row][col] = 0;
      errorMap[row][col] = false;
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
            scoreAwarded[row][col] = true;
          }
          // 정답을 입력했을 때 주변 관련 칸의 메모를 지웁니다. (설정된 경우에만)
          if (autoEraserEnabled) {
            _clearNotesInScope(row, col, number);
          }
        }
      } else {
        errorMap[row][col] = false;
      }
    }
  }

  void _clearNotesInScope(int row, int col, int number) {
    // 1. 같은 행의 메모 제거
    for (int c = 0; c < 9; c++) {
      notes[row][c].remove(number);
    }
    // 2. 같은 열의 메모 제거
    for (int r = 0; r < 9; r++) {
      notes[r][col].remove(number);
    }
    // 3. 같은 3x3 박스의 메모 제거
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int r = startRow; r < startRow + 3; r++) {
      for (int c = startCol; c < startCol + 3; c++) {
        notes[r][c].remove(number);
      }
    }
  }

  void fillPossibleNotes(int row, int col) {
    if (initialGrid[row][col] != 0 || currentGrid[row][col] != 0) return;

    notes[row][col].clear();
    for (int num = 1; num <= 9; num++) {
      if (_isValid(currentGrid, row, col, num)) {
        notes[row][col].add(num);
      }
    }
  }

  void giveHint(int row, int col) {
    if (initialGrid[row][col] == 0) {
      currentGrid[row][col] = solution[row][col];
      notes[row][col].clear();
      errorMap[row][col] = false;
      scoreAwarded[row][col] = true;
    }
  }

  // The undo() method is removed.

  bool isSolved() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
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
        if (currentGrid[r][c] == number && !errorMap[r][c]) {
          count++;
        }
      }
    }
    return count;
  }

  // 특정 위치에 숫자를 넣었을 때 충돌하는 칸들을 반환 (레이저 효과용)
  List<Map<String, int>> getConflicts(int row, int col, int number) {
    if (number == 0) return [];
    List<Map<String, int>> conflicts = [];

    // 1. 같은 행 체크
    for (int c = 0; c < 9; c++) {
      if (c != col && currentGrid[row][c] == number) {
        conflicts.add({'row': row, 'col': c});
      }
    }

    // 2. 같은 열 체크
    for (int r = 0; r < 9; r++) {
      if (r != row && currentGrid[r][col] == number) {
        conflicts.add({'row': r, 'col': col});
      }
    }

    // 3. 같은 3x3 박스 체크
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int r = startRow; r < startRow + 3; r++) {
      for (int c = startCol; c < startCol + 3; c++) {
        if ((r != row || c != col) && currentGrid[r][c] == number) {
          // 이미 행/열에서 추가된 경우 중복 방지
          if (!conflicts.any(
            (conflict) => conflict['row'] == r && conflict['col'] == c,
          )) {
            conflicts.add({'row': r, 'col': c});
          }
        }
      }
    }

    return conflicts;
  }

  // 오늘 날짜 전용 시드 생성 (데일리 도전용)
  static int getDailySeed() {
    final now = DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }
}
