import 'dart:math';
import 'package:sudoku_game/models/sudoku_board.dart';

// 던전의 각 방(Room)의 타입을 정의합니다.
enum RoomType {
  normal,
  elite,
  shop,
  boss,
}

// 던전의 한 칸을 나타내는 방(Room) 클래스입니다.
class RoomData {
  final RoomType type;
  bool isCleared;
  final Difficulty difficulty; // 각 방의 스도쿠 난이도
  final SudokuBoard board; // 각 방마다 고유한 스도쿠 퍼즐

  RoomData({
    required this.type,
    this.isCleared = false,
    required this.difficulty,
    required this.board,
  });

  RoomData clone() {
    return RoomData(
      type: type,
      isCleared: isCleared,
      difficulty: difficulty,
      board: board.clone(), // SudokuBoard도 깊은 복사
    );
  }
}

// 전체 던전 맵과 플레이어의 현재 위치를 관리하는 클래스입니다.
class DungeonMap {
  final int width;
  final int height;
  late List<List<RoomData>> grid; // 5x5 2차원 배열

  int currentX;
  int currentY;

  DungeonMap({
    this.width = 5,
    this.height = 5,
    this.currentX = 2, // 중앙 (2,2) 시작
    this.currentY = 2,
  }) {
    grid = List.generate(height, (y) => List.generate(width, (x) {
      // 중심(2, 2)으로부터의 거리 계산 (Manhattan distance)
      int distance = (x - 2).abs() + (y - 2).abs();
      
      Difficulty diff;
      if (distance <= 1) {
        diff = Difficulty.easy;
      } else if (distance == 2) {
        diff = Difficulty.medium;
      } else {
        diff = Difficulty.hard;
      }

      return RoomData(
        type: (distance >= 3) ? RoomType.elite : RoomType.normal,
        difficulty: diff,
        board: SudokuBoard(difficulty: diff),
      );
    }));
  }

  // 현재 방을 가져옵니다.
  RoomData get currentRoom => grid[currentY][currentX];

  // 플레이어 이동 로직 (단순히 좌표만 변경)
  void move(int newX, int newY) {
    if (newX >= 0 && newX < width && newY >= 0 && newY < height) {
      currentX = newX;
      currentY = newY;
    }
  }

  // clone을 위한 private 생성자
  DungeonMap._clone({
    required this.width,
    required this.height,
    required this.grid,
    required this.currentX,
    required this.currentY,
  });

  DungeonMap clone() {
    return DungeonMap._clone(
      width: width,
      height: height,
      grid: grid.map((row) => row.map((room) => room.clone()).toList()).toList(),
      currentX: currentX,
      currentY: currentY,
    );
  }
}
