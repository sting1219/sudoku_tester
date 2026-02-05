import 'package:flutter/material.dart';
import '../models/sudoku_board.dart';

class SudokuGrid extends StatelessWidget {
  final SudokuBoard board;
  final Function(int row, int col) onCellTap; // 셀이 탭되었을 때 호출될 콜백
  final int? selectedRow; // 현재 선택된 셀의 행
  final int? selectedCol; // 현재 선택된 셀의 열
  final List<List<bool>> errorMap; 
  final bool isSuccess;

  const SudokuGrid({
    super.key,
    required this.board,
    required this.onCellTap,
    this.selectedRow,
    this.selectedCol,
    required this.errorMap, 
    this.isSuccess = false,
  });

// lib/widgets/sudoku_grid.dart 클래스 내부
Widget _buildCellContent(SudokuBoard board, int row, int col, bool isInitial, bool isError) {
    int value = board.currentGrid[row][col];
    List<int> cellNotes = board.notes[row][col];

    // 1. 숫자가 있는 경우 (확정된 숫자)
    if (value != 0) {
      return Text(
        value.toString(),
        style: TextStyle(
          fontSize: 24, // ⭐️ 가독성을 위해 크기 살짝 키움
          fontWeight: isInitial ? FontWeight.w900 : FontWeight.bold,
          // 에러면 흰색(배경이 빨강이므로), 아니면 (초기값이면 검정, 사용자가 입력한 거면 파랑)
          color: isError ? Colors.white : (isInitial ? Colors.black : Colors.blue[700]),
        ),
      );
    }

    // 2. 숫자가 없고 메모가 있는 경우
    if (cellNotes.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(3.0), // ⭐️ 메모 간격 최적화
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.0,
          ),
          itemCount: 9,
          itemBuilder: (context, i) {
            int noteNum = i + 1;
            bool hasNote = cellNotes.contains(noteNum);
            return Center(
              child: Text(
                hasNote ? '$noteNum' : '',
                style: TextStyle(
                  fontSize: 11, // ⭐️ 요청하신 대로 크기 키움 (기존 8 -> 11)
                  fontWeight: FontWeight.bold, // ⭐️ 볼드 처리로 더 뚜렷하게
                  color: Colors.blueGrey[600],
                  height: 1.0,
                ),
              ),
            );
          },
        ),
      );
    }

    // 3. 아무것도 없는 빈 칸
    return const SizedBox.shrink();
  }
  
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0, // 보드를 항상 정사각형으로 유지
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 3.0), // 전체 테두리
        ),
        child: GridView.builder(
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
            final isSelected = row == selectedRow && col == selectedCol; // 선택 여부
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
              
              if (row == selectedRow || col == selectedCol || 
                (row >= startRow && row < startRow + 3 && col >= startCol && col < startCol + 3)) {
                isRelated = true;
              }
            }
            // 3. 같은 숫자를 가진 셀 체크 (0 제외)
            bool isSameValue = false;
            if (selectedValue != null && selectedValue != 0 && 
                board.currentGrid[row][col] == selectedValue) {
              isSameValue = true;
            }
            // 4. 색상 우선순위 결정
            Color cellColor = Colors.white; // 기본색
            if (isError) {
              cellColor = Colors.red[200]!; // 에러가 최우선
            } else if (isSelected) {
              cellColor = Colors.blue[300]!; // 선택된 셀 (진한 파랑)
            } else if (isSameValue) {
              cellColor = Colors.blue[100]!; // 같은 숫자 셀 (중간 파랑)
            } else if (isRelated) {
              cellColor = const Color(0xFFE8F0FE); // 관련 라인 (매우 연한 파랑)
            }

            // 🎇 성공 시 색상 변경 (초록색 반짝임)
      if (isSuccess) {
        cellColor = Colors.green[300]!;
      }

            return GestureDetector(
              onTap: isSuccess ? null : () => onCellTap(row, col), // 성공 시 터치 막기
              child: AnimatedContainer( // Container를 AnimatedContainer로 변경
                duration: Duration(milliseconds: isSuccess ? 600 : 0),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                color: cellColor,
                  border: Border(
                    // 얇은 그리드 라인
                    top: BorderSide(width: row % 3 == 0 ? 2 : 0.5, color: Colors.black),
                    left: BorderSide(width: col % 3 == 0 ? 2 : 0.5, color: Colors.black),
                    right: BorderSide(width: col == 8 ? 2 : 0, color: Colors.black),
                    bottom: BorderSide(width: row == 8 ? 2 : 0, color: Colors.black),
                  ),
                ),
                child: Center(
                    child: isSuccess 
                    ? const Icon(Icons.check_circle, color: Colors.white, size: 24) // ⭐️ 숫지 대신 체크 아이콘
                    : _buildCellContent(board, row, col, isInitial, isError),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
