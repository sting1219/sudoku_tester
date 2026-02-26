import '../models/sudoku_board.dart';
import '../models/combat_data.dart';

class GameController {
  static const Map<Difficulty, int> _baseGold = {
    Difficulty.easy: 15,
    Difficulty.medium: 50,
    Difficulty.hard: 200,
  };

  static const Map<Difficulty, int> _baseXp = {
    Difficulty.easy: 60,
    Difficulty.medium: 250,
    Difficulty.hard: 1200,
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

  /// Calculates the reward (Gold, XP) based on difficulty, time, and mistakes.
  static (int, int) calculateReward({
    required Difficulty difficulty,
    required int timeElapsed,
    required int mistakes,
  }) {
    double gold = _baseGold[difficulty]!.toDouble();
    double xp = _baseXp[difficulty]!.toDouble();

    if (mistakes == 0) {
      gold *= 1.2;
      xp *= 1.2;
    }

    final targetTime = _targetTimes[difficulty];
    if (targetTime != null && timeElapsed <= targetTime) {
      gold *= 1.3;
      xp *= 1.3;
    }

    return (gold.toInt(), xp.toInt());
  }

  /// Checks if filling a cell completes a row, column, or box (Critical Hit).
  static bool isCellCompletionCritical(
    SudokuBoard board,
    int row,
    int col,
    int number,
  ) {
    final tempBoard = board.clone();
    tempBoard.currentGrid[row][col] = number;

    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;

    // Check Box
    bool boxComplete = true;
    for (int r = startRow; r < startRow + 3; r++) {
      for (int c = startCol; c < startCol + 3; c++) {
        if (tempBoard.currentGrid[r][c] == 0) {
          boxComplete = false;
          break;
        }
      }
      if (!boxComplete) break;
    }
    if (boxComplete) return true;

    // Check Row
    bool rowComplete = true;
    for (int c = 0; c < 9; c++) {
      if (tempBoard.currentGrid[row][c] == 0) {
        rowComplete = false;
        break;
      }
    }
    if (rowComplete) return true;

    // Check Column
    bool colComplete = true;
    for (int r = 0; r < 9; r++) {
      if (tempBoard.currentGrid[r][col] == 0) {
        colComplete = false;
        break;
      }
    }
    if (colComplete) return true;

    return false;
  }

  /// Calculates damage dealt based on input number and player stats.
  static int calculateDamage(
    int number,
    PlayerCombatStats stats,
    Difficulty difficulty,
  ) {
    final double difficultyMultiplier =
        _difficultyDamageMultiplier[difficulty] ?? 1.0;
    return (number * stats.attackPower * difficultyMultiplier).toInt();
  }
}
