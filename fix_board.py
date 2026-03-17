import os
import re

filepath = r'c:\Users\PCUSER\Desktop\Sudoku\sudoku_game\lib\views\sudoku_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

board_widget_code = """  Widget _buildSudokuBoardWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.zero,
        child: _showMoveButtons
            ? Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: SudokuGrid(
                      key: _gridKey,
                      board: _getCurrentSudokuBoard(),
                      onCellTap: _onCellTapped,
                      onCellLongPress: _handleCellLongPress,
                      selectedRow: _selectedRow,
                      selectedCol: _selectedCol,
                      errorMap: _getCurrentSudokuBoard().errorMap,
                      isSuccess: _isSuccessAnimation,
                      flashingRow: _flashingRow,
                      flashingCol: _flashingCol,
                      conflicts: _currentConflicts,
                      errorRow: _errorRow,
                      errorCol: _errorCol,
                      conflictAnimationValue: _conflictAnimationValue,
                    ),
                  ),
                  if (_errorExplanation != null)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(
                              alpha: 0.9,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            _errorExplanation!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_dungeonMap.currentRoom.isCleared)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "이미 정복한 지역입니다!",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            _buildMoveButtons(),
                          ],
                        ),
                      ),
                    )
                  else
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: _buildMoveButtons(),
                      ),
                    ),
                ],
              )
            : Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: SudokuGrid(
                      key: _gridKey,
                      board: _getCurrentSudokuBoard(),
                      onCellTap: _onCellTapped,
                      onCellLongPress: _handleCellLongPress,
                      selectedRow: _selectedRow,
                      selectedCol: _selectedCol,
                      errorMap: _getCurrentSudokuBoard().errorMap,
                      isSuccess: _isSuccessAnimation,
                      flashingRow: _flashingRow,
                      flashingCol: _flashingCol,
                      conflicts: _currentConflicts,
                      errorRow: _errorRow,
                      errorCol: _errorCol,
                      conflictAnimationValue: _conflictAnimationValue,
                    ),
                  ),
                  if (_errorExplanation != null)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(
                              alpha: 0.9,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _errorExplanation!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

"""

build_pattern = re.compile(r'(  Widget _buildResponsiveLayout\(\) \{)')
if build_pattern.search(content):
    content = build_pattern.sub(board_widget_code + r'\1', content, count=1)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print('Successfully inserted _buildSudokuBoardWidget!')
else:
    print('Failed to find _buildResponsiveLayout method.')
