import 'package:flutter/material.dart';

class MiniSudokuGrid extends StatelessWidget {
  final List<int> snapshot;

  const MiniSudokuGrid({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    if (snapshot.length != 81) {
      return Container(
        color: Colors.white10,
        child: const Center(
          child: Icon(Icons.grid_on, color: Colors.white24, size: 20),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
        ),
        itemCount: 81,
        itemBuilder: (context, index) {
          final value = snapshot[index];
          final row = index ~/ 9;
          final col = index % 9;

          // 구역 구분 (3x3 블록)
          final bool rightBorder = (col + 1) % 3 == 0 && col != 8;
          final bool bottomBorder = (row + 1) % 3 == 0 && row != 8;

          return Container(
            decoration: BoxDecoration(
              border: Border(
                right: rightBorder
                    ? const BorderSide(color: Colors.white38, width: 0.5)
                    : BorderSide.none,
                bottom: bottomBorder
                    ? const BorderSide(color: Colors.white38, width: 0.5)
                    : BorderSide.none,
              ),
            ),
            child: Center(
              child: Text(
                value == 0 ? "" : value.toString(),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
