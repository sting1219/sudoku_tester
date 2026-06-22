import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sudoku_board.dart';
import '../utils/app_styles.dart';
import 'shake_widget.dart';
import 'conflict_painter.dart';

class SudokuGrid extends StatelessWidget {
  final SudokuBoard board;
  final Function(int row, int col) onCellTap;
  final int? selectedRow;
  final int? selectedCol;
  final List<List<bool>> errorMap;
  final bool isSuccess;
  final int? flashingRow;
  final int? flashingCol;
  final Function(int row, int col)? onCellLongPress;
  final List<Map<String, int>> conflicts;
  final int? errorRow;
  final int? errorCol;
  final double conflictAnimationValue;
  final Set<String> foggyCells; // 안개 낀 칸 좌표 ("row,col")

  const SudokuGrid({
    super.key,
    required this.board,
    required this.onCellTap,
    this.selectedRow,
    this.selectedCol,
    required this.errorMap,
    this.isSuccess = false,
    this.flashingRow,
    this.flashingCol,
    this.onCellLongPress,
    this.conflicts = const [],
    this.errorRow,
    this.errorCol,
    this.conflictAnimationValue = 0.0,
    this.foggyCells = const {},
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white54, width: 2.0),
        ),
        child: Stack(
          children: [
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 9,
                childAspectRatio: 1.0,
                crossAxisSpacing: 0.0,
                mainAxisSpacing: 0.0,
              ),
              itemCount: 81,
              itemBuilder: (context, index) {
                final row = index ~/ 9;
                final col = index % 9;
                final isInitial = board.initialGrid[row][col] != 0;
                final isSelected = row == selectedRow && col == selectedCol;
                final isError = errorMap[row][col];

                int? selectedValue;
                if (selectedRow != null && selectedCol != null) {
                  selectedValue = board.currentGrid[selectedRow!][selectedCol!];
                }

                bool isRelated = false;
                if (selectedRow != null && selectedCol != null) {
                  int startRow = (selectedRow! ~/ 3) * 3;
                  int startCol = (selectedCol! ~/ 3) * 3;
                  if (row == selectedRow ||
                      col == selectedCol ||
                      (row >= startRow &&
                          row < startRow + 3 &&
                          col >= startCol &&
                          col < startCol + 3)) {
                    isRelated = true;
                  }
                }

                bool isSameValue = false;
                if (selectedValue != null &&
                    selectedValue != 0 &&
                    board.currentGrid[row][col] == selectedValue) {
                  isSameValue = true;
                }

                bool isFlashing = false;
                if (flashingRow != null && flashingCol != null) {
                  int fStartRow = (flashingRow! ~/ 3) * 3;
                  int fStartCol = (flashingCol! ~/ 3) * 3;
                  if (row == flashingRow ||
                      col == flashingCol ||
                      (row >= fStartRow &&
                          row < fStartRow + 3 &&
                          col >= fStartCol &&
                          col < fStartCol + 3)) {
                    isFlashing = true;
                  }
                }

                return SudokuCell(
                  key: ValueKey('cell_${row}_${col}'),
                  row: row,
                  col: col,
                  value: board.currentGrid[row][col],
                  notes: board.notes[row][col],
                  isInitial: isInitial,
                  isSelected: isSelected,
                  isError: isError,
                  isRelated: isRelated,
                  isSameValue: isSameValue,
                  isFlashing: isFlashing,
                  isSuccess: isSuccess,
                  isShake: row == errorRow && col == errorCol,
                  isFoggy: foggyCells.contains("$row,$col"),
                  onTap: () => onCellTap(row, col),
                  onLongPress: () => onCellLongPress?.call(row, col),
                );
              },
            ),
            if (conflicts.isNotEmpty && errorRow != null && errorCol != null)
              IgnorePointer(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: ConflictPainter(
                    conflicts: conflicts,
                    targetRow: errorRow!,
                    targetCol: errorCol!,
                    animationValue: conflictAnimationValue,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SudokuCell extends StatelessWidget {
  final int row;
  final int col;
  final int value;
  final List<int> notes;
  final bool isInitial;
  final bool isSelected;
  final bool isError;
  final bool isRelated;
  final bool isSameValue;
  final bool isFlashing;
  final bool isSuccess;
  final bool isShake;
  final bool isFoggy;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const SudokuCell({
    super.key,
    required this.row,
    required this.col,
    required this.value,
    required this.notes,
    required this.isInitial,
    required this.isSelected,
    required this.isError,
    required this.isRelated,
    required this.isSameValue,
    required this.isFlashing,
    required this.isSuccess,
    required this.isShake,
    this.isFoggy = false,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseColor = AppColors.scaffoldBackground;
    Color cellColor = baseColor;

    if (isError) {
      cellColor = Color.alphaBlend(
        Colors.red.withValues(alpha: 0.4),
        baseColor,
      );
    } else if (isFlashing) {
      cellColor = Color.alphaBlend(
        Colors.amber.withValues(alpha: 0.6),
        baseColor,
      );
    } else if (isSelected) {
      cellColor = Color.alphaBlend(
        Colors.blue.withValues(alpha: 0.5),
        baseColor,
      );
    } else if (isSameValue) {
      cellColor = Color.alphaBlend(
        Colors.blueAccent.withValues(alpha: 0.4),
        baseColor,
      );
    } else if (isRelated) {
      cellColor = Color.alphaBlend(
        Colors.white.withValues(alpha: 0.1),
        baseColor,
      );
    }

    if (isSuccess) {
      cellColor = Colors.green[400]!;
    }

    return ShakeWidget(
      shake: isShake,
      child: GestureDetector(
        onTap: isSuccess ? null : onTap,
        onLongPress: isSuccess ? null : onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: cellColor,
            boxShadow: (isSuccess || isFlashing)
                ? [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.5),
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ),
                  ]
                : null,
            border: isSelected
                ? Border.all(color: Colors.white, width: 3.0)
                : isSameValue
                    ? Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5)
                    : Border(
                    top: BorderSide(
                      width: row % 3 == 0 ? 3.0 : 0.5,
                      color: row % 3 == 0
                          ? const Color(0xFF3D522B)
                          : const Color(0xFF2A3621),
                    ),
                    left: BorderSide(
                      width: col % 3 == 0 ? 3.0 : 0.5,
                      color: col % 3 == 0
                          ? const Color(0xFF3D522B)
                          : const Color(0xFF2A3621),
                    ),
                    right: BorderSide(
                      width: col == 8 ? 3.0 : 0.5,
                      color: col == 8
                          ? const Color(0xFF3D522B)
                          : const Color(0xFF2A3621),
                    ),
                    bottom: BorderSide(
                      width: row == 8 ? 3.0 : 0.5,
                      color: row == 8
                          ? const Color(0xFF3D522B)
                          : const Color(0xFF2A3621),
                    ),
                  ),
          ),
          child: Center(
            child: isSuccess
                ? const Icon(Icons.check_circle, color: Colors.white, size: 24)
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildCellContent(),
                      if (isFoggy)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          color: Colors.grey.withValues(alpha: 0.9),
                          child: const Center(
                            child: Icon(Icons.cloud, color: Colors.white70, size: 20),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCellContent() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Center(
        child: value != 0
            ? FittedBox(
                fit: BoxFit.contain,
                child: TweenAnimationBuilder<double>(
                  key: ValueKey('cell_text_${row}_${col}_$value'),
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Text(
                        value.toString(),
                        style: GoogleFonts.cinzel(
                          fontSize: 34,
                          fontWeight: isInitial
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isError
                              ? AppColors.dangerColor
                              : (isInitial
                                    ? AppColors.textHeadline
                                    : AppColors.accentColor),
                          shadows: isInitial
                              ? [
                                  Shadow(
                                    blurRadius: 2.0,
                                    color: Colors.black.withValues(alpha: 0.5),
                                    offset: const Offset(0.5, 0.5),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              )
            : (notes.isNotEmpty
                  ? GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.0,
                          ),
                      itemCount: 9,
                      itemBuilder: (context, i) {
                        int noteNum = i + 1;
                        bool hasNote = notes.contains(noteNum);
                        return Center(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              hasNote ? '$noteNum' : '',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                                color: AppColors.textBody.withValues(
                                  alpha: 0.5,
                                ),
                                height: 1.0,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : const SizedBox.shrink()),
      ),
    );
  }
}
