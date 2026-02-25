import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sudoku_board.dart';
import 'shake_widget.dart';
import 'conflict_painter.dart';

class SudokuGrid extends StatelessWidget {
  final SudokuBoard board;
  final Function(int row, int col) onCellTap; // 셀이 탭되었을 때 호출될 콜백
  final int? selectedRow; // 현재 선택된 셀의 행
  final int? selectedCol; // 현재 선택된 셀의 열
  final List<List<bool>> errorMap;
  final bool isSuccess;
  final int? flashingRow; // 플래시 효과를 줄 행
  final int? flashingCol; // 플래시 효과를 줄 열

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
  });

  final Function(int row, int col)? onCellLongPress;
  final List<Map<String, int>> conflicts;
  final int? errorRow;
  final int? errorCol;
  final double conflictAnimationValue;

  // lib/widgets/sudoku_grid.dart 클래스 내부
  Widget _buildCellContent(
    SudokuBoard board,
    int row,
    int col,
    bool isInitial,
    bool isError,
  ) {
    int value = board.currentGrid[row][col];
    List<int> cellNotes = board.notes[row][col];

    // 내부 여백을 주어 테두리와 숫자가 겹치지 않게 보호
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Center(
        child: value != 0
            ? // 1. 값이 있는 경우: 중앙에 큰 숫자 하나만 배치
              FittedBox(
                fit: BoxFit.contain,
                child: TweenAnimationBuilder<double>(
                  key: ValueKey('cell_${row}_${col}_$value'),
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
                              ? Colors.redAccent
                              : (isInitial
                                    ? Colors.white
                                    : const Color(0xFF00E5FF)),
                          shadows: isInitial
                              ? [
                                  Shadow(
                                    blurRadius: 2.0,
                                    color: Colors.black.withOpacity(0.5),
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
            : // 2. 값이 없는 경우: 메모 그리드 배치 (값이 있을 때는 아예 렌더링 안 됨)
              (cellNotes.isNotEmpty
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
                        bool hasNote = cellNotes.contains(noteNum);
                        return Center(
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              hasNote ? '$noteNum' : '',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.normal,
                                color: Colors.blueGrey[300],
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

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0, // 보드를 항상 정사각형으로 유지
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white54, width: 2.0), // 전체 테두리 상향
        ),
        child: Stack(
          children: [
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(), // 스크롤 방지
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
                final isInitial = board.initialGrid[row][col] != 0; // 힌트 숫자 여부
                final isSelected =
                    row == selectedRow && col == selectedCol; // 선택 여부
                final isError = errorMap[row][col]; // 에러 발생 여부 확인
                // 현재 선택된 셀의 숫자 (0이 아닐 때만)
                int? selectedValue;
                if (selectedRow != null && selectedCol != null) {
                  selectedValue = board.currentGrid[selectedRow!][selectedCol!];
                }

                // 2. 관련 라인(행/열/박스) 체크 로직
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
                // 3. 같은 숫자를 가진 셀 체크 (0 제외)
                bool isSameValue = false;
                if (selectedValue != null &&
                    selectedValue != 0 &&
                    board.currentGrid[row][col] == selectedValue) {
                  isSameValue = true;
                }

                // 3.5 정답 플래시 영역 체크
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
                // 4. 색상 우선순위 결정 (AlphaBlend로 '중첩' 효과 구현)
                const Color baseColor = Color(
                  0xFF13221C,
                ); // Darker Garden Green
                Color cellColor = baseColor;

                if (isError) {
                  cellColor = Color.alphaBlend(
                    Colors.red.withOpacity(0.4),
                    baseColor,
                  );
                } else if (isFlashing) {
                  // 정답 플래시 효과: 황금색/밝은 파란색
                  cellColor = Color.alphaBlend(
                    Colors.amber.withOpacity(0.6),
                    baseColor,
                  );
                } else if (isSelected) {
                  cellColor = const Color(
                    0xFF2D5A4C,
                  ); // Muted Emerald Selection
                } else if (isSameValue) {
                  // sameNumberBg: rgba(74, 144, 226, 0.3)를 base 위에 중첩
                  cellColor = Color.alphaBlend(
                    const Color(0xFF4A90E2).withOpacity(0.2),
                    baseColor,
                  );
                } else if (isRelated) {
                  // relatedBg: rgba(255, 255, 255, 0.08)를 base 위에 중첩 (은은한 밝기)
                  cellColor = Color.alphaBlend(
                    Colors.white.withOpacity(0.05),
                    baseColor,
                  );
                }

                // 🎇 성공 시 색상 변경 (초록색 반짝임)
                if (isSuccess) {
                  cellColor = Colors.green[400]!;
                }

                return ShakeWidget(
                  shake: row == errorRow && col == errorCol,
                  child: GestureDetector(
                    onTap: isSuccess
                        ? null
                        : () => onCellTap(row, col), // 성공 시 터치 막기
                    onLongPress: isSuccess
                        ? null
                        : () => onCellLongPress?.call(row, col),
                    child: AnimatedContainer(
                      // Container를 AnimatedContainer로 변경
                      duration: Duration(
                        milliseconds: (isSuccess || isFlashing) ? 500 : 0,
                      ),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: cellColor,
                        boxShadow: (isSuccess || isFlashing)
                            ? [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.5),
                                  blurRadius: 10.0,
                                  spreadRadius: 2.0,
                                ),
                              ]
                            : null,
                        border: Border(
                          // 격자 선 선명화 및 교차점 마감 정밀화
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
                            width: col == 8 ? 3.0 : 0,
                            color: col == 8
                                ? const Color(0xFF3D522B)
                                : const Color(0xFF2A3621),
                          ),
                          bottom: BorderSide(
                            width: row == 8 ? 3.0 : 0,
                            color: row == 8
                                ? const Color(0xFF3D522B)
                                : const Color(0xFF2A3621),
                          ),
                        ),
                      ),
                      child: Center(
                        child: isSuccess
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 24,
                              ) // ⭐️ 숫지 대신 체크 아이콘
                            : _buildCellContent(
                                board,
                                row,
                                col,
                                isInitial,
                                isError,
                              ),
                      ),
                    ),
                  ),
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
