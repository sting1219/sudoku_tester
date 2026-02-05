import 'package:flutter/material.dart';
import 'package:sudoku_game/models/dungeon.dart';

class MiniMap extends StatelessWidget {
  final DungeonMap dungeonMap;

  const MiniMap({Key? key, required this.dungeonMap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, // 미니맵 크기
      height: 100, // 미니맵 크기
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        children: List.generate(dungeonMap.height, (y) {
          return Expanded(
            child: Row(
              children: List.generate(dungeonMap.width, (x) {
                Color cellColor;
                if (dungeonMap.currentX == x && dungeonMap.currentY == y) {
                  cellColor = Colors.blue.withOpacity(0.5); // 현재 위치
                } else if (dungeonMap.grid[y][x].isCleared) {
                  cellColor = Colors.green.withOpacity(0.5); // 클리어된 방
                } else {
                  cellColor = Colors.grey.withOpacity(0.2); // 일반 방
                }
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(1),
                    color: cellColor,
                    alignment: Alignment.center,
                    child: Text(
                      '${x},${y}', // 디버그용 좌표 표시
                      style: TextStyle(fontSize: 8, color: Colors.black),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}
