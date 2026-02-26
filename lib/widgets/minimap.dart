import 'package:flutter/material.dart';
import 'package:sudoku_game/models/dungeon.dart';
import 'room_info_dialog.dart';

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
                final room = dungeonMap.grid[y][x];
                final isVisible = dungeonMap.isVisible(x, y);

                Color cellColor;
                Widget? content;

                if (!isVisible) {
                  cellColor = Colors.black.withValues(
                    alpha: 0.8,
                  ); // 안개 (보이지 않음)
                } else {
                  if (dungeonMap.currentX == x && dungeonMap.currentY == y) {
                    cellColor = Colors.blueAccent.withValues(
                      alpha: 0.7,
                    ); // 현재 위치
                    content = const Icon(
                      Icons.person,
                      size: 12,
                      color: Colors.white,
                    );
                  } else if (room.isCleared) {
                    cellColor = Colors.green.withValues(alpha: 0.4); // 클리어된 방
                    content = const Icon(
                      Icons.check,
                      size: 10,
                      color: Colors.white70,
                    );
                  } else {
                    cellColor = Colors.grey.withValues(alpha: 0.3); // 일반/탐험된 방
                    if (room.type == RoomType.boss) {
                      content = const Icon(
                        Icons.stars,
                        size: 14,
                        color: Colors.red,
                      );
                    } else if (room.type == RoomType.elite) {
                      content = const Icon(
                        Icons.warning_amber_rounded,
                        size: 12,
                        color: Colors.orange,
                      );
                    }
                  }
                }

                return Expanded(
                  child: GestureDetector(
                    onTap: isVisible
                        ? () {
                            showDialog(
                              context: context,
                              builder: (context) => RoomInfoDialog(room: room),
                            );
                          }
                        : null,
                    child: Container(
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: cellColor,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color:
                              (dungeonMap.currentX == x &&
                                  dungeonMap.currentY == y)
                              ? Colors.white
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: content,
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
