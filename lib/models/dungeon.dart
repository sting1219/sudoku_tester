import 'dart:math';
import 'package:sudoku_game/models/sudoku_board.dart';
import '../data/lore_data.dart';

// 던전의 각 방(Room)의 타입을 정의합니다.
enum RoomType { normal, elite, shop, boss }

// 던전의 한 칸을 나타내는 방(Room) 클래스입니다.
class RoomData {
  final RoomType type;
  bool isCleared;
  bool isExplored; // 탐험 여부 추가
  final Difficulty difficulty;
  final SudokuBoard board;

  // 수집 및 도감용 메타데이터
  final String artifactName;
  final String artifactLore;
  final int artifactNumber;

  RoomData({
    required this.type,
    this.isCleared = false,
    this.isExplored = false,
    required this.difficulty,
    required this.board,
    required this.artifactName,
    required this.artifactLore,
    required this.artifactNumber,
  });

  RoomData clone() {
    return RoomData(
      type: type,
      isCleared: isCleared,
      isExplored: isExplored,
      difficulty: difficulty,
      board: board.clone(),
      artifactName: artifactName,
      artifactLore: artifactLore,
      artifactNumber: artifactNumber,
    );
  }
}

class DungeonMap {
  final int width;
  final int height;
  late List<List<RoomData>> grid;

  int currentX;
  int currentY;

  DungeonMap({
    this.width = 5,
    this.height = 5,
    this.currentX = 0,
    this.currentY = 4,
  }) {
    final random = Random();
    grid = List.generate(
      height,
      (y) => List.generate(width, (x) {
        int distance = (x - 0).abs() + (y - 4).abs();

        Difficulty diff;
        if (distance <= 2) {
          diff = Difficulty.easy;
        } else if (distance <= 4) {
          diff = Difficulty.medium;
        } else {
          diff = Difficulty.hard;
        }

        RoomType type = RoomType.normal;
        if (x == 4 && y == 0) {
          type = RoomType.boss;
          diff = Difficulty.hard;
        } else if (distance >= 4 && (x + y) % 3 == 0) {
          type = RoomType.elite;
        }

        // 유물 및 설정 문구 생성
        int artNum = random.nextInt(9) + 1;
        String artName = _generateArtifactName(type, artNum);
        String artLore = _generateArtifactLore(type, artNum);

        return RoomData(
          type: type,
          difficulty: diff,
          board: SudokuBoard(difficulty: diff),
          isExplored: (x == 0 && y == 4),
          artifactName: artName,
          artifactLore: artLore,
          artifactNumber: artNum,
        );
      }),
    );
  }

  String _generateArtifactName(RoomType type, int number) {
    if (type == RoomType.boss) return "심연의 정수 #$number";
    if (type == RoomType.elite) return "고대인의 투구 #$number";
    return "정원의 파편 #$number";
  }

  String _generateArtifactLore(RoomType type, int number) {
    return LoreData.getLore(number);
  }

  double get purificationRate {
    int clearedCount = 0;
    for (var row in grid) {
      for (var room in row) {
        if (room.isCleared) clearedCount++;
      }
    }
    return clearedCount / (width * height);
  }

  RoomData get currentRoom => grid[currentY][currentX];

  // 현재 방과 인접하거나 이미 가본 방인지 (미니맵 표시용)
  bool isVisible(int x, int y) {
    if (grid[y][x].isExplored) return true;
    // 인접한 방인지 체크
    int dx = (x - currentX).abs();
    int dy = (y - currentY).abs();
    return (dx + dy) == 1;
  }

  // 해당 방향으로 이동 가능한지
  bool canMoveTo(int targetX, int targetY) {
    if (targetX < 0 || targetX >= width || targetY < 0 || targetY >= height)
      return false;
    // 현재 방이 클리어되어야 이동 가능
    if (!currentRoom.isCleared) return false;
    // 인접한 칸만 이동 가능
    int dx = (targetX - currentX).abs();
    int dy = (targetY - currentY).abs();
    return (dx + dy) == 1;
  }

  void move(int newX, int newY) {
    if (newX >= 0 && newX < width && newY >= 0 && newY < height) {
      currentX = newX;
      currentY = newY;
      grid[currentY][currentX].isExplored = true; // 이동한 방 탐험 처리
    }
  }

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
      grid: grid
          .map((row) => row.map((room) => room.clone()).toList())
          .toList(),
      currentX: currentX,
      currentY: currentY,
    );
  }
}
