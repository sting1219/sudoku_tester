import os
import re

filepath = r'c:\Users\PCUSER\Desktop\Sudoku\sudoku_game\lib\views\sudoku_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove any existing broken _buildResponsiveLayout (should be none now)
content = re.sub(r'  Widget _buildResponsiveLayout\(\) \{.*?(^\s*@override\s*$|^\s*Widget build\(BuildContext context\))',
                 r'\1', content, flags=re.DOTALL | re.MULTILINE)

new_responsive = """  Widget _buildResponsiveLayout() {
    bool isLocked = _isCellLocked();
    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent && !_isPaused) {
          if (_showMoveButtons) {
            switch (event.logicalKey) {
              case LogicalKeyboardKey.arrowUp:
                _moveToRoom(_dungeonMap.currentX, _dungeonMap.currentY - 1);
                break;
              case LogicalKeyboardKey.arrowDown:
                _moveToRoom(_dungeonMap.currentX, _dungeonMap.currentY + 1);
                break;
              case LogicalKeyboardKey.arrowLeft:
                _moveToRoom(_dungeonMap.currentX - 1, _dungeonMap.currentY);
                break;
              case LogicalKeyboardKey.arrowRight:
                _moveToRoom(_dungeonMap.currentX + 1, _dungeonMap.currentY);
                break;
            }
          }
          final label = event.logicalKey.keyLabel;
          if (RegExp(r'^[1-9]$').hasMatch(label)) {
            _handleNumberInput(int.parse(label));
          } else if (label == 'f' || label == 'F') {
            _fillOneEmptyCellWithAnswer();
          } else if (event.logicalKey == LogicalKeyboardKey.backspace ||
              event.logicalKey == LogicalKeyboardKey.delete) {
            _handleNumberInput(0);
          }
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      MonsterStatus(key: _monsterKey, monster: _currentMonster),
                      const SizedBox(height: 10),
                      Expanded(child: _buildSudokuBoardWidget()),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Column(
                        children: [
                          _buildTopControls(),
                          ActionButtons(
                            onUndo: (_history.isEmpty || _undoUses >= _maxUndoUses) ? null : () {
                              _undoUses++;
                              _handleUndo();
                            },
                            onDelete: (isLocked || _isPaused) ? null : () => _handleNumberInput(0),
                            onMemoToggle: isLocked ? null : () => setState(() => _isMemoMode = !_isMemoMode),
                            isMemoOn: _isMemoMode,
                            hintCount: _hintsRemaining,
                            onHint: (isLocked || _hintsRemaining <= 0 || _isPaused || _selectedRow == null) ? null : _handleHint,
                            undoCount: _undoUses,
                            maxUndoCount: _maxUndoUses,
                          ),
                          NumberKeypad(
                            board: _getCurrentSudokuBoard(),
                            onNumberTap: (_isPaused || isLocked) ? null : (n) => _handleNumberInput(n),
                          ),
                          CombatLog(logMessages: _combatLogMessages),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "Map Pos: (${_dungeonMap.currentX}, ${_dungeonMap.currentY})",
                              style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                            ),
                          ),
                          _buildQuickSlots(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                _buildTopControls(),
                MonsterStatus(key: _monsterKey, monster: _currentMonster),
                Expanded(child: _buildSudokuBoardWidget()),
                ActionButtons(
                  onUndo: (_history.isEmpty || _undoUses >= _maxUndoUses) ? null : () {
                    _undoUses++;
                    _handleUndo();
                  },
                  onDelete: (isLocked || _isPaused) ? null : () => _handleNumberInput(0),
                  onMemoToggle: isLocked ? null : () => setState(() => _isMemoMode = !_isMemoMode),
                  isMemoOn: _isMemoMode,
                  hintCount: _hintsRemaining,
                  onHint: (isLocked || _hintsRemaining <= 0 || _isPaused || _selectedRow == null) ? null : _handleHint,
                  undoCount: _undoUses,
                  maxUndoCount: _maxUndoUses,
                ),
                NumberKeypad(
                  board: _getCurrentSudokuBoard(),
                  onNumberTap: (_isPaused || isLocked) ? null : (n) => _handleNumberInput(n),
                ),
                CombatLog(logMessages: _combatLogMessages),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Map Pos: (${_dungeonMap.currentX}, ${_dungeonMap.currentY})",
                    style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                ),
                _buildQuickSlots(),
              ],
            );
          }
        },
      ),
    );
  }
"""

build_pattern = re.compile(r'(  @override\n  Widget build\(BuildContext context\) \{)')
if build_pattern.search(content):
    content = build_pattern.sub(new_responsive + r'\n\1', content, count=1)
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print('Successfully inserted _buildResponsiveLayout!')
else:
    print('Failed to find build method.')
